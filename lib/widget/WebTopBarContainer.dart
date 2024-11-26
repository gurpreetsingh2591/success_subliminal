import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';

class WebTopBarContainer extends StatelessWidget {
  final String screen;

  const WebTopBarContainer({Key? key, required this.screen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 25),
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => {context.push(Routes.dashboard)},
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset('assets/images/app_logo.png', scale: 2.5),
                ),
              )),
          buildTabBarContainer(context),
          Row(children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => {context.pushReplacement(Routes.account)},
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    decoration: kBlackButtonBoxDecoration,
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          child: Image.asset(
                            'assets/images/ic_account_white.png',
                            color: Colors.grey,
                            scale: 3,
                          ),
                        ),
                        Text(
                            SharedPrefs()
                                .getUserFullName()
                                .toString()
                                .toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'DPClear',
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => {
                  _logout(context)

                  //logoutDialog(context)
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 5),
                    decoration: kBlackButtonBoxDecoration,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: Image.asset(
                              'assets/images/logout_web.png',
                              color: Colors.grey,
                              scale: 3,
                            )),
                        Text("LOG OUT".toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'DPClear',
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center),
                      ],
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

  _logout(BuildContext context) {
    if (player.playing) {
      player.stop();
    }

    SharedPrefs().reset();
    SharedPrefs().removeTokenKey();
    SharedPrefs().setIsLogin(false);
    SharedPrefs().setIsSignUp(false);
    SharedPrefs().removeUserEmail();
    SharedPrefs().removeUserFullName();
    SharedPrefs().setIsSubPlaying(false);
    SharedPrefs().setFreeSubId("");
    SharedPrefs().setIsFreeTrail(false);
    SharedPrefs().setIsFreeTrailUsed(false);
    SharedPrefs().setPlayingSubId(0);
    SharedPrefs().setIsSubscription(false);
    SharedPrefs().setUserPlanName("");
    SharedPrefs().removeUserPlanId();
    SharedPrefs().setUserSubscriptionId("");
    SharedPrefs().setSubscriptionStartDate("");
    SharedPrefs().setSubscriptionEndDate("");
    SharedPrefs().setStripeCustomerId("");

    //  Navigator.of(buildContext, rootNavigator: true).pop();
    context.go(Routes.home);
  }

  Widget buildTabBarContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => {context.push(Routes.discover)},
              child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Discover',
                      style: TextStyle(
                          fontSize: 22,
                          color:
                              screen == "discover" ? kTextColor : Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w600),
                    ),
                  )),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => {context.push(Routes.libraryNew)},
              child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Library',
                      style: TextStyle(
                          fontSize: 22,
                          color:
                              screen == "library" ? kTextColor : Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w600),
                    ),
                  )),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => {context.push(Routes.create)},
              child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Create',
                      style: TextStyle(
                          fontSize: 22,
                          color: screen == "create" ? kTextColor : Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w600),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Future logoutDialog(BuildContext buildContext) {
    return showDialog(
      context: buildContext,
      builder: (buildContext) => AlertDialog(
        content: const Text("Are you sure to logout!"),
        actions: [
          TextButton(
            child: const Text(
              kCancel,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w700,
                  color: kTextColor),
            ),
            onPressed: () {
              Navigator.of(buildContext, rootNavigator: true).pop();
            },
          ),
          TextButton(
            child: const Text(
              kOK,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w700,
                  color: kTextColor),
            ),
            onPressed: () {
              SharedPrefs().removeTokenKey();
              SharedPrefs().setIsLogin(false);
              SharedPrefs().setIsSignUp(false);
              SharedPrefs().removeUserEmail();
              SharedPrefs().removeUserFullName();
              SharedPrefs().setIsSubPlaying(false);
              SharedPrefs().setFreeSubId("");
              SharedPrefs().setIsFreeTrail(false);
              SharedPrefs().setIsFreeTrailUsed(false);
              SharedPrefs().setPlayingSubId(0);
              SharedPrefs().setIsSubscription(false);
              SharedPrefs().setUserSubscriptionId("");
              SharedPrefs().setSubscriptionStartDate("");
              SharedPrefs().setSubscriptionEndDate("");
              SharedPrefs().setStripeCustomerId("");

              Navigator.of(buildContext, rootNavigator: true).pop();
              buildContext.go(Routes.home);
            },
          ),
        ],
      ),
    );
  }
}
