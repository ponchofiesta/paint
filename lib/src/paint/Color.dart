class Color {

  int r;
  int g;
  int b;
  int a;

  Color(this.r, this.g, this.b, this.a);

  String toRgba() {
    return 'rgba(${r},${g},${b},${a})';
  }

  String get hex {
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

  set hex(String hex) {
    String hexr;
    String hexg;
    String hexb;
    if (hex.length == 4) {
      hexr = hex[1] + hex[1];
      hexg = hex[2] + hex[2];
      hexb = hex[3] + hex[3];
    } else if (hex.length == 7) {
      hexr = hex.substring(1, 2) + hex.substring(1, 2);
      hexg = hex.substring(3, 4) + hex.substring(3, 4);
      hexb = hex.substring(5, 6) + hex.substring(5, 6);
    } else {
      return;
    }
    r = int.parse(hexr, radix: 16);
    g = int.parse(hexg, radix: 16);
    b = int.parse(hexb, radix: 16);
    a = 255;
  }

}
