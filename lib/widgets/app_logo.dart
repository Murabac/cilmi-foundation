import 'package:flutter/material.dart';

/// Brand logo from [assets/logo.png].
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 120,
    this.width,
  });

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      semanticLabel: 'CILMI FOUNDATION',
    );
  }
}
