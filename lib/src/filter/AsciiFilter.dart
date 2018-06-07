import 'dart:html';
import 'dart:math';

import 'package:paint/src/Color.dart';
import 'package:paint/src/filter/AbstractFilter.dart';

class AsciiFilter extends AbstractFilter {

  AsciiFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Object options]) {

    var size = 20;
    if (options != null && options is Map && options.containsKey('size')) {
      size = int.parse(options['size'], radix: 10);
    } else {
      window.console.log('AsciiFilter: using default size of ${size}');
    }

    var imgData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
    var pixels = imgData.data;

    var iMode = 1;
    var iCDif = 80;

    int r0, r1, r2, r3, r4, r5, r6;

    for (var y = 0; y < rect.height; y += size){
      for (var x = 0; x < rect.width; x += size){
        // different modes
        if (iMode == 1) {
          r0 = (55 + new Random().nextDouble() * 200).floor();
          r1 = r2 = r3 = r4 = r5 = r6 = 0;
        } else if (iMode == 2) {
          r0 = 255;
          r1 = r3 = r5 = getRand(-iCDif, iCDif * 2);
          r2 = r4 = r6 = getRand(0, iCDif);
        } else if (iMode == 3) {
          r0 = 255;
          r1 = getRand(-iCDif, iCDif * 2);
          r2 = getRand(0, iCDif);
          r3 = getRand(-iCDif, iCDif * 2);
          r4 = getRand(0, iCDif);
          r5 = getRand(-iCDif, iCDif * 2);
          r6 = getRand(0, iCDif);
        }
        for (var y2 = 0; y2 < size; y2++){
          for (var x2 = 0; x2 < size; x2++){
            var i = ((y + y2) * rect.width + x + x2) * 4;
            if (i >= 0 && i < pixels.length) {
              pixels[i] = pixels[i] - r1 + r2;
              pixels[i+1] = pixels[i+1] - r3 + r4;
              pixels[i+2] = pixels[i+2] - r5 + r6;
              pixels[i+3] = r0;
            }
          }
        }
      }
    }

//    var yCellMax = (rect.height / size).floor() + 1;
//    var xCellMax = (rect.width / size).floor() + 1;
//
//    var cellColors = new List.generate(yCellMax, (_) => new List.generate(xCellMax, (__) => new Color(0, 0, 0, 0)));
//    var cellNumPixels = new List.generate(yCellMax, (_) => new List.generate(xCellMax, (__) => 0));
//
//    window.console.log('cellColors: ${cellColors.length},${cellColors[0].length}');
//
//    for (var i = 0; i < pixels.length; i += 4) {
//
//      var y = ((i / 4) / rect.width).floor();
//      var x = (i / 4) % rect.width;
//
//      var yCell = (y / size).floor();
//      var xCell = (x / size).floor();
//
//      //window.console.log('yCell=${yCell}, xCell=${xCell}');
//
//      cellColors[yCell][xCell].r += pixels[i];
//      cellColors[yCell][xCell].g += pixels[i + 1];
//      cellColors[yCell][xCell].b += pixels[i + 2];
//      cellColors[yCell][xCell].a += pixels[i + 3];
//      cellNumPixels[yCell][xCell]++;
//    }
//
//    for (var y = 0; y < cellColors.length; y++) {
//      for (var x = 0; x < cellColors[y].length; x++) {
//        cellColors[y][x].r = (cellColors[y][x].r / cellNumPixels[y][x]).floor();
//        cellColors[y][x].g = (cellColors[y][x].g / cellNumPixels[y][x]).floor();
//        cellColors[y][x].b = (cellColors[y][x].b / cellNumPixels[y][x]).floor();
//        cellColors[y][x].a = (cellColors[y][x].a / cellNumPixels[y][x]).floor();
//        window.console.log('cellColor[${y}][${x}] = ${cellColors[y][x].toString()}');
//      }
//    }


//    var yMax = (rect.height / size).floor();
//    var xMax = (rect.width / size).floor();
//
//    for (var y = 0; y < yMax; y++) {
//      for (var x = 0; x < xMax; x++) {
//
//        var cellColor = new Color(0, 0, 0, 0);
//
//        var y2Max = y * size + size;
//        var x2Max = x * size + size;
//
//        for (var y2 = y * size; y2 < y2Max; y2++) {
//          for (var x2 = x * size; x2 < x2Max; x2++) {
//
//            var y3 = (y * size + y2);
//            var x3 = (x * size + x2);
//            var index = y3 * (x3 * 4) + (x3 * 4);
//
//            if (y == 0 && x == 0) {
//              pixels[index] = 255;
//              pixels[index + 1] = 255;
//              pixels[index + 2] = 255;
//              continue;
//            }
//
//            cellColor.r += pixels[index];
//            cellColor.g += pixels[index + 1];
//            cellColor.b += pixels[index + 2];
//            cellColor.a += pixels[index + 3];
//            //window.console.log('   ${x},${y}: r=${cellColor.r} g=${cellColor.g} b=${cellColor.b} a=${cellColor.a}');
//          }
//        }
//
//        cellColor.r = (cellColor.r / (size * size)).round();
//        cellColor.g = (cellColor.g / (size * size)).round();
//        cellColor.b = (cellColor.b / (size * size)).round();
//        cellColor.a = (cellColor.a / (size * size)).round();
//
//        window.console.log('${x},${y}: r=${cellColor.r} g=${cellColor.g} b=${cellColor.b} a=${cellColor.a}');
//
////        for (var y2 = y * size; y2 < y * size + size; y2++) {
////          for (var x2 = x * size; x2 < x * size + size; x2++) {
////            var index = ((y + y2) * size + (x + x2)) * 4;
////            if (y == 0 && x == 0) {
////              pixels[index] = 255;
////              pixels[index + 1] = 255;
////              pixels[index + 2] = 255;
////              continue;
////            }
////            pixels[index] = cellColor.r;
////            pixels[index + 1] = cellColor.g;
////            pixels[index + 2] = cellColor.b;
////            pixels[index + 3] = cellColor.a;
////          }
////        }
//
//      }
//    }

    ctx.putImageData(imgData, rect.left, rect.top);
  }

  int getRand(int x, int y) {
    return (new Random().nextDouble() * y).floor() + x;
  }

}
