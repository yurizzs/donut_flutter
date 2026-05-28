import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutSpinner extends StatefulWidget {
  final double size;
  const DonutSpinner({super.key, this.size = 40.0});

  @override
  State<DonutSpinner> createState() => _DonutSpinnerState();
}

class _DonutSpinnerState extends State<DonutSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * math.pi,
          child: Text(
            '🍩',
            style: TextStyle(fontSize: widget.size),
          ),
        );
      },
    );
  }
}

class AppLoading extends StatelessWidget {
  final double size;
  const AppLoading({super.key, this.size = 40.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DonutSpinner(size: size),
    );
  }
}
