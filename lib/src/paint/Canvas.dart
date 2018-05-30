import 'dart:html';

class Canvas {

  CanvasElement canvas;
  CanvasRenderingContext2D ctx;

  Canvas(CanvasElement canvas) {
    this.canvas = canvas;
    this.ctx = canvas.context2D;
  }

  void DrawPen(int x, int y, int size) {
    //TODO draw pen
  }
}
