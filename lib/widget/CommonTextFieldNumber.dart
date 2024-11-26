import 'package:flutter/material.dart';

import '../utils/constant.dart';

class CommonTextFieldNumber extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autocorrect;
  final String text;
  final int maxLength;
  final FocusNode focus;

  const CommonTextFieldNumber({
    Key? key,
    required this.controller,
    required this.hintText,
    this.autocorrect = false,
    required this.text,
    required this.maxLength,
    required this.focus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kEditTextDecoration10Radius,
      child: TextFormField(
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'DPClear',
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        keyboardType: TextInputType.phone,
        enableSuggestions: false,
        autocorrect: autocorrect,
        focusNode: focus,
        controller: controller,
        autofocus: false,
        maxLength: maxLength,
        textAlign: TextAlign.left,
        onEditingComplete: () => FocusScope.of(context).nextFocus(),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
          hintStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.0,
              color: Colors.white54,
              fontFamily: 'DPClear'),
          hintText: hintText,
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
        ),
      ),
    );
  }
}
