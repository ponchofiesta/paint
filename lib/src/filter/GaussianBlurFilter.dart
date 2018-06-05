import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/AbstractFilter.dart';

class GaussianBlurFilter extends AbstractFilter {

  GaussianBlurFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Object options]) {
    // TODO implement gaussian blur filter
    window.alert('not implemented');
  }

}
