import 'package:flutter/material.dart';

import '../utils/constant.dart';
import 'ButtonWidget400.dart';
import 'CommonCVVTextField.dart';
import 'CommonTextFieldNumber.dart';
import 'CommonTextFieldSetting.dart';
import 'ExpiryTextField.dart';
import 'TextFieldWidget500.dart';

class SettingCardInfoWidget extends StatelessWidget {
  final TextEditingController cardNoText;
  final TextEditingController expiryMonthText;
  final TextEditingController expiryYearText;
  final TextEditingController cvvText;
  final TextEditingController nameText;
  final FocusNode nameFocus;
  final FocusNode cvvFocus;
  final FocusNode expiryMonthFocus;
  final FocusNode expiryYearFocus;
  final FocusNode cardFocus;
  final String buttonName;
  final String screen;
  final String type;
  final VoidCallback onTap;

  const SettingCardInfoWidget({
    Key? key,
    required this.cardNoText,
    required this.cvvText,
    required this.nameText,
    required this.expiryMonthText,
    required this.expiryYearText,
    required this.onTap,
    required this.buttonName,
    required this.screen,
    required this.type,
    required this.nameFocus,
    required this.cvvFocus,
    required this.expiryMonthFocus,
    required this.expiryYearFocus,
    required this.cardFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 10, right: 15, top: 15),
            child: const TextFieldWidget500(
                text: 'Card Number',
                size: 16,
                color: Colors.white,
                textAlign: TextAlign.center),
          ),
          Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: kEditTextDecoration,
              child: CommonTextFieldNumber(
                controller: cardNoText,
                hintText: '0000  0000  0000  0000',
                text: '',
                maxLength: 16,
                focus: cardFocus,
              )),
          Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(top: 10, left: 10),
                          child: const TextFieldWidget500(
                              text: 'Expiration Date',
                              size: 16,
                              color: Colors.white,
                              textAlign: TextAlign.center))),
                  Expanded(
                      flex: 1,
                      child: Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(left: 10, top: 10),
                          child: const TextFieldWidget500(
                              text: 'Security Code',
                              size: 16,
                              color: Colors.white,
                              textAlign: TextAlign.center)))
                ],
              )),
          Container(
              margin: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 50,
                              width: 60,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: kEditTextDecoration,
                              child: ExpiryTextField(
                                controller: expiryMonthText,
                                hintText: 'MM',
                                text: '',
                                isFocused: false,
                                focus: expiryMonthFocus,
                              )),
                          Container(
                              height: 50,
                              width: 20,
                              margin: const EdgeInsets.only(right: 5),
                              alignment: Alignment.center,
                              child: const TextFieldWidget500(
                                  text: '/',
                                  size: 16,
                                  color: Colors.white,
                                  textAlign: TextAlign.center)),
                          Container(
                              height: 50,
                              width: 60,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: kEditTextDecoration,
                              child: ExpiryTextField(
                                controller: expiryYearText,
                                hintText: 'YY',
                                text: '',
                                isFocused: false,
                                focus: expiryYearFocus,
                              )),
                        ]),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 50,
                              width: 60,
                              margin: const EdgeInsets.only(left: 5),
                              decoration: kEditTextDecoration,
                              child: CommonCVVTextField(
                                controller: cvvText,
                                hintText: 'CVV',
                                text: '',
                                maxLength: 3,
                                focus: cvvFocus,
                              )),
                        ]),
                  )
                ],
              )),
          Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(left: 10, right: 15, top: 30),
              child: const TextFieldWidget500(
                  text: 'Name on Card',
                  size: 16,
                  color: Colors.white,
                  textAlign: TextAlign.center)),
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: kEditTextDecoration,
            child: CommonTextFieldSetting(
              controller: nameText,
              hintText: "Name Surname",
              text: "",
              isFocused: true,
              focus: nameFocus,
            ),
          ),
          Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  decoration: kEditTextDecoration,
                  child: ButtonWidget400(
                      buttonSize: 50,
                      name: type == "edit"
                          ? "Edit card".toUpperCase()
                          : screen == 'subscription'
                              ? buttonName.toUpperCase()
                              : "+  Add card".toUpperCase(),
                      icon: '',
                      visibility: false,
                      padding: 30,
                      onTap: onTap,
                      size: 14,
                      deco: kButtonBox10Decoration),
                ),
              ]),
        ]);
  }
}
