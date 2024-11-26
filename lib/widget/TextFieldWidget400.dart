import 'package:flutter/material.dart';

import '../utils/constant.dart';

class TextFieldWidget extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final FontWeight weight;

  const TextFieldWidget(
      {Key? key,
      required this.text,
      required this.size,
      required this.color,
      required this.weight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: textStyle(size, color, weight));
  }
}
