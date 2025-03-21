import 'package:flutter/material.dart';

class CommonStyles {
  static const TextStyle boldText = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static Text boldTextWidget(String text, {TextStyle? style}) {
    return Text(
      text,
      style: style ?? boldText,
    );
  }
}