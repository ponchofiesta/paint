import 'dart:html';
import 'dart:math';

import 'package:paint/src/filter/AbstractFilter.dart';

class PixelateFilter extends AbstractFilter {

  PixelateFilter(CanvasElement canvas) : super(canvas);

  @override
  void use(Rectangle rect, [Map options]) {

    checkRequiredOptions(options, ['size', 'mode']);
    var size = options['size'];
    var mode = options['mode'];

    if (mode == 'raster') {

      int width = (rect.width / size).round();
      int height = (rect.height / size).round();

      ctx.drawImageScaledFromSource(canvas, rect.left, rect.top, rect.width, rect.height, rect.left, rect.top, width, height);
      ctx.imageSmoothingEnabled = false;
      ctx.drawImageScaledFromSource(canvas, rect.left, rect.top, width, height, rect.left, rect.top, rect.width, rect.height);

    } else {

      var imgData = ctx.getImageData(rect.left, rect.top, rect.width, rect.height);
      var pixels = imgData.data;
      final diff = 80;
      int r0, r1, r2, r3, r4, r5, r6;

      for (var y = 0; y < rect.height; y += size){
        for (var x = 0; x < rect.width; x += size){

          switch (mode) {
            case 'transparent':
              r0 = (55 + new Random().nextDouble() * 200).floor();
              r1 = r2 = r3 = r4 = r5 = r6 = 0;
              break;
            case 'brightness':
              r0 = 255;
              r1 = r3 = r5 = random(-diff, diff * 2);
              r2 = r4 = r6 = random(0, diff);
              break;
            case 'color':
              r0 = 255;
              r1 = random(-diff, diff * 2);
              r2 = random(0, diff);
              r3 = random(-diff, diff * 2);
              r4 = random(0, diff);
              r5 = random(-diff, diff * 2);
              r6 = random(0, diff);
              break;
            default:
              throw 'No pixelate mode defined';
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

      ctx.putImageData(imgData, rect.left, rect.top);

    }
  }

  int random(int x, int y) {
    return (new Random().nextDouble() * y).floor() + x;
  }

}
