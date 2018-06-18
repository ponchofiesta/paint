import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/ConvoluteFilter.dart';

class SharpenFilter extends ConvoluteFilter {

  SharpenFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {
    options['matrix'] = [
      [0, -2, 0],
      [-2, 11, -2],
      [0, -2, 0]
    ];
    super.use(rect, options);
  }

}
