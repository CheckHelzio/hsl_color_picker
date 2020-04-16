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
                print(colorSelected);
                setState(() {
                  hslColor = colorSelected;
                  color = colorSelected.toColor();
                });
              },
              size: 200,
              strokeWidth: 5,
              thumbSize: 9,
              thumbStrokeSize: 3,
              showCenterColorIndicator: true,
              centerColorIndicatorSize: 80,
              initialColor: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
