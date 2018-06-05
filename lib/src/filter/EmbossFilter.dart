import 'dart:html';
import 'dart:math';

import 'package:paint/src/Color.dart';
import 'package:paint/src/filter/AbstractFilter.dart';

class EmbossFilter extends AbstractFilter {

  var strength = 0.5;
  // shifting matrix
  var matrix = [-2.0, -1.0, .0, -1.0, 1.0, 1.0, .0, 1.0, 2.0];

  EmbossFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Object options]) {
    // TODO Emboss not ready
    var imgData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
    var imageData = transformMatrix(imgData, canvas.width, canvas.height);
    ctx.putImageData(imageData, rect.left, rect.top);
  }

  ImageData transformMatrix(ImageData pixels, int width, int height) {
    // create a second canvas and context to keep temp results
    CanvasElement canvas2 = document.createElement('canvas');
    canvas2.width = width;
    canvas2.height = height;
    var ctx2 = canvas2.context2D;
    // draw image
    ctx2.drawImage(canvas, width , height);
    var buffImageData = ctx2.getImageData(0, 0, width, height);
    var data = pixels.data;
    var bufferedData = buffImageData.data;
    // normalize matrix
    matrix = normalizeMatrix(matrix);
    int matrixSize = sqrt(matrix.length).round();
    for (var i = 1; i < width - 1; i++) {
      for (var j = 1; j < height - 1; j++) {
        var sumR = .0;
        var sumG = .0;
        var sumB = .0;
        // loop through the matrix
        for (var h = 0; h < matrixSize; h++) {
          for (var w = 0; w < matrixSize; w++) {
            var r = convertCoordinates(i + h - 1, j + w - 1, width) << 2;
            // RGB for current pixel
            Color currentPixel = new Color(bufferedData[r], bufferedData[r + 1], bufferedData[r + 2], bufferedData[r + 3]);
            sumR += currentPixel.r * matrix[w + h * matrixSize];
            sumG += currentPixel.g * matrix[w + h * matrixSize];
            sumB += currentPixel.b * matrix[w + h * matrixSize];
          }
        }
        var rf = convertCoordinates(i, j, width) << 2;
        data[rf] = findColorDiff(strength, sumR, data[rf]);
        data[rf + 1] = findColorDiff(strength, sumG, data[rf + 1]);
        data[rf + 2] = findColorDiff(strength, sumB, data[rf + 2]);
      }
    }
    return pixels;
  }

  List<double> normalizeMatrix(List<double> matrix) {
    var j = .0;
    for (var i = 0; i < matrix.length; i++) {
      j += matrix[i];
    }
    for (var i = 0; i < matrix.length; i++) {
      matrix[i] /= j;
    }
    return matrix;
  }

  // convert x-y coordinates into pixel position
  int convertCoordinates(x, y, w) {
    return x + (y * w);
  }
  // find a specified distance between two colours
  int findColorDiff(double diff, double dest, int src) {
    return (diff * dest + (1 - diff) * src).round();
  }

}
