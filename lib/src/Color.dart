class Color {

  int r;
  int g;
  int b;
  int a;

  Color(this.r, this.g, this.b, this.a);

  String toRgba() {
    return 'rgba(${r},${g},${b},${a})';
  }

  @override
  String toString() {
    return 'Color: ${r},${g},${b},${a}';
  }

  String get hex {
    return toHex();
  }

  set hex(String hex) {
    Color color = new Color.fromHex(hex);
    r = color.r;
    g = color.g;
    b = color.b;
    a = color.a;
  }

  factory Color.fromHex(String hex) {
    String hexr;
    String hexg;
    String hexb;
    if (hex.length == 4) {
      hexr = hex[1] * 2;
      hexg = hex[2] * 2;
      hexb = hex[3] * 2;
    } else if (hex.length == 7) {
      hexr = hex.substring(1, 3);
      hexg = hex.substring(3, 5);
      hexb = hex.substring(5, 7);
    } else {
      throw 'Hex format invalid';
    }
    var r = int.parse(hexr, radix: 16);
    var g = int.parse(hexg, radix: 16);
    var b = int.parse(hexb, radix: 16);
    var a = 255;
    return new Color(r, g, b, a);
  }

  String toHex() {
    String hexr = r.toRadixString(16);
    if (hexr.length == 1) {
      hexr = '0' + hexr;
    }
    String hexg = g.toRadixString(16);
    if (hexg.length == 1) {
      hexg = '0' + hexg;
    }
    String hexb = b.toRadixString(16);
    if (hexb.length == 1) {
      hexb = '0' + hexb;
    }
    return '#' + hexr + hexg + hexb;
  }

}
