import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:angular/angular.dart';

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
  List<int> color = [255, 255, 255];

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
            var form = querySelector('#new-image-modal form');
            num width = (form.querySelector('input[name="width"]') as InputElement).valueAsNumber;
            num height = (form.querySelector('input[name="height"]') as InputElement).valueAsNumber;
            createImage(width, height);
          })
        })])
        .callMethod('modal', ['show']);
  }

  void createImage(num width, num height) {
    Element canvasDiv = querySelector("div.canvas");
    CanvasElement newCanvas = new CanvasElement();
    newCanvas.width = width;
    newCanvas.height = height;
    newCanvas.id = "canvas";
    canvasDiv.innerHtml = "";
    newCanvas.onMouseEnter.listen(mouseOverCanvas);
    newCanvas.onMouseLeave.listen(mouseOverCanvas);
    newCanvas.onMouseDown.listen(mouseDownCanvas);
    newCanvas.onMouseUp.listen(mouseUpCanvas);
    newCanvas.onMouseMove.listen(mouseMoveCanvas);
    canvasDiv.append(newCanvas);
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
  }

  void mouseUpCanvas(MouseEvent event) {
    isMouseDown = false;
  }

  void mouseMoveCanvas(MouseEvent event) {
    if (isMouseDown) {
      switch (activeTool) {
        case 'pen':
          // TODO get mouse pos
          canvas.DrawPen();
          break;
      }
    }
  }

}
