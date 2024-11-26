import 'package:flutter/material.dart';

import '../utils/constant.dart';

class TextFieldWidget500 extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final TextAlign textAlign;

  const TextFieldWidget500(
      {Key? key,
      required this.text,
      required this.size,
      required this.color,
      required this.textAlign})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign, style: textStyle(size, color, FontWeight.w500));
  }
}
