import 'dart:html';
import 'dart:math';

abstract class AbstractFilter {

  CanvasElement canvas;
  CanvasRenderingContext2D ctx;

  AbstractFilter(this.canvas) {
    this.ctx = canvas.context2D;
  }

  void use(Rectangle rect, [Object options]) {}
}
