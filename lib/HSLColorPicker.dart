library hslcolorpicker;

import "dart:math" as Math;

import 'package:flutter/material.dart';

/// SIZE OF A SINGLE PIXEL ON THE SCREEN
double pixelSize;

class HSLColorPicker extends StatefulWidget {
  final Color initialColor;
  final double size;
  double strokeSize;
  double thumbSize;
  double thumbStrokeSize;
  bool showCenterColorIndicator;
  double centerColorIndicatorSize;
  final ValueChanged<HSLColor> onChanged;

  HSLColorPicker({
    Key key,
    @required this.onChanged,
    this.initialColor = Colors.red,
    this.size = 200,
    this.centerColorIndicatorSize,
    this.showCenterColorIndicator = true,
    this.strokeSize,
    this.thumbSize,
    this.thumbStrokeSize,
  })  : assert(onChanged != null),
        super(key: key);

  @override
  _HSLColorPickerState createState() => new _HSLColorPickerState();
}

class _HSLColorPickerState extends State<HSLColorPicker> {
  HSLColor color;
  final GlobalKey colorPickerKey = GlobalKey();

  /// Values
  double hue;
  double lightness;
  double saturation;

  /// Controls
  bool controles;
  bool controlSaturacion;

  @override
  void didChangeDependencies() {
    pixelSize = 1.0 / MediaQuery.of(context).devicePixelRatio;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    color = HSLColor.fromColor(widget.initialColor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    hue = color.hue;
    lightness = color.lightness;
    saturation = color.saturation;

    if (widget.strokeSize == null) {
      widget.strokeSize = widget.size * .027;
    }
    if (widget.thumbSize == null) {
      widget.thumbSize = widget.size * .043;
    }
    if (widget.thumbStrokeSize == null) {
      widget.thumbStrokeSize = widget.size * .015;
    }
    if (widget.centerColorIndicatorSize == null) {
      widget.centerColorIndicatorSize = widget.size / 2.6;
    }

    return GestureDetector(
      onPanStart: (details) => this.onPanStart(details.globalPosition),
      onPanUpdate: (details) => this.onPanUpdate(details.globalPosition),
      child: Container(
        key: this.colorPickerKey,
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: new _WheelPainter(
              color: this.color,
              strokeSize: widget.strokeSize,
              showCenterColorIndicator: widget.showCenterColorIndicator,
              thumbSize: widget.thumbSize,
              centerColorIndicatorSize: widget.centerColorIndicatorSize,
              thumbStrokeSize: widget.thumbStrokeSize),
        ),
      ),
    );
  }

  Offset getOffset(Offset ratio) {
    RenderBox renderBox = this.colorPickerKey.currentContext.findRenderObject();
    Offset startPosition = renderBox.localToGlobal(Offset.zero);
    return ratio - startPosition;
  }

  Size getSize() {
    RenderBox renderBox = this.colorPickerKey.currentContext.findRenderObject();
    return renderBox.size;
  }

  void onPanStart(Offset offset) {
    RenderBox renderBox = this.colorPickerKey.currentContext.findRenderObject();
    Size size = renderBox.size;

    Offset startPosition = renderBox.globalToLocal(offset);
    Offset center = Offset(size.width / 2, size.height / 2);

    Offset vector = startPosition - center;

    final maxRadioControles = _WheelPainter.radio(
            size, widget.strokeSize, widget.thumbSize, widget.thumbStrokeSize) -
        10;
    final hip = Math.sqrt(Math.pow(vector.dx, 2) + Math.pow(vector.dy, 2));

    if (hip < maxRadioControles) {
      controles = true;
      var gradosCircunferencia =
          Math.atan2(vector.dy, vector.dx) * 180 / Math.pi;

      if (gradosCircunferencia < 0) {
        gradosCircunferencia = 180 + 180 - gradosCircunferencia.abs();
      }

      controlSaturacion =
          (gradosCircunferencia > 90 && gradosCircunferencia < 270);
    } else {
      controles = false;
    }

    _actualizar(vector);
  }

  void onPanUpdate(Offset offset) {
    RenderBox renderBox = this.colorPickerKey.currentContext.findRenderObject();
    Size size = renderBox.size;

    Offset startPosition = renderBox.globalToLocal(offset);
    Offset center = Offset(size.width / 2, size.height / 2);

    Offset vector = startPosition - center;
    _actualizar(vector);
  }

  void _actualizar(Offset vector) {
    setState(() {
      var gradosCircunferencia =
          Math.atan2(vector.dy, vector.dx) * 180 / Math.pi;

      if (gradosCircunferencia < 0) {
        gradosCircunferencia = 180 + 180 - gradosCircunferencia.abs();
      }

      if (controles) {
        if (controlSaturacion) {
          if (gradosCircunferencia < 270 && gradosCircunferencia > 90) {
            var gradosSaturacion = gradosCircunferencia - 90;

            if (gradosSaturacion > 180 - _WheelPainter.apertura) {
              gradosSaturacion = 180 - _WheelPainter.apertura;
            }
            if (gradosSaturacion < _WheelPainter.apertura) {
              gradosSaturacion = _WheelPainter.apertura;
            }

            saturation = (1.0 /
                _WheelPainter.gradosArco *
                (gradosSaturacion - _WheelPainter.apertura));
          }
        } else {
          if (gradosCircunferencia > 270 || gradosCircunferencia < 90) {
            var gradosLuminosidad;
            if (gradosCircunferencia > 270) {
              gradosLuminosidad = gradosCircunferencia - 270;
            } else {
              gradosLuminosidad = gradosCircunferencia + 90;
            }

            if (gradosLuminosidad > 180 - _WheelPainter.apertura) {
              gradosLuminosidad = 180 - _WheelPainter.apertura;
            }
            if (gradosLuminosidad < _WheelPainter.apertura) {
              gradosLuminosidad = _WheelPainter.apertura;
            }

            lightness = (1.0 /
                _WheelPainter.gradosArco *
                (gradosLuminosidad - _WheelPainter.apertura));
          }
        }
      } else {
        hue = gradosCircunferencia;
      }

      color = HSLColor.fromAHSL(1, hue, saturation, lightness);
      super.widget.onChanged(HSLColor.fromAHSL(1, hue, saturation, lightness));
    });
  }
}

class Wheel {
  static Offset hueToVector(double h, double radio, Offset center) =>
      new Offset(
          Math.cos(h) * radio + center.dx, Math.sin(h) * radio + center.dy);
}

class _WheelPainter extends CustomPainter {
  static double radio(Size size, double strokeSize, double thumbSize,
          double thumbStrokeSize) =>
      Math.min(size.width, size.height).toDouble() / 2 -
      Math.max(strokeSize, thumbSize + (thumbStrokeSize / 2));

  final HSLColor color;
  final double strokeSize;
  final bool showCenterColorIndicator;
  final double thumbSize;
  final double thumbStrokeSize;
  final double centerColorIndicatorSize;

  static final apertura = 15.0;
  static final gradosArco = 180 - apertura * 2;
  static double space(Size size, double centerColorIndicatorSize,
          double strokeSize, double thumbSize, double thumbStrokeSize) =>
      (Math.min(size.width, size.height).toDouble() -
          centerColorIndicatorSize -
          Math.max(strokeSize, thumbSize + (thumbStrokeSize / 2))) /
      4;

  _WheelPainter({
    Key key,
    this.color,
    this.showCenterColorIndicator,
    this.centerColorIndicatorSize,
    this.strokeSize,
    this.thumbSize,
    this.thumbStrokeSize,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = new Offset(size.width / 2, size.height / 2);

    Offset centerOffset = Offset(0, 0);
    double radio =
        _WheelPainter.radio(size, strokeSize, thumbStrokeSize, thumbStrokeSize);

    canvas.translate(center.dx, center.dy);

    /// center indicator color circle
    if (showCenterColorIndicator) {
      canvas.drawCircle(
          centerOffset,
          (centerColorIndicatorSize / 2) + pixelSize,
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.grey);

      canvas.drawCircle(
          centerOffset,
          centerColorIndicatorSize / 2,
          Paint()
            ..style = PaintingStyle.fill
            ..color = color.toColor());
    }

    /// hue circle
    canvas.drawCircle(
      centerOffset,
      radio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeSize
        ..shader = SweepGradient(
          colors: [
            HSLColor.fromAHSL(1, 0, 1, .5).toColor(),
            HSLColor.fromAHSL(1, 60, 1, .5).toColor(),
            HSLColor.fromAHSL(1, 120, 1, .5).toColor(),
            HSLColor.fromAHSL(1, 180, 1, .5).toColor(),
            HSLColor.fromAHSL(1, 240, 1, .5).toColor(),
            HSLColor.fromAHSL(1, 300, 1, .5).toColor(),
            HSLColor.fromAHSL(1, 0, 1, .5).toColor(),
          ],
        ).createShader(
          Rect.fromCircle(center: centerOffset, radius: radio),
        ),
    );

    canvas.rotate(Math.pi / 180 * 270);

    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(0, 3),
            radius: radio -
                space(size, centerColorIndicatorSize, strokeSize,
                    thumbStrokeSize, thumbStrokeSize)),
        Math.pi / 180 * apertura,
        Math.pi / 180 * gradosArco,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeSize + pixelSize * 2
          ..color = Colors.grey);

    /// lightness arch
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(0, 3),
          radius: radio -
              space(size, centerColorIndicatorSize, strokeSize, thumbStrokeSize,
                  thumbStrokeSize)),
      Math.pi / 180 * apertura,
      Math.pi / 180 * gradosArco,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeSize
        ..shader = SweepGradient(
          startAngle: Math.pi / 180 * apertura,
          endAngle: Math.pi / 180 * gradosArco,
          colors: [
            HSLColor.fromAHSL(
              1,
              color.hue,
              color.saturation,
              0,
            ).toColor(),
            HSLColor.fromAHSL(
              1,
              color.hue,
              color.saturation,
              .5,
            ).toColor(),
            HSLColor.fromAHSL(
              1,
              color.hue,
              color.saturation,
              1,
            ).toColor(),
          ],
        ).createShader(
          Rect.fromCircle(
              center: Offset(0, 3),
              radius: radio -
                  space(size, centerColorIndicatorSize, strokeSize,
                      thumbStrokeSize, thumbStrokeSize)),
        ),
    );
    canvas.rotate(-Math.pi / 180 * 270);

    canvas.rotate(Math.pi / 180 * 90);

    /// saturation arch
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(0, 3),
            radius: radio -
                space(size, centerColorIndicatorSize, strokeSize,
                    thumbStrokeSize, thumbStrokeSize)),
        Math.pi / 180 * apertura,
        Math.pi / 180 * gradosArco,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeSize + pixelSize * 2
          ..color = Colors.grey);

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(0, 3),
          radius: radio -
              space(size, centerColorIndicatorSize, strokeSize, thumbStrokeSize,
                  thumbStrokeSize)),
      Math.pi / 180 * apertura,
      Math.pi / 180 * gradosArco,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeSize
        ..shader = SweepGradient(
          startAngle: Math.pi / 180 * apertura,
          endAngle: Math.pi / 180 * gradosArco,
          colors: [
            HSLColor.fromAHSL(1, color.hue, 0, color.lightness).toColor(),
            HSLColor.fromAHSL(1, color.hue, 1, color.lightness).toColor(),
          ],
        ).createShader(
          Rect.fromCircle(
              center: Offset(0, 3),
              radius: radio -
                  space(size, centerColorIndicatorSize, strokeSize,
                      thumbStrokeSize, thumbStrokeSize)),
        ),
    );

    canvas.rotate(-Math.pi / 180 * 90);

    /// Thumb hue picker
    final Paint paintColor = new Paint()
      ..color = color.toColor()
      ..style = PaintingStyle.fill;
    final Paint paintWhite = new Paint()
      ..color = Colors.white
      ..strokeWidth = thumbStrokeSize
      ..style = PaintingStyle.stroke;
    final Paint paintBlack = new Paint()
      ..color = Colors.grey
      ..strokeWidth = thumbStrokeSize + 2
      ..style = PaintingStyle.stroke;

    Offset wheel = Wheel.hueToVector(
        ((color.hue + 360.0) * Math.pi / 180.0), radio, centerOffset);
    canvas.drawCircle(wheel, thumbSize, paintBlack);
    canvas.drawCircle(wheel, thumbSize, paintWhite);
    canvas.drawCircle(wheel, thumbSize, paintColor);

    /// Thumb saturacion picker
    final Paint paintSaturacionColor = new Paint()
      ..color = color.toColor()
      ..style = PaintingStyle.fill;
    final Paint paintSaturacionWhite = new Paint()
      ..color = Colors.white
      ..strokeWidth = thumbStrokeSize
      ..style = PaintingStyle.stroke;
    final Paint paintSaturacionBlack = new Paint()
      ..color = Colors.grey
      ..strokeWidth = thumbStrokeSize + 2
      ..style = PaintingStyle.stroke;

    Offset saturacionWheel = Wheel.hueToVector(
        ((color.saturation * gradosArco + apertura + 90) * Math.pi / 180.0),
        radio -
            space(size, centerColorIndicatorSize, strokeSize, thumbStrokeSize,
                thumbStrokeSize),
        centerOffset);
    canvas.drawCircle(
        saturacionWheel.translate(-3, 0), thumbSize, paintSaturacionBlack);
    canvas.drawCircle(
        saturacionWheel.translate(-3, 0), thumbSize, paintSaturacionWhite);
    canvas.drawCircle(
        saturacionWheel.translate(-3, 0), thumbSize, paintSaturacionColor);

    /// Thumb Lightness picker
    final Paint paintLuminosidadColor = new Paint()
      ..color = color.toColor()
      ..style = PaintingStyle.fill;
    final Paint paintLuminosidadWhite = new Paint()
      ..color = Colors.white
      ..strokeWidth = thumbStrokeSize
      ..style = PaintingStyle.stroke;
    final Paint paintLuminosidadBlack = new Paint()
      ..color = Colors.grey
      ..strokeWidth = thumbStrokeSize + 2
      ..style = PaintingStyle.stroke;

    Offset luminosidadWheel = Wheel.hueToVector(
        ((color.lightness * gradosArco + apertura - 90) * Math.pi / 180.0),
        radio -
            space(size, centerColorIndicatorSize, strokeSize, thumbStrokeSize,
                thumbStrokeSize),
        centerOffset);
    canvas.drawCircle(
        luminosidadWheel.translate(3, 0), thumbSize, paintLuminosidadBlack);
    canvas.drawCircle(
        luminosidadWheel.translate(3, 0), thumbSize, paintLuminosidadWhite);
    canvas.drawCircle(
        luminosidadWheel.translate(3, 0), thumbSize, paintLuminosidadColor);
  }

  @override
  bool shouldRepaint(_WheelPainter other) => true;
}
