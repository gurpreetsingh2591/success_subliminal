import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../utils/constant.dart';

class TopBarWithoutLoginContainer extends StatelessWidget {
  final String screen;
  final Size mq;

  const TopBarWithoutLoginContainer({
    Key? key,
    required this.screen,
    required this.mq,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 25),
      height: mq.height * 0.1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () =>
                    {videoPlayerController!.pause(), context.push(Routes.home)},
                child: Align(
                  alignment: Alignment.topRight,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      scale: 2,
                    ),
                  ),
                ),
              )),
          Row(children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => {
                  videoPlayerController!.pause(),
                  context.push(Routes.signIn)
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    margin: const EdgeInsets.only(right: 10, top: 2),
                    decoration: kBlackButtonBox10Decoration,
                    height: 52,
                    child: Text("Sign In".toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            letterSpacing: 1,
                            fontFamily: 'DPClear',
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => {
                  videoPlayerController!.pause(),
                  context.push(Routes.signUp)
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      child: Image.asset(
                        'assets/images/ic_text_button.png',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
