import 'dart:html';
import 'dart:math';

import 'package:paint/src/Color.dart';
import 'package:paint/src/filter/AbstractFilter.dart';
import 'package:paint/src/filter/AsciiFilter.dart';
import 'package:paint/src/filter/BlurFilter.dart';
import 'package:paint/src/filter/BrightenFilter.dart';
import 'package:paint/src/filter/EmbossFilter.dart';
import 'package:paint/src/filter/GreyscaleFilter.dart';
import 'package:paint/src/filter/PixelateFilter.dart';
import 'package:paint/src/filter/SharpenFilter.dart';

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

  void fillRect(Rectangle rect, Color color) {
    ctx
      ..fillStyle = color.toRgba()
      ..fillRect(rect.left, rect.top, rect.width, rect.height);
  }

  void fill(Point position, Rectangle rect) {

    var newPos,
        x,
        y,
        pixelPos,
        reachLeft,
        reachRight,
        drawingBoundLeft = rect.left,
        drawingBoundTop = rect.top,
        drawingBoundRight = rect.left + rect.width - 1,
        drawingBoundBottom = rect.top + rect.height - 1,
        pixelStack = [[position.x, position.y]];

    while (pixelStack.length > 0) {

      newPos = pixelStack.removeAt(0);
      x = newPos[0];
      y = newPos[1];

      // Get current pixel position
      pixelPos = (y * rect.width + x) * 4;

      // Go up as long as the color matches and are inside the canvas
      while (y >= drawingBoundTop && matchStartColor(pixelPos, startR, startG, startB)) {
        y -= 1;
        pixelPos -= rect.width * 4;
      }

      pixelPos += canvasWidth * 4;
      y += 1;
      reachLeft = false;
      reachRight = false;

      // Go down as long as the color matches and in inside the canvas
      while (y <= drawingBoundBottom && matchStartColor(pixelPos, startR, startG, startB)) {
        y += 1;

        colorPixel(pixelPos, curColor.r, curColor.g, curColor.b);

        if (x > drawingBoundLeft) {
          if (matchStartColor(pixelPos - 4, startR, startG, startB)) {
            if (!reachLeft) {
              // Add pixel to stack
              pixelStack.push([x - 1, y]);
              reachLeft = true;
            }
          } else if (reachLeft) {
            reachLeft = false;
          }
        }

        if (x < drawingBoundRight) {
          if (matchStartColor(pixelPos + 4, startR, startG, startB)) {
            if (!reachRight) {
              // Add pixel to stack
              pixelStack.push([x + 1, y]);
              reachRight = true;
            }
          } else if (reachRight) {
            reachRight = false;
          }
        }

        pixelPos += rect.width * 4;
      }
    }
  }

  void filter(Rectangle rect, String filterName, [Object options]) {
    var filter = getFilter(filterName);
    filter.use(rect, options);
  }

  AbstractFilter getFilter(String filterName) {
    switch (filterName) {
      case 'greyscale':
        return new GreyscaleFilter(canvas);
      case 'emboss':
        return new EmbossFilter(canvas);
      case 'ascii':
        return new AsciiFilter(canvas);
      case 'pixelate':
        return new PixelateFilter(canvas);
      case 'blur':
        return new BlurFilter(canvas);
      case 'sharpen':
        return new SharpenFilter(canvas);
      case 'brightness':
        return new BrightenFilter(canvas);
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

  void gradient(List<Point> points, List colors, Rectangle rect) {
    var gradient = ctx.createLinearGradient(points[0].x, points[0].y, points[1].x, points[1].y);
    for (var color in colors) {
      gradient.addColorStop(color['position'], color['color']);
    }
    ctx.fillStyle = gradient;
    ctx.fillRect(rect.left, rect.top, rect.width, rect.height);
  }

  void importImage(ImageElement image, Rectangle rect) {
    ctx.drawImageScaled(image, rect.left, rect.top, rect.width, rect.height);
  }

}
