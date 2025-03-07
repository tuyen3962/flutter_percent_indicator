import 'package:flutter/material.dart';
import 'package:percent_indicator/model/percent_model.dart';

class SplitLinearIndicator extends StatelessWidget {
  const SplitLinearIndicator({
    Key? key,
    this.models = const [],
    this.height = 8,
    this.radius = 12,
    this.spacing = 2,
  }) : super(key: key);

  final List<PercentModel> models;
  final double height;
  final double radius;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final total = models.fold<double>(0, (a, b) => a + b.percent);
    if (total != 1) return SizedBox();

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
        child: Row(
            spacing: spacing,
            children: models
                .map((e) => Container(
                    width: e.percent * constraints.maxWidth - spacing,
                    height: height,
                    color: e.color))
                .toList()),
      );
    });
  }
}
