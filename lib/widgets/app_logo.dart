import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/logo.jpg',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.donut_large, size: size, color: const Color(0xFFE91E63)),
    );
  }
}
