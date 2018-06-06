import 'dart:html';
import 'dart:math';

import 'package:paint/src/Color.dart';
import 'package:paint/src/filter/AbstractFilter.dart';

class AsciiFilter extends AbstractFilter {

  AsciiFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Object options]) {

    // TODO AsciiFilter not ready

    var size = 10;
    if (options != null && options is Map && options.containsKey('size')) {
      size = int.parse(options['size'], radix: 10);
    } else {
      window.console.log('AsciiFilter: using default size of ${size}');
    }

    var imgData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
    var pixels = imgData.data;

    for (var y = 0; y < rect.height / size; y++) {
      for (var x = 0; x < rect.width / size; x++) {

        var cellColor = new Color(0, 0, 0, 0);

        for (var y2 = y * size; y2 < y * size + size; y2++) {
          for (var x2 = x * size; x2 < x * size + size; x2++) {
            var index = ((y + y2) * size + (x + x2)) * 4;
            cellColor.r += pixels[index];
            cellColor.g += pixels[index + 1];
            cellColor.b += pixels[index + 2];
            cellColor.a += pixels[index + 3];
            //window.console.log('   ${x},${y}: r=${cellColor.r} g=${cellColor.g} b=${cellColor.b} a=${cellColor.a}');
          }
        }

        cellColor.r = (cellColor.r / (size * size)).round();
        cellColor.g = (cellColor.g / (size * size)).round();
        cellColor.b = (cellColor.b / (size * size)).round();
        cellColor.a = (cellColor.a / (size * size)).round();

        window.console.log('${x},${y}: r=${cellColor.r} g=${cellColor.g} b=${cellColor.b} a=${cellColor.a}');

        for (var y2 = y * size; y2 < y * size + size; y2++) {
          for (var x2 = x * size; x2 < x * size + size; x2++) {
            var index = ((y + y2) * size + (x + x2)) * 4;
            pixels[index] = cellColor.r;
            pixels[index + 1] = cellColor.g;
            pixels[index + 2] = cellColor.b;
            pixels[index + 3] = cellColor.a;
          }
        }

      }
    }

    ctx.putImageData(imgData, rect.left, rect.top);
  }

}
