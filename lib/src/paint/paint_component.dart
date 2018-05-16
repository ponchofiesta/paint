import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:js_proxy/js_proxy.dart';

import 'paint_service.dart';

@Component(
  selector: 'paint',
  encapsulation: ViewEncapsulation.None, // disable angular css classes
  styleUrls: const ['paint_component.css'],
  templateUrl: 'paint_component.html',
  directives: const [
    CORE_DIRECTIVES,
    const [NgClass]
  ],
  providers: const [PaintService],
)
class PaintComponent implements OnInit {
  final PaintService paintService;
  var $ = new JProxy.fromContext('jQuery');

  var penSize = 10;
  var activeTool = 'mark';
  var color = [255, 255, 255];

  PaintComponent(this.paintService);

  @override
  Future<Null> ngOnInit() async {

    // tools: pen popup
    $('.tools .pen').popup({
      'popup': $('.pen.popup'),
      'on': 'click',
      'hoverable': true,
      'position': 'right center'
    });

    // tools: default color
    //$('.tools input[type="color"]').val('#fff');
  }

  void newImage() {
    $('#new-image-modal').modal({
      'onApprove': (element){
        var form = $('#new-image-modal form');
        num width = form.find('input[name="width"]').val();
        num height = form.find('input[name="height"]').val();
        createImage(width, height);
      }
    }).modal("show");
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
    canvasDiv.append(newCanvas);
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

  void mouseOverCanvas(event) {
    window.console.log(event);
  }

}
