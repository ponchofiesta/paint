import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/AbstractFilter.dart';

class GreyscaleFilter extends AbstractFilter {

  GreyscaleFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Object options]) {
    var imgData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
    var pixels = imgData.data;
    for (var i = 0, n = pixels.length; i < n; i += 4) {
      int grayscale = (pixels[i] * .2126 + pixels[i + 1] * .7152 + pixels[i + 2] * .0722).round();
      pixels[i] = pixels[i + 1] = pixels[i + 2] = grayscale;
    }
    ctx.putImageData(imgData, rect.left, rect.top);
  }

}
