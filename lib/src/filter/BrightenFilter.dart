import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/AbstractFilter.dart';

class BrightenFilter extends AbstractFilter {

  BrightenFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {

    checkRequiredOptions(options, ['brightness']);
    var brightness = options['brightness'];

    var imgData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
    var pixels = imgData.data;
    for (var i = 0, n = pixels.length; i < n; i += 4) {
      pixels[i] += brightness;
      pixels[i + 1] += brightness;
      pixels[i + 2] += brightness;
    }
    ctx.putImageData(imgData, rect.left, rect.top);
  }

}
