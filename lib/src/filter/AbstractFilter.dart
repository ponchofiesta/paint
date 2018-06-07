import 'dart:html';
import 'dart:math';

abstract class AbstractFilter {

  CanvasElement canvas;
  CanvasRenderingContext2D ctx;

  AbstractFilter(this.canvas) {
    this.ctx = canvas.context2D;
  }

  void use(Rectangle rect, [Map options]) {}

  void checkRequiredOptions(Map options, List<String> required) {
    if (options == null || options is! Map) {
      throw new ArgumentError("Parameter options must be a Map");
    }
    for (var parameter in required) {
      if (!options.containsKey(parameter)) {
        throw "Required option ${parameter} not provided.";
      }
    }
  }

  bool isOptionAvailable(Map options, String optionName) {
    if (options == null || options is! Map) {
      throw new ArgumentError("Parameter options must be a Map");
    }
    return options.containsKey(optionName);
  }

}
