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

  String activeTool = 'mark';
  int penSize = 10;
  int filterSize = 10;
  bool isToolShown = false;
  Color color = new Color(0, 0, 0, 255);
  Point mousePosition = new Point(0, 0);
  Point markPositionStart = new Point(0, 0);
  Rectangle markRect = new Rectangle(0, 0, 0, 0);
  bool isMouseDown = false;
  var gradientPoints = [new Point(0, 0), new Point(0, 0)];
  String font = 'Arial';
  num fontSize = 12;
  String fontStyle = '';
  String fontWeight = '';
  Point importMouseOffset;
  var gradientChooser; // JS Grapick: https://github.com/artf/grapick


  @override
  Future<Null> ngOnInit() async {

    // create empty image
    createImage(width: 480, height: 320);

    // tools: pen popup
    context
      .callMethod(r'$', ['.tools .button.pen'])
      .callMethod('popup', [new JsObject.jsify({
        'popup': context.callMethod(r'$', ['.pen.popup']),
        'on': 'click',
        'hoverable': true,
        'position': 'right center'
      })]);

    // tools: rubber popup
    context
      .callMethod(r'$', ['.tools .button.rubber'])
      .callMethod('popup', [new JsObject.jsify({
        'popup': context.callMethod(r'$', ['.pen.popup']),
        'on': 'click',
        'hoverable': true,
        'position': 'right center'
      })]);
    querySelector('.pen.popup').onMouseUp.forEach((element) => element);

    // tools: gradient popup
    context
      .callMethod(r'$', ['.tools .button.gradient'])
      .callMethod('popup', [new JsObject.jsify({
        'popup': context.callMethod(r'$', ['.gradient.popup']),
        'on': 'click',
        'hoverable': true,
        'position': 'right center'
      })]);

    // tools: text tool chooser
    context
      .callMethod(r'$', [':not(#main-menu) .ui.dropdown'])
      .callMethod('dropdown');

    // initialize menu dropdown
    context
      .callMethod(r'$', ['#main-menu .ui.dropdown'])
      .callMethod('dropdown', [new JsObject.jsify({
        'action': 'hide'
      })]);

    // initialize all checkboxes
    context
      .callMethod(r'$', ['.ui.checkbox'])
      .callMethod('checkbox');

    // initialize gradient chooser
    gradientChooser = new JsObject(context['Grapick'], [new JsObject.jsify({
      'el': '.tools .gradient.popup',
      'width': '200px'
    })])
      ..callMethod('addHandler', [0, '#ffffff'])
      ..callMethod('addHandler', [100, '#000000'])
      ..callMethod('on', ['change', new JsFunction.withThis(gradientUpdateIcon)]);
    gradientChooser.callMethod('emit', ['change']);

    // add input listeners
    querySelector('body')
      ..onMouseUp.listen(mouseUpCanvas)
      ..onMouseMove.listen(mouseMoveCanvas)
      ..onKeyPress.listen(keyPress);

  }

  /**
   * Switch the tool
   */
  void setTool(String tool) {
    if (tool != 'gradient') {
      querySelector('#mark-tool').classes.add('hidden');
    }
    querySelector('#text-tool').classes.add('hidden');
    querySelector('#import-tool').classes.add('hidden');
    activeTool = tool;
  }

  // Image creation and saving ---------------------------------------------

  /**
   * Show dialog for new image
   */
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

  /**
   * Place a canvas to the work area
   */
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

  /**
   * Create a new empty image by size or open one
   */
  void createImage({num width, num height}) {
    if (width == null || height == null) {
      // open image file
      openImage((ImageElement image) {
        image.addEventListener('load', (event) {
          var canvas = new CanvasElement(width: image.width, height: image.height);
          var context = canvas.context2D;
          context.drawImage(image, 0, 0);
          addCanvas(canvas);
        });
      });
    } else {
      // create new empty image
      addCanvas(new CanvasElement(width: width, height: height));
    }
  }

  /**
   * Open a image file
   */
  void openImage(Function callback(ImageElement image)) {
    InputElement input = document.createElement('input');
    input.accept = 'image/x-png,image/gif,image/jpeg';
    input.type = 'file';
    input.addEventListener('change', (event) {
      var file = input.files.first;
      var image = new ImageElement();
      image.src = Url.createObjectUrl(file);
      callback(image);
    });
    input.click();
  }

  /**
   * Save canvas to image file
   */
  void saveImage([Event event]) {
    if (event != null) {
      event.preventDefault();
    }
    CanvasElement canvas = querySelector("#canvas");
    context
      .callMethod(r'$', ['#save-image-modal'])
      .callMethod('modal', [new JsObject.jsify({
        'onApprove': new JsFunction.withThis((element){
          InputElement filetype = querySelector('#save-image-modal form input[name="filetype"]');
          InputElement quality = querySelector('#save-image-modal form input[name="quality"]');
          canvas.toBlob((blob) {
            AnchorElement a = document.createElement('a');
            a.classes.add('hidden');
            a.target = '_blank';
            a.href = Url.createObjectUrlFromBlob(blob);
            querySelector('body').append(a);
            a.click();
            a.remove();
          }, filetype.value, quality.valueAsNumber);
        })
      })])
      .callMethod('modal', ['show']);
  }

  // Import -------------------------------------------------------------

  /**
   * Import a image file and place it on top of the canvas
   */
  void importImage() {
    setTool('import');
    openImage((ImageElement image) {
      image.addEventListener('load', (event) {
        num limit = 200;
        int maxLength = max(image.width, image.height);
        num factor = limit / maxLength;
        var importTool = querySelector("#import-tool");
        if (factor < 1) {
          importTool.style
            ..left = '${canvas.canvas.documentOffset.x}px'
            ..top = '${canvas.canvas.documentOffset.y}px'
            ..width = '${image.width * factor}px'
            ..height = '${image.height * factor}px';
        }
        importTool
          ..append(image)
          ..classes.remove("hidden");
      });
    });
  }


  void importMouseDown(MouseEvent event) {
    event.preventDefault();
    var importTool = querySelector("#import-tool");
    importMouseOffset = new Point(event.client.x - importTool.documentOffset.x, event.client.y - importTool.documentOffset.y);
    isMouseDown = true;
  }

  void importMouseMove(MouseEvent event) {
    if (isMouseDown) {
      querySelector("#import-tool").style
        ..left = '${event.client.x - importMouseOffset.x}px'
        ..top = '${event.client.y - importMouseOffset.y}px';
    }
  }

  void importMouseWheel(WheelEvent event) {
    event.preventDefault();
    var importTool = querySelector("#import-tool");
    importTool.style
      ..left = '${importTool.documentOffset.x - event.deltaY / 2 * -.1}px'
      ..top = '${importTool.documentOffset.y - event.deltaY / 2 * -.1}px'
      ..width = '${importTool.offsetWidth + event.deltaY * -.1}px'
      ..height = '${importTool.offsetHeight + event.deltaY * -.1}px';
  }

  /**
   * Import: Insert the preview image to the canvas
   */
  void importInsert() {
    var importTool = querySelector('#import-tool');
    if (!importTool.classes.contains('hidden')) {
      var importImage = importTool.querySelector('img');
      var importRect = new Rectangle(
          importImage.documentOffset.x - canvas.canvas.documentOffset.x + 2,
          importImage.documentOffset.y - canvas.canvas.documentOffset.y + 2,
          importImage.offsetWidth,
          importImage.offsetHeight
      );
      canvas.importImage(importImage, importRect);
      importTool.classes.add('hidden');
      importImage.remove();
      return;
    }
  }

  // Mark tool ---------------------------------------------------------------

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

  // Main events --------------------------------------------------------------

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

      case 'fill':
        canvas.fill(mousePosition, color, 10, getMark());
        break;

      case 'gradient':
        var gradientTool = querySelector('#gradient-tool');
        if (gradientTool.classes.contains('hidden')) {
          // start new gradient
          gradientStart(mousePosition);
        } else {
          // clear gradient
          gradientTool.classes.add('hidden');
        }

        break;

      case 'import':
        importInsert();
        break;
    }
  }

  void mouseUpCanvas(MouseEvent event) {
    if (isMouseDown) {
      switch (activeTool) {
        case 'gradient':
          if (!querySelector('#gradient-tool').classes.contains('hidden')) {
            querySelector('#gradient-tool').classes.add('hidden');

            var values = gradientChooser.callMethod('getHandlers');

            var colors = [];
            for (var value in values) {
              colors.add({
                'position': value.callMethod('getPosition') / 100,
                'color': value.callMethod('getColor') as String
              });
            }

            canvas.gradient(gradientPoints, colors, getMark());
          }
          break;
      }
    }
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

        case 'gradient':
          gradientMove(mousePosition);
          break;
      }
    }
  }

  void keyPress(KeyboardEvent event) {
    switch (activeTool) {
      case 'import':
        if (event.keyCode == 13) {
          importInsert();
        }
        break;
    }
  }

  // Text tool ----------------------------------------------------------------

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

  // Fill area (rectangle) ----------------------------------------------------

  void fill() {
    var rect = getMark();
    canvas.fillRect(rect, color);
  }

  // Delete area (rectangle) --------------------------------------------------

  void delete() {
    var rect = getMark();
    canvas.delete(rect);
  }

  // Filters ------------------------------------------------------------------

  /**
   * Use a filter by name.
   */
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
                switch (input.type) {
                  case 'text':
                    options[input.name] = input.value;
                    break;
                  case 'number':
                    options[input.name] = input.valueAsNumber;
                    break;
                  case 'radio':
                    if (input.checked) {
                      options[input.name] = input.value;
                    }
                    break;
                }
              }

              filterRun(filterName, rect, options);

            })
          })])
          .callMethod('modal', ['show']);
    } else {
      filterRun(filterName, rect, options);
    }

  }

  /**
   * Run a specific filter
   */
  void filterRun(String filterName, [Rectangle rect, Map options]) {
    try {
      canvas.filter(rect, filterName, options);
    } catch (ex) {
      window.alert('Could not apply filter: ' + ex);
      throw ex;
    }
  }

  // Gradient tool -----------------------------------------------------------

  /**
   * Start a gradient on position
   */
  void gradientStart(Point position) {
    gradientPoints[0] = new Point(position.x, position.y);
    gradientMove(position);
    querySelector('#gradient-tool').classes.remove('hidden');
  }

  /**
   * Move second gradient point to position
   */
  void gradientMove(Point position) {
    gradientPoints[1] = new Point(position.x, position.y);

    var dx = gradientPoints[1].x - gradientPoints[0].x;
    var dy = gradientPoints[1].y - gradientPoints[0].y;
    var angle = atan2(dy, dx);
    angle *= 180 / pi;

    var length = sqrt(dx * dx + dy * dy);

    var left = gradientPoints[0].x + canvas.canvas.documentOffset.x;
    var top = gradientPoints[0].y + canvas.canvas.documentOffset.y;

    querySelector('#gradient-tool').style
      ..left = '${left}px'
      ..top = '${top}px'
      ..width = '${length}px'
      ..transform = 'rotate(${angle}deg)';
  }

  /**
   * Fill tool bar icon with the current gradient
   */
  gradientUpdateIcon() {
    var icon = querySelector('.tools>.gradient>i');
    icon.style.backgroundImage = gradientChooser.callMethod('getSafeValue');
  }


  // Helper -------------------------------------------------------------------

  /**
   * Get mouse position relative to canvas
   */
  Point getMousePositionOnCanvas(MouseEvent event) {
    return new Point(
        event.client.x - canvas.canvas.documentOffset.x,
        event.client.y - canvas.canvas.documentOffset.y
    );
  }

  /**
   * Get marked rectangle or the canvas rectangle
   */
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
}
