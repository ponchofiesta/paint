import 'dart:core';
import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:math';

import 'package:angular/angular.dart';

import 'package:paint/src/Canvas.dart';
import 'package:paint/src/Color.dart';

@Component(
  selector: 'paint',
  encapsulation: ViewEncapsulation.None, // disable angular css classes
  styleUrls: const ['paint_component.css'],
  templateUrl: 'paint_component.html',
  directives: const [
    NgClass,
    NgStyle
  ],
)
class PaintComponent implements OnInit {

  Canvas canvas;

  int penSize = 10;
  int filterSize = 10;
  String activeTool = 'mark';
  bool isToolShown = false;
  Color color = new Color(0, 0, 0, 255);
  Point mousePosition = new Point(0, 0);
  Point markPositionStart = new Point(0, 0);
  Rectangle markRect = new Rectangle(0, 0, 0, 0);
  bool isMouseDown = false;

  String font = 'Arial';
  num fontSize = 12;
  String fontStyle = '';
  String fontWeight = '';


  @override
  Future<Null> ngOnInit() async {

    // create empty image
    createImage(width: 480, height: 320);

    // tools: pen popup
    context
        .callMethod(r'$', ['.tools .pen'])
        .callMethod('popup', [new JsObject.jsify({
          'popup': context.callMethod(r'$', ['.pen.popup']),
          'on': 'click',
          'hoverable': true,
          'position': 'right center'
        })]);

    // tools: rubber popup
    context
        .callMethod(r'$', ['.tools .rubber'])
        .callMethod('popup', [new JsObject.jsify({
      'popup': context.callMethod(r'$', ['.pen.popup']),
      'on': 'click',
      'hoverable': true,
      'position': 'right center'
    })]);

    // tools: text tool chooser
    context
        .callMethod(r'$', ['.ui.dropdown'])
        .callMethod('dropdown');

    // tools: default color
    (querySelector('.tools input[type="color"]') as InputElement).value = '#fff';

    querySelector('body')
      ..onMouseUp.listen(mouseUpCanvas)
      ..onMouseMove.listen(mouseMoveCanvas);

  }

  void newImage() {
    context
        .callMethod(r'$', ['#new-image-modal'])
        .callMethod('modal', [new JsObject.jsify({
          'onApprove': new JsFunction.withThis((element){
            int width = (querySelector('#new-image-modal form input[name="width"]') as InputElement).valueAsNumber;
            int height = (querySelector('#new-image-modal form input[name="height"]') as InputElement).valueAsNumber;
            createImage(width: width, height: height);
          })
        })])
        .callMethod('modal', ['show']);
  }

  void addCanvas(CanvasElement newCanvas) {
    var canvasDiv = querySelector("div.canvas");
    newCanvas
      ..id = "canvas"
      ..onMouseDown.listen(mouseDownCanvas);
    canvasDiv
      ..innerHtml = ""
      ..append(newCanvas);
    this.canvas = new Canvas(newCanvas);
  }

  void createImage({num width, num height}) {
    if (width == null || height == null) {
      // open image file
      openImage((CanvasElement canvas) {
        addCanvas(canvas);
      });
    } else {
      // create new empty image
      addCanvas(new CanvasElement(width: width, height: height));
    }
  }

  void openImage(Function callback(CanvasElement canvas)) {
    InputElement input = document.createElement('input');
    input.accept = 'image/x-png,image/gif,image/jpeg';
    input.type = 'file';
    input.addEventListener('change', (event) {
      var file = input.files.first;
      var img = new ImageElement();
      img.addEventListener('load', (event) {
        var canvas = new CanvasElement(width: img.width, height: img.height);
        var context = canvas.context2D;
        context.drawImage(img, 0, 0);
        callback(canvas);
      });
      img.src = Url.createObjectUrl(file);
    });
    input.click();
  }

  void saveImage() {
    CanvasElement canvas = querySelector("#canvas");
    AnchorElement a = querySelector("#saveImage");
    a.href = canvas.toDataUrl();
  }

  void setTool(String tool) {
    querySelector('#text-tool').classes.add('hidden');
    querySelector('#mark-tool').classes.add('hidden');
    activeTool = tool;
  }

  void mouseDownCanvas(MouseEvent event) {
    if (isToolShown) {
      return;
    }
    isMouseDown = true;
    mousePosition = getMousePositionOnCanvas(event);
    switch (activeTool) {

      case 'pen':
        canvas.penStart(mousePosition, penSize, color);
        break;

      case 'pipette':
        color = canvas.pipette(mousePosition);
        break;

      case 'text':
        var textTool = querySelector('#text-tool');
        (textTool.querySelector('input[name="text"]') as InputElement).value = '';
        textTool.style
          ..left = '${event.client.x - 1}px'
          ..top = '${event.client.y - 1}px';
        textTool
          ..classes.remove('hidden')
          ..querySelector('input[name="text"]').focus();
        isToolShown = true;
        break;

      case 'mark':
        markMouseDownCanvas(event);
        break;

      case 'rubber':
        canvas.rubberStart(mousePosition, penSize);
        break;
    }
  }

  void markMouseDownCanvas(MouseEvent event) {
    var markTool = querySelector('#mark-tool');
    if (markTool.classes.contains('hidden')) {
      // start new marker
      markPositionStart = event.client;
      markTool.style
        ..left = '${markPositionStart.x}px'
        ..top = '${markPositionStart.y}px'
        ..width = '0'
        ..height = '0';
      markRect = new Rectangle(0, 0, 0, 0);
      markTool.classes.remove('hidden');
    } else {
      // clear marker
      markTool.classes.add('hidden');
    }
  }

  void mouseUpCanvas(MouseEvent event) {
    isMouseDown = false;
  }

  void mouseMoveCanvas(MouseEvent event) {
    if (isToolShown) {
      return;
    }
    if (isMouseDown) {
      mousePosition = getMousePositionOnCanvas(event);
      switch (activeTool) {

        case 'pen':
          canvas.penMove(mousePosition);
          break;

        case 'pipette':
          color = canvas.pipette(mousePosition);
          break;

        case 'mark':
          markSet(event);
          break;

        case 'rubber':
          canvas.rubberMove(mousePosition);
          break;
      }
    }
  }

  void markSet(MouseEvent event) {
    var markTool = querySelector('#mark-tool');
    if (markTool.classes.contains('hidden')) {
      return;
    }

    var left = 0;
    var top = 0;
    var width = 0;
    var height = 0;

    // set border limits for marker
    if (event.client.x < markPositionStart.x) {
      if (event.client.x < canvas.canvas.documentOffset.x) {
        left = canvas.canvas.documentOffset.x;
        width = markPositionStart.x - canvas.canvas.documentOffset.x;
      } else {
        left = event.client.x;
        width = markPositionStart.x - event.client.x;
      }
    } else {
      if (event.client.x > canvas.canvas.documentOffset.x + canvas.canvas.offsetWidth) {
        left = markPositionStart.x;
        width = canvas.canvas.documentOffset.x + canvas.canvas.offsetWidth - markPositionStart.x;
      } else {
        left = markPositionStart.x;
        width = event.client.x - markPositionStart.x;
      }
    }
    if (event.client.y < markPositionStart.y) {
      if (event.client.y < canvas.canvas.documentOffset.y) {
        top = canvas.canvas.documentOffset.y;
        height = markPositionStart.y - canvas.canvas.documentOffset.y;
      } else {
        top = event.client.y;
        height = markPositionStart.y - event.client.y;
      }
    } else {
      if (event.client.y > canvas.canvas.documentOffset.y + canvas.canvas.offsetHeight) {
        top = markPositionStart.y;
        height = canvas.canvas.documentOffset.y + canvas.canvas.offsetHeight - markPositionStart.y;
      } else {
        top = markPositionStart.y;
        height = event.client.y - markPositionStart.y;
      }
    }

    // visual marker position
    markTool.style
      ..left = '${left}px'
      ..top = '${top}px'
      ..width = '${width}px'
      ..height = '${height}px';

    // rect
    markRect = new Rectangle(
      markTool.documentOffset.x - canvas.canvas.documentOffset.x,
      markTool.documentOffset.y - canvas.canvas.documentOffset.y,
      markTool.offsetWidth,
      markTool.offsetHeight
    );
  }

  Point getMousePositionOnCanvas(MouseEvent event) {
    return new Point(
        event.client.x - canvas.canvas.documentOffset.x,
        event.client.y - canvas.canvas.documentOffset.y
    );
  }

  void textInsert() {
    var textTool = querySelector('#text-tool');
    textTool.classes.add('hidden');
    var text = (textTool.querySelector('input[name="text"]') as InputElement).value;
    canvas.textInsert(text, mousePosition, font, fontStyle, fontWeight, color, fontSize);
    isToolShown = false;
  }
  void textCancel() {
    var textTool = querySelector('#text-tool');
    textTool.classes.add('hidden');
    isToolShown = false;
  }

  void onTextChange() {
    InputElement input = querySelector('#text-tool input[name="text"]');
    int width = canvas.measureString(input.value, font, fontStyle, fontWeight, fontSize).ceil();
    input.style.minWidth = width.toString() + 'px';
  }

  void setFont(String font) {
    this.font = font;
    onTextChange();
  }
  void setFontSize(String size) {
    fontSize = int.parse(size, radix: 10);
    onTextChange();
  }
  void setFontStyle() {
    var italicButton = querySelector('.font-style button.italic');
    italicButton.classes.toggle('active');
    fontStyle = italicButton.classes.contains('active') ? 'italic' : '';
    onTextChange();
  }
  void setFontWeight() {
    var boldButton = querySelector('.font-style button.bold');
    boldButton.classes.toggle('active');
    fontWeight = boldButton.classes.contains('active') ? 'bold' : '';
    onTextChange();
  }

  Rectangle getMark() {
    var markTool = querySelector('#mark-tool');
    if (markTool.classes.contains('hidden')) {
      // no mark, use whole canvas
      return new Rectangle(
          0,
          0,
          canvas.canvas.offsetWidth,
          canvas.canvas.offsetHeight
      );
    }
    // marked area
    return new Rectangle(
      markTool.documentOffset.x - canvas.canvas.documentOffset.x,
      markTool.documentOffset.y - canvas.canvas.documentOffset.y,
      markTool.offsetWidth,
      markTool.offsetHeight
    );
  }

  void fill() {
    var rect = getMark();
    canvas.fill(rect, color);
  }

  void filter(String filterName, [Map options]) {

    if (options == null || !(options is Map)) {
      options = new Map();
    }

    var rect = getMark();
    var modalSelector = '#filter-${filterName}-modal';
    var modal = querySelector(modalSelector);

    if (modal != null) {
      context
          .callMethod(r'$', [modalSelector])
          .callMethod('modal', [new JsObject.jsify({
            'onApprove': new JsFunction.withThis((element){

              var inputs = querySelectorAll('${modalSelector} form input');

              for (InputElement input in inputs) {
                options[input.name] = input.value;
              }

              filterRun(filterName, rect, options);

            })
          })])
          .callMethod('modal', ['show']);
    } else {
      filterRun(filterName, rect, options);
    }

  }

  void filterRun(String filterName, [Rectangle rect, Map options]) {
    try {
      canvas.filter(rect, filterName, options);
    } catch (ex) {
      window.alert('Could not apply filter.');
      throw ex;
    }
  }

  void delete() {
    var rect = getMark();
    canvas.delete(rect);
  }

}
