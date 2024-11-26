import 'package:flutter/material.dart';

import '../utils/constant.dart';

class ExpiryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autocorrect;
  final String text;
  bool isFocused;
  final FocusNode focus;

  ExpiryTextField(
      {Key? key,
      required this.controller,
      required this.hintText,
      this.autocorrect = false,
      required this.text,
      required this.isFocused,
      required this.focus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kEditTextDecoration10Radius,
      child: TextFormField(
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'DPClear',
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        keyboardType: TextInputType.phone,
        /*inputFormatters: [CardExpirationFormatter()],*/
        enableSuggestions: false,
        controller: controller,
        maxLength: 2,
        focusNode: focus,
        autofocus: false,
        textAlign: TextAlign.center,
        onEditingComplete: () => FocusScope.of(context).nextFocus(),
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
          hintStyle: const TextStyle(
              fontSize: 16.0, color: Colors.white54, fontFamily: 'DPClear'),
          hintText: hintText,
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
        ),
      ),
    );
  }
}
