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

  bool isMouseDown = false;

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

    // tools: default color
    context
        .callMethod(r'$', ['.tools input[type="color"]'])
        .callMethod('val', ['#fff']);
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

  void setActiveTool(String tool) {
    activeTool = tool;
  }

  void setPenSize(int size) {
    penSize = size;
  }

  void mouseOverCanvas(MouseEvent event) {
    if (activeTool == 'pen') {
      // TODO show pen cursor
    }
  }


  void mouseDownCanvas(MouseEvent event) {
    isMouseDown = true;
    Point position = getMousePositionOnCanvas(event);
    switch (activeTool) {
      case 'pen':
        canvas.penStart(position, penSize, color);
        break;
      case 'pipette':
        color = canvas.pipette(position);
        break;
    }
  }

  void mouseUpCanvas(MouseEvent event) {
    isMouseDown = false;
  }

  void mouseMoveCanvas(MouseEvent event) {
    if (isMouseDown) {
      Point position = getMousePositionOnCanvas(event);
      switch (activeTool) {
        case 'pen':
          canvas.penMove(position);
          break;
        case 'pipette':
          color = canvas.pipette(position);
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

}
