import 'package:flutter/material.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

class ColorPicker extends StatefulWidget {
  final Color mColor;
  final double anchura;
  final double altura;
  final double radioClip;

  const ColorPicker(
      {Key key, this.mColor, this.anchura, this.altura, this.radioClip})
      : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  HSLColor color;
  HSLColor colorHex;
  double luminosidad = 1;
  double luminosidadHex = 1;

  @override
  void initState() {
    color = HSLColor.fromColor(widget.mColor);
    colorHex = HSLColor.fromColor(widget.mColor);
    super.initState();
  }

  void onChanged(HSLColor color) {
    this.color = color;

    if (color.lightness > 0.8) {
      double variable = color.lightness - 0.8;
      luminosidad = 1 - (variable * 5);
    } else {
      luminosidad = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Center(
              child: Container(
                width: 230,
                height: 230,
                child: HSLColorPicker(
                  initialColor: Colors.blue,
                  onChanged: (value) {
                    super.setState(() {
                      this.onChanged(value);
                    });
                  },
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              height: 80,
              width: 80,
              child: Material(
                borderRadius: BorderRadius.circular(64),
                color: color.toColor(),
                child: Center(
                  child: Text(
                    "#" +
                        color
                            .toColor()
                            .toString()
                            .split("0x")[1]
                            .toUpperCase()
                            .replaceFirst("FF", "")
                            .replaceAll(")", ""),
                    style: TextStyle(
                        color: HSLColor.fromColor(Colors.grey)
                            .withLightness(luminosidad)
                            .toColor()),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int hexToInt(String hex) {
  int val = 0;
  int len = hex.length;
  for (int i = 0; i < len; i++) {
    int hexDigit = hex.codeUnitAt(i);
    if (hexDigit >= 48 && hexDigit <= 57) {
      val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 65 && hexDigit <= 70) {
      // A..F
      val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 97 && hexDigit <= 102) {
      // a..f
      val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
    } else {
      throw new FormatException("Invalid hexadecimal value");
    }
  }
  return val;
}
