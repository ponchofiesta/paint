import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/AbstractFilter.dart';
import 'package:paint/src/filter/ConvoluteFilter.dart';

class BlurFilter extends AbstractFilter {

  BlurFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {
    ConvoluteFilter filter = new ConvoluteFilter(canvas);
    options['matrix'] = [
      [1, 2, 1],
      [2, 8, 2],
      [1, 2, 1]
    ];
    filter.use(rect, options);
  }

}
