import 'package:flutter/material.dart';

import '../utils/constant.dart';

class NoteField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FocusNode focus;

  const NoteField(
      {Key? key,
      required this.controller,
      required this.hintText,
      required this.focus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: kEditTextDecoration,
      child: TextFormField(
        maxLines: 6,
        //obscureText: true,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'DPClear',
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),

        keyboardType: TextInputType.text,
        controller: controller,
        focusNode: focus,
        textAlign: TextAlign.left,
        onEditingComplete: () => FocusScope.of(context).nextFocus(),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
          hintStyle: const TextStyle(
              fontSize: 14.0, color: Colors.white54, fontFamily: 'DPClear'),
          hintText: hintText,
          contentPadding: const EdgeInsets.all(10.0),
        ),
      ),
    );
  }
}
