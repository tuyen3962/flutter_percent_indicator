part of 'split_circular_percent_indicator.dart';

_ArcAngles _getStartAngleFixedMargin(ArcType arcType) {
  double fixedStartAngle, startAngleFixedMargin;
  if (arcType == ArcType.FULL_REVERSED) {
    fixedStartAngle = 399;
    startAngleFixedMargin = 312 / fixedStartAngle;
  } else if (arcType == ArcType.FULL) {
    fixedStartAngle = 220;
    startAngleFixedMargin = 172 / fixedStartAngle;
  } else {
    fixedStartAngle = 270;
    startAngleFixedMargin = 135 / fixedStartAngle;
  }
  return _ArcAngles(
    fixedStartAngle: fixedStartAngle,
    startAngleFixedMargin: startAngleFixedMargin,
  );
}

class _ArcAngles {
  const _ArcAngles(
      {required this.fixedStartAngle, required this.startAngleFixedMargin});
  final double fixedStartAngle;
  final double startAngleFixedMargin;
}

class _CirclePainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final Paint _paintLineBorder = Paint();
  final Paint _paintBackgroundStartAngle = Paint();
  final double lineWidth;
  final double backgroundWidth;
  final double progress;
  final double radius;
  final Color progressColor;
  final Color? progressBorderColor;
  final Color backgroundColor;
  final CircularStrokeCap circularStrokeCap;
  final double startAngle;
  final LinearGradient? linearGradient;
  final Color? arcBackgroundColor;
  final ArcType? arcType;
  final bool reverse;
  final MaskFilter? maskFilter;
  final bool rotateLinearGradient;
  final int totalDivider;
  final double spacing;

  _CirclePainter(
      {required this.lineWidth,
      required this.backgroundWidth,
      required this.progress,
      required this.radius,
      required this.progressColor,
      required this.backgroundColor,
      this.progressBorderColor,
      this.startAngle = 0.0,
      this.circularStrokeCap = CircularStrokeCap.butt,
      this.linearGradient,
      required this.reverse,
      this.arcBackgroundColor,
      this.arcType,
      this.maskFilter,
      required this.rotateLinearGradient,
      this.totalDivider = 1,
      this.spacing = 2}) {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = backgroundWidth;
    _paintBackground.strokeCap = circularStrokeCap.strokeCap;

    if (arcBackgroundColor != null) {
      _paintBackgroundStartAngle.color = arcBackgroundColor!;
      _paintBackgroundStartAngle.style = PaintingStyle.stroke;
      _paintBackgroundStartAngle.strokeWidth = lineWidth;
      _paintBackgroundStartAngle.strokeCap = circularStrokeCap.strokeCap;
    }

    _paintLine.color = progressColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth =
        progressBorderColor != null ? lineWidth - 2 : lineWidth;
    _paintLine.strokeCap = circularStrokeCap.strokeCap;

    if (progressBorderColor != null) {
      _paintLineBorder.color = progressBorderColor!;
      _paintLineBorder.style = PaintingStyle.stroke;
      _paintLineBorder.strokeWidth = lineWidth;
      _paintLineBorder.strokeCap = circularStrokeCap.strokeCap;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double fixedStartAngle = startAngle;
    double startAngleFixedMargin = 1.0;

    final maxAngle = 360 * startAngleFixedMargin;
    final degreeDistance = (maxAngle - spacing * totalDivider) / (totalDivider);
    if (arcType != null) {
      final arcAngles = _getStartAngleFixedMargin(arcType!);
      fixedStartAngle = arcAngles.fixedStartAngle;
      startAngleFixedMargin = arcAngles.startAngleFixedMargin;
    }

    if (arcType == null) {
      // var startAngle = 0.0 + spacing / 2;
      // for (var i = 0; i < totalDivider; i++) {
      //   canvas.drawArc(
      //       Rect.fromCircle(center: center, radius: radius),
      //       radians(startAngle).toDouble(),
      //       radians(degreeDistance).toDouble(),
      //       false,
      //       _paintBackground);
      //   startAngle += degreeDistance + spacing;
      // }
      drawSplitCircle(canvas, center, maxAngle, degreeDistance,
          paint: _paintBackground);
    }

    if (maskFilter != null) {
      _paintLineBorder.maskFilter = _paintLine.maskFilter = maskFilter;
    }
    if (linearGradient != null) {
      if (rotateLinearGradient && progress > 0) {
        double correction = 0;
        if (_paintLine.strokeCap != StrokeCap.butt) {
          correction = math.atan(_paintLine.strokeWidth / 2 / radius);
        }
        _paintLineBorder.shader = _paintLine.shader = SweepGradient(
          transform: reverse
              ? GradientRotation(
                  radians(-90 - progress + startAngle) - correction)
              : GradientRotation(radians(-90.0 + startAngle) - correction),
          startAngle: radians(0).toDouble(),
          endAngle: radians(progress).toDouble(),
          tileMode: TileMode.clamp,
          colors: reverse
              ? linearGradient!.colors.reversed.toList()
              : linearGradient!.colors,
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );
      } else if (!rotateLinearGradient) {
        _paintLineBorder.shader =
            _paintLine.shader = linearGradient!.createShader(
          Rect.fromCircle(center: center, radius: radius),
        );
      }
    }

    if (arcBackgroundColor != null) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians(-90.0 + fixedStartAngle).toDouble(),
        radians(360 * startAngleFixedMargin).toDouble(),
        false,
        _paintBackgroundStartAngle,
      );
    }

    if (reverse) {
      // final start =
      //     radians(360 * startAngleFixedMargin - 90.0 + fixedStartAngle)
      //         .toDouble();
      // final end = radians(-progress * startAngleFixedMargin).toDouble();
      // if (progressBorderColor != null) {
      //   canvas.drawArc(
      //     Rect.fromCircle(
      //       center: center,
      //       radius: radius,
      //     ),
      //     start,
      //     end,
      //     false,
      //     _paintLineBorder,
      //   );
      // }
      // canvas.drawArc(
      //   Rect.fromCircle(
      //     center: center,
      //     radius: radius,
      //   ),
      //   start,
      //   end,
      //   false,
      //   _paintLine,
      // );
    } else {
      drawSplitCircle(canvas, center, maxAngle, degreeDistance,
          endDegree: progress * startAngleFixedMargin,
          paint: progressBorderColor != null ? _paintLineBorder : _paintLine);
      // var startDegree = 0.0 + spacing / 2;
      // final endDegree = progress * startAngleFixedMargin;
      // for (var i = 0; i < totalDivider; i++) {
      //   final newEndDegree = startDegree + degreeDistance;
      //   final isEnd = newEndDegree >= endDegree;
      //   final sweepAngle = isEnd ? endDegree - startDegree : degreeDistance;
      //   if (sweepAngle > 0) {
      //     canvas.drawArc(
      //         Rect.fromCircle(center: center, radius: radius),
      //         radians(startDegree).toDouble(),
      //         radians(sweepAngle).toDouble(),
      //         false,
      //         progressBorderColor != null ? _paintLineBorder : _paintLine);
      //   }
      //   if (isEnd) return;
      //   startDegree += degreeDistance + spacing;
      // }
    }
  }

  void drawSplitCircle(
      Canvas canvas, Offset center, double maxAngle, double degreeDistance,
      {double? endDegree, required Paint paint}) {
    var startDegree = 0.0 + spacing / 2;
    for (var i = 0; i < totalDivider; i++) {
      double sweepAngle = degreeDistance;
      bool isEnd = false;
      if (endDegree != null) {
        final newEndDegree = startDegree + degreeDistance;
        isEnd = newEndDegree >= endDegree;
        if (isEnd) {
          sweepAngle = endDegree - startDegree;
        }
      }
      if (sweepAngle > 0) {
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            radians(startDegree).toDouble(),
            radians(sweepAngle).toDouble(),
            false,
            paint);
      }
      if (isEnd) return;
      startDegree += degreeDistance + spacing;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
