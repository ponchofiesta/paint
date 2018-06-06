import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/AbstractFilter.dart';

class PixelateFilter extends AbstractFilter {

  PixelateFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Object options]) {

    var size = 10;
    if (options != null && options is Map && options.containsKey('size')) {
      size = int.parse(options['size'], radix: 10);
    } else {
      window.console.log('PixelateFilter: using default size of ${size}');
    }

    int width = (rect.width / size).round();
    int height = (rect.height / size).round();

    ctx.drawImageScaledFromSource(canvas, rect.left, rect.top, rect.width, rect.height, rect.left, rect.top, width, height);
    ctx.imageSmoothingEnabled = false;
    ctx.drawImageScaledFromSource(canvas, rect.left, rect.top, width, height, rect.left, rect.top, rect.width, rect.height);

  }

}
