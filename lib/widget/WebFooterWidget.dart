import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../pages/web_view.dart';
import '../utils/constant.dart';

class WebFooterWidget extends StatelessWidget {
  const WebFooterWidget({
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
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 10,
                    ),
                    child: Image.asset(
                      "assets/images/ic_apple_pay.png",
                      scale: 1.5,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Image.asset(
                      "assets/images/ic_google_play_icon.png",
                      scale: 1.5,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () =>
                        {

                          context.push(Routes.term)
                          //_navigateToWebScreen(context, 'term')
                          //launchTermURL()
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
                        onTap: () =>
                        {
                          //_navigateToWebScreen(context, 'term')
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
            ]));
  }

  void _navigateToWebScreen(BuildContext context, String isTermPolicy) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) =>
            WebViewScreen(
              isTermPolicy: isTermPolicy,
            ),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
