import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/AbstractFilter.dart';
import 'package:paint/src/filter/ConvoluteFilter.dart';

class EmbossFilter extends AbstractFilter {

  EmbossFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {
    ConvoluteFilter filter = new ConvoluteFilter(canvas);
    options['matrix'] = [
      [2, 0, 0],
      [0, -1, 0],
      [0, 0, -1]
    ];
    options['offset'] = 127;
    filter.use(rect, options);
  }

}