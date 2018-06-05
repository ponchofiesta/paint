import 'dart:html';
import 'dart:math';

import 'package:paint/src/Color.dart';
import 'package:paint/src/filter/AbstractFilter.dart';
import 'package:paint/src/filter/EmbossFilter.dart';
import 'package:paint/src/filter/GaussianBlurFilter.dart';
import 'package:paint/src/filter/GreyscaleFilter.dart';

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
    penMove(position);
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

  void textInsert(String text, Point position, String font, String style, String weight, Color color, int size) {
    ctx
      ..textBaseline = 'top'
      ..font = '${style} ${weight} ${size}px ${font}'
      ..fillStyle = color.toRgba()
      ..fillText(text, position.x, position.y);
  }

  double measureString(String text, String font, String style, String weight, int size) {
    ctx.font = '${style} ${weight} ${size}px ${font}';
    return ctx.measureText(text).width;
  }

  void fill(Rectangle rect, Color color) {
    ctx
      ..fillStyle = color.toRgba()
      ..fillRect(rect.left, rect.top, rect.width, rect.height);
  }

  void filter(Rectangle rect, String filterName, [Object options]) {
    var filter = getFilter(filterName);
    filter.use(rect, options);
  }

  AbstractFilter getFilter(String filterName) {
    switch (filterName) {
      case 'greyscale':
        return new GreyscaleFilter(canvas);
      case 'gaussianblur':
        return new GaussianBlurFilter(canvas);
      case 'emboss':
        return new EmbossFilter(canvas);
    }
    throw new Exception("Filter not found");
  }

  void delete(Rectangle rect) {
    ctx.clearRect(rect.left, rect.top, rect.width, rect.height);
  }

  void rubberStart(Point position, int penSize) {
    _mouseLastPosition = position;
    _penSize = penSize;
    rubberMove(position);
  }

  void rubberMove(Point position) {
    ctx
      ..save()
      ..beginPath()
      ..globalCompositeOperation = 'destination-out'
      ..moveTo(_mouseLastPosition.x, _mouseLastPosition.y)
      ..lineTo(position.x, position.y)
      ..lineCap = 'round'
      ..lineWidth = _penSize
      ..strokeStyle = '#000'
      ..stroke()
      ..restore();
    _mouseLastPosition = position;
  }

}
