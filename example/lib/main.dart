import 'package:flutter/material.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ColorPickerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ColorPickerPage extends StatefulWidget {
  @override
  _ColorPickerPageState createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  HSLColor hslColor = HSLColor.fromColor(Colors.blue);
  Color color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: color,
        title: Stack(
          children: <Widget>[
            Text(
              "HSL COLOR PICKER: ${"#" + color.toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")}",
              style: TextStyle(
                fontSize: 16,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1
                  ..color = Colors.grey,
              ),
            ),
            Text(
              "HSL COLOR PICKER: ${"#" + color.toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            HSLColorPicker(
              onChanged: (colorSelected) {
                setState(() {
                  hslColor = colorSelected;
                  color = colorSelected.toColor();
                });
              },
              size: 200,
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                "Hue:\n${hslColor.hue}",
                style: TextStyle(
                    color: HSLColor.fromAHSL(1, hslColor.hue, .5, .5).toColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                "Saturation:\n${hslColor.saturation}",
                style: TextStyle(
                    color: HSLColor.fromAHSL(
                            1, hslColor.hue, hslColor.saturation, .5)
                        .toColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Stack(
                children: <Widget>[
                  Text(
                    "Lightness:\n${hslColor.lightness}",
                    style: TextStyle(
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = .5
                          ..color = Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Lightness:\n${hslColor.lightness}",
                    style: TextStyle(
                        color: HSLColor.fromAHSL(
                                1, hslColor.hue, .5, hslColor.lightness)
                            .toColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
