import 'package:flutter/material.dart';

import '../utils/constant.dart';

class SupportWidget extends StatelessWidget {
  final TextEditingController supportDescriptionText;

  SupportWidget({Key? key, required this.supportDescriptionText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: kEditTextDecoration,
      child: TextFormField(
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'DPClear',
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        controller: supportDescriptionText,
        maxLines: 12,
        keyboardType: TextInputType.text,
        enableSuggestions: false,
        textAlign: TextAlign.left,
        onEditingComplete: () => FocusScope.of(context).nextFocus(),
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16.0,
              color: Colors.white54,
              fontFamily: 'DPClear'),
          hintText: "Message",
          contentPadding: EdgeInsets.only(right: 15),
        ),
      ),
    );
  }
}
