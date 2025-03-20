import 'dart:ui';

import 'package:flutter/material.dart';

class CustomBoldText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const CustomBoldText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text, style: style?? const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
