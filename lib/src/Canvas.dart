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

/**
 * Canvas drawing engine
 */
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

  /**
   * Start drawing with pen
   */
  void penStart(Point position, int penSize, Color color) {
    _mouseLastPosition = position;
    _penSize = penSize;
    _color = color;
    penMove(position);
  }

  /**
   * Draw a pen line from start to position
   */
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

  /**
   * Draw a text
   */
  void textInsert(String text, Point position, String font, String style, String weight, Color color, int size) {
    ctx
      ..textBaseline = 'top'
      ..font = '${style} ${weight} ${size}px ${font}'
      ..fillStyle = color.toRgba()
      ..fillText(text, position.x, position.y);
  }

  /**
   * Get text length
   */
  double measureString(String text, String font, String style, String weight, int size) {
    ctx.font = '${style} ${weight} ${size}px ${font}';
    return ctx.measureText(text).width;
  }

  /**
   * Start the rubber
   */
  void rubberStart(Point position, int penSize) {
    _mouseLastPosition = position;
    _penSize = penSize;
    rubberMove(position);
  }

  /**
   * Delete from rubber start to position in a line
   */
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

  /**
   * Draw a gradient
   */
  void gradient(List<Point> points, List colors, Rectangle rect) {
    var gradient = ctx.createLinearGradient(points[0].x, points[0].y, points[1].x, points[1].y);
    for (var color in colors) {
      gradient.addColorStop(color['position'], color['color']);
    }
    ctx.fillStyle = gradient;
    ctx.fillRect(rect.left, rect.top, rect.width, rect.height);
  }

  /**
   * Place a image on the canvas
   */
  void importImage(ImageElement image, Rectangle rect) {
    ctx.drawImageScaled(image, rect.left, rect.top, rect.width, rect.height);
  }

  /**
   * Delete a rectangle
   */
  void delete(Rectangle rect) {
    ctx.clearRect(rect.left, rect.top, rect.width, rect.height);
  }

  /**
   * Fill a rectangle
   */
  void fillRect(Rectangle rect, Color color) {
    ctx
      ..fillStyle = color.toRgba()
      ..fillRect(rect.left, rect.top, rect.width, rect.height);
  }

  /**
   * Fill all pixels around a position having the same color
   */
  void fill(Point position, Color color, int tolerance, Rectangle rect) {

    var imgData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
    var points = [position];
    Point point;
    var seen = new Map<String, bool>();
    var steps = [[1, 0], [0, 1], [0, -1], [-1, 0]];
    String key;
    int index;
    int i;
    int x2;
    int y2;

    tolerance = tolerance.abs();

    // color of the selected pixel
    index = 4 * (position.y * rect.width + position.x);
    Color targetColor = new Color(
        imgData.data[index],
        imgData.data[index + 1],
        imgData.data[index + 2],
        imgData.data[index + 3]
    );

    // walk over all pixels in queue
    while(points.length > 0) {

      point = points.removeLast();
      index = 4 * (point.y * rect.width + point.x);

      // compare pixels. skip this pixel if not equal
      if((imgData.data[index] - targetColor.r).abs() > tolerance
          || (imgData.data[index + 1] - targetColor.g).abs() > tolerance
          || (imgData.data[index + 2] - targetColor.b).abs() > tolerance
          || (imgData.data[index + 3] - targetColor.a).abs() > tolerance
      ) {
        continue;
      }

      // Look to each side of the pixel
      i = steps.length;
      while(i-- > 0) {

        // fill the current pixel
        imgData.data[index] = color.r;
        imgData.data[index + 1] = color.g;
        imgData.data[index + 2] = color.b;
        imgData.data[index + 3] = color.a;

        // next pixel
        x2 = point.x + steps[i][0];
        y2 = point.y + steps[i][1];
        key = '${x2},${y2}';

        // if new pixel in range and not already checked, add to list
        if(x2 < 0 || y2 < 0 || x2 >= rect.width || y2 >= rect.height || seen.containsKey(key) && seen[key]) {
          continue;
        }
        points.add(new Point(x2, y2 ));

        // current pixel is done
        seen[key] = true;
      }
    }

    ctx.putImageData(imgData, rect.left, rect.top);
  }

  /**
   * Use a filter
   */
  void filter(Rectangle rect, String filterName, [Object options]) {
    var filter = getFilter(filterName);
    filter.use(rect, options);
  }

  /**
   * Filter generator (something like a factory)
   */
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

  /**
   * Get color on position
   */
  Color pipette(Point position) {
    var pixel = ctx.getImageData(position.x, position.y, 1, 1).data;
    return new Color(pixel[0], pixel[1], pixel[2], pixel[3]);
  }

}
