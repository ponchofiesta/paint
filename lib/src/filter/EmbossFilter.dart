import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/ConvoluteFilter.dart';

class EmbossFilter extends ConvoluteFilter {

  EmbossFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {
    options['matrix'] = [
      [2, 0, 0],
      [0, -1, 0],
      [0, 0, -1]
    ];
    options['offset'] = 127;
    super.use(rect, options);
  }

}
