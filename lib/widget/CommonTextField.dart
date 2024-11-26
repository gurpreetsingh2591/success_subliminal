import 'package:flutter/material.dart';

import '../utils/constant.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final String hintText;
  final bool autocorrect;
  final String text;
  bool isFocused;
  bool isDeco;
  Color textColor;

  CommonTextField(
      {Key? key,
      required this.controller,
      required this.hintText,
      this.autocorrect = false,
      required this.text,
      required this.isFocused,
      required this.isDeco,
      required this.textColor,
      required this.focus})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isDeco ? kEditTextDecoration : null,
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: TextFormField(
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
              focusNode: focus,
              keyboardType: TextInputType.text,
              enableSuggestions: false,
              autocorrect: autocorrect,
              controller: controller,
              autofocus: false,
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
          ),
          !isFocused
              ? Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => {},
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      height: 45,
                      decoration: kTransButtonBoxDecoration,
                      alignment: Alignment.topRight,
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/ic_edit_pencil.png',
                            scale: 2),
                      ),
                    ),
                  ),
                )
              : const Text(""),
        ],
      ),
    );
  }
}
