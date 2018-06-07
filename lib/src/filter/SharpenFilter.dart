import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/AbstractFilter.dart';
import 'package:paint/src/filter/ConvoluteFilter.dart';

class SharpenFilter extends AbstractFilter {

  SharpenFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {
    ConvoluteFilter filter = new ConvoluteFilter(canvas);
    options['matrix'] = [
      [0, -2, 0],
      [-2, 11, -2],
      [0, -2, 0]
    ];
    filter.use(rect, options);
  }

}
