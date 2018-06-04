import 'dart:html';
import 'dart:math';

abstract class AbstractFilter {

  CanvasRenderingContext2D ctx;

  AbstractFilter(this.ctx);

  void use(Rectangle rect, {Object options}) {}
}
