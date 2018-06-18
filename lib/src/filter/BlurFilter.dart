import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/ConvoluteFilter.dart';

class BlurFilter extends ConvoluteFilter {

  BlurFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {
    options['matrix'] = [
      [1, 2, 1],
      [2, 8, 2],
      [1, 2, 1]
    ];
    super.use(rect, options);
  }

}
