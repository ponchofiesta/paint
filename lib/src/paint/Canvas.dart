import 'dart:html';
import 'dart:math';

import 'package:paint/src/paint/Color.dart';

class Canvas {

  CanvasElement canvas;
  CanvasRenderingContext2D ctx;

  Point _mouseLastPosition = new Point(0, 0);
  int _penSize = 10;
  Color _color = new Color(0, 0, 0, 255);

  Canvas(CanvasElement canvas) {
    this.canvas = canvas;
    this.ctx = canvas.context2D;
  }

  void penStart(Point position, int penSize, Color color) {
    _mouseLastPosition = position;
    _penSize = penSize;
    _color = color;
  }

  void penMove(Point position) {
    ctx
      ..beginPath()
      ..moveTo(_mouseLastPosition.x, _mouseLastPosition.y)
      ..lineTo(position.x, position.y)
      ..lineCap = 'round'
      ..lineWidth = _penSize
      ..strokeStyle = _color.toRgba()
      ..stroke();
    _mouseLastPosition = position;
  }

  Color pipette(Point position) {
    var pixel = ctx.getImageData(position.x, position.y, 1, 1).data;
    return new Color(pixel[0], pixel[1], pixel[2], pixel[3]);
  }
}
