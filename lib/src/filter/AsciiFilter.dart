import 'dart:html';
import 'dart:math';

import 'package:paint/src/Color.dart';
import 'package:paint/src/filter/AbstractFilter.dart';

class AsciiFilter extends AbstractFilter {

  AsciiFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {

    checkRequiredOptions(options, ['size']);
    var size = options['size'];

    var imgData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
    var pixels = imgData.data;

    for (var y = 0; y < rect.height; y += size) {
      for (var x = 0; x < rect.width; x += size) {

        var cellColor = new Color(0, 0, 0, 0);

        // sum all pixels in this cell
        for (var y2 = 0; y2 < size && y + y2 < rect.height; y2++) {
          for (var x2 = 0; x2 < size && x + x2 < rect.width; x2++) {
            var index = ((y + y2) * rect.width + x + x2) * 4;
            if (index >= 0 && index < pixels.length) {
              cellColor.r += pixels[index];
              cellColor.g += pixels[index + 1];
              cellColor.b += pixels[index + 2];
              cellColor.a += pixels[index + 3];
            }
          }
        }

        // get average and greyscale color for cell
        cellColor.r = (cellColor.r / (size * size)).round();
        cellColor.g = (cellColor.g / (size * size)).round();
        cellColor.b = (cellColor.b / (size * size)).round();
        cellColor.a = (cellColor.a / (size * size)).round();

        // greyscale cell color
        int greyscale = (cellColor.r * .2126 + cellColor.g * .7152 + cellColor.b * .0722).round();

        // set ascii char for cell illuminance
        var char = '';
        if (greyscale > 50) char = '#';
        if (greyscale > 71) char = '@';
        if (greyscale > 92) char = '8';
        if (greyscale > 118) char = '&';
        if (greyscale > 130) char = 'o';
        if (greyscale > 163) char = '*';
        if (greyscale > 184) char = ':';
        if (greyscale > 205) char = '.';

        // fill cell
        ctx
          ..fillStyle = new Color(255, 255, 255, cellColor.a).toRgba()
          ..fillRect(x, y, size, size);

        // draw char
        ctx
          ..textBaseline = 'top'
          ..font = '${size}px monospace'
          ..fillStyle = new Color(cellColor.r, cellColor.g, cellColor.b, 255).toRgba()
          ..fillText(char, x, y);

      }
    }

  }

  int getRand(int x, int y) {
    return (new Random().nextDouble() * y).floor() + x;
  }

}
