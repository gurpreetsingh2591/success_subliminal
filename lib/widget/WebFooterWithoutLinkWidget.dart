import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../utils/constant.dart';

class WebFooterWithoutLinkWidget extends StatelessWidget {
  const WebFooterWithoutLinkWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
        left: 10,
        right: 10,
      ),
      height: 80,
      decoration: kBlackButtonBox10Decoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => {
                  context.push(Routes.term)
                  // launchTermURL()
                },
                child: const Text(
                  'Terms & Conditions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 20),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: () => {
                  context.push(Routes.privacy)
                  //launchURL()
                },
                child: const Text(
                  'Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
