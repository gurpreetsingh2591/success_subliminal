import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../utils/constant.dart';

class SignUpTextWidget extends StatelessWidget {
  const SignUpTextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: kHaveNotAcc,
          style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'DPClear',
              fontWeight: FontWeight.w500),
          /*defining default style is optional */
          children: [
            TextSpan(
              text: kSignUp,
              style: const TextStyle(
                  fontSize: 16,
                  color: kLoginText,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.pushReplacement(Routes.signUp);
                },
            ),
          ],
        ),
      ),
    );
  }
}
