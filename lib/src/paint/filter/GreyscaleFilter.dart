import 'dart:html';
import 'dart:math';

import 'AbstractFilter.dart';

class GreyscaleFilter extends AbstractFilter {

  GreyscaleFilter(CanvasRenderingContext2D ctx) : super(ctx);

  @override
  void use(Rectangle rect, {Object options}) {
    var imgData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
    var pixels = imgData.data;
    for (var i = 0, n = pixels.length; i < n; i += 4) {
      int grayscale = (pixels[i] * .3 + pixels[i + 1] * .59 + pixels[i + 2] * .11).round();
      pixels[i] = pixels[i + 1] = pixels[i + 2] = grayscale;
    }
    //redraw the image in black & white
    ctx.putImageData(imgData, rect.left, rect.top);
  }

}
