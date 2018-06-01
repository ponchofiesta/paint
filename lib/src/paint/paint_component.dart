import 'dart:core';
import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:paint/src/paint/Color.dart';

import 'Canvas.dart';

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
    createImage(480, 320);

    // tools: pen popup
    context
        .callMethod(r'$', ['.tools .pen'])
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
            createImage(width, height);
          })
        })])
        .callMethod('modal', ['show']);
  }

  void createImage(num width, num height) {
    Element canvasDiv = querySelector("div.canvas");
    CanvasElement newCanvas = new CanvasElement();
    newCanvas
      ..width = width
      ..height = height
      ..id = "canvas"
      ..onMouseDown.listen(mouseDownCanvas);
    canvasDiv
      ..innerHtml = ""
      ..append(newCanvas);
    this.canvas = new Canvas(newCanvas);
  }

  void saveImage() {
    CanvasElement canvas = querySelector("#canvas");
    AnchorElement a = querySelector("#saveImage");
    a.download = "image.png";
    a.href = canvas.toDataUrl();
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
        Element markTool = querySelector('#mark-tool');
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

        break;
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
          Element markTool = querySelector('#mark-tool');
          if (markTool.classes.contains('hidden')) {
            break;
          }
          if (mousePosition.x < markPositionStart.x) {
            markTool.style
              ..left = '${event.client.x}px'
              ..width = '${markPositionStart.x - event.client.x}px';
          } else {
            markTool.style
              ..left = '${markPositionStart.x}px'
              ..width = '${event.client.x - markPositionStart.x}px';
          }
          if (mousePosition.y < markPositionStart.y) {
            markTool.style
              ..top = '${event.client.y}px'
              ..height = '${markPositionStart.y - event.client.y}px';
          } else {
            markTool.style
              ..top = '${markPositionStart.y}px'
              ..height = '${event.client.y - markPositionStart.y}px';
          }
          markRect = new Rectangle(
            markTool.documentOffset.x - canvas.canvas.documentOffset.x,
            markTool.documentOffset.y - canvas.canvas.documentOffset.y,
            markTool.offsetWidth,
            markTool.offsetHeight
          );
          break;
      }
    }
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
    Element italicButton = querySelector('.font-style button.italic');
    italicButton.classes.toggle('active');
    fontStyle = italicButton.classes.contains('active') ? 'italic' : '';
    onTextChange();
  }
  void setFontWeight() {
    Element boldButton = querySelector('.font-style button.bold');
    boldButton.classes.toggle('active');
    fontWeight = boldButton.classes.contains('active') ? 'bold' : '';
    onTextChange();
  }

}
