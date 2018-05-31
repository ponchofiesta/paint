import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:paint/src/paint/Color.dart';

//import 'paint_service.dart';
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
  //providers: const [PaintService],
)
class PaintComponent implements OnInit {
  //final PaintService paintService;

  Canvas canvas;

  int penSize = 10;
  String activeTool = 'mark';
  Color color = new Color(0, 0, 0, 255);
  Point mousePosition = new Point(0, 0);
  bool isMouseDown = false;

  String font = 'Arial';
  int fontSize = 12;
  String fontStyle = 'normal';


  //PaintComponent(this.paintService);

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
      ..onMouseEnter.listen(mouseOverCanvas)
      ..onMouseLeave.listen(mouseOverCanvas)
      ..onMouseDown.listen(mouseDownCanvas)
      ..onMouseUp.listen(mouseUpCanvas)
      ..onMouseMove.listen(mouseMoveCanvas);
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

  void mouseOverCanvas(MouseEvent event) {
    if (activeTool == 'pen') {
      // TODO show pen cursor
    }
  }

  void mouseDownCanvas(MouseEvent event) {
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
          ..left = '${event.client.x}px'
          ..top = '${event.client.y}px';
        textTool
          ..classes.remove('hidden')
          ..querySelector('input[name="text"]').focus();
        break;
    }
  }

  void mouseUpCanvas(MouseEvent event) {
    isMouseDown = false;
  }

  void mouseMoveCanvas(MouseEvent event) {
    if (isMouseDown) {
      mousePosition = getMousePositionOnCanvas(event);
      switch (activeTool) {
        case 'pen':
          canvas.penMove(mousePosition);
          break;
        case 'pipette':
          color = canvas.pipette(mousePosition);
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
    canvas.textInsert(text, mousePosition, font, 'italic', color, fontSize);
  }

  void textCancel() {
    var textTool = querySelector('#text-tool');
    textTool.classes.add('hidden');
  }

}
