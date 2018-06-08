import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/AbstractFilter.dart';

class ConvoluteFilter extends AbstractFilter {

  ConvoluteFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {

    checkRequiredOptions(options, ['matrix']);

    var matrix = options['matrix'] as List<List<int>>;

    int offset = 0;
    if (isOptionAvailable(options, 'offset')) {
      offset = options['offset'] as int;
    }

    List<int> matrixFlat = []
        ..addAll(matrix[0])
        ..addAll(matrix[1])
        ..addAll(matrix[2]);
    var divisor = matrixFlat.reduce((a, b) => (a + b));
    if (divisor == 0) {
      divisor = 1;
    }

    var oldData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
    var oldPixels = oldData.data;
    var newData = ctx.createImageData(oldData);
    var newPixels = newData.data;
    var result = 0;

    for (var i = 0; i < newPixels.length; i++) {
      if ((i + 1) % 4 == 0) {
        newPixels[i] = oldPixels[i];
        continue;
      }
      var iPicker = [
        i - rect.width * 4 - 4,
        i - rect.width * 4,
        i - rect.width * 4 + 4,
        i - 4,
        i,
        i + 4,
        i + rect.width * 4 - 4,
        i + rect.width * 4,
        i + rect.width * 4 + 4
      ];
      result = 0;
      for (var j = 0; j < iPicker.length; j++) {
        result += (iPicker[j] >= 0 && iPicker[j] < oldPixels.length ? oldPixels[iPicker[j]] : oldPixels[i]) * matrixFlat[j];
      }
      result = (result / divisor).floor();
      result += offset;
      newPixels[i] = result;
    }

    ctx.putImageData(newData, rect.left, rect.top);

  }

}
