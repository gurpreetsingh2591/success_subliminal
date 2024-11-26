import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:success_subliminal/pages/home_page.dart';

import '../app/router.dart';
import '../pages/discover_page.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../widget/ButtonWidget400.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return showAlertDialog(context, "");
  }

  Future errorDialog(String title, BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content: Text(title),
            backgroundColor: kTransBaseNew,
            actions: [
              TextButton(
                child: const Text(
                  "OK",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
    );
  }

  buildUpgradeMobileSubscriptionDialogContainer(BuildContext contexts,
      int difference,
      bool isSubscriptionActive,
      bool isTrial,
      String amount,
      String plan,
      String subId) {
    return showDialog(
        context: contexts,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              backgroundColor: kDialogBgColor,
              insetPadding: const EdgeInsets.all(15),
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 10,
                        ),
                        alignment: Alignment.center,
                        child: Align(
                            alignment: Alignment.center,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: difference < 8 && !isSubscriptionActive
                                    ? "You’ve reached your Create Subliminal limit for your Free Trial. You can wait until the card on file gets charged with the subscription plan or you can upgrade now."
                                    : 'You’ve reached your Create Subliminal limit for your current Plan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w400,
                                ),
                                /*defining default style is optional */
                              ),
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: kButtonBox10Decoration,
                            margin: const EdgeInsets.only(
                                top: 20, right: 5, left: 5),
                            child: ButtonWidget400(
                                buttonSize: 40,
                                name: 'Not Now'.toUpperCase(),
                                icon: '',
                                visibility: false,
                                padding: 10,
                                onTap: () => {Navigator.pop(context)},
                                size: 12,
                                deco: kButtonBox10Decoration),
                          ),
                          Container(
                            decoration: kButtonBox10Decoration,
                            margin: const EdgeInsets.only(
                                top: 20, right: 5, left: 5),
                            child: ButtonWidget400(
                                buttonSize: 40,
                                name: 'Upgrade'.toUpperCase(),
                                icon: '',
                                visibility: false,
                                padding: 10,
                                onTap: () =>
                                {
                                  if (SharedPrefs().getUserPlanId() != null)
                                    {
                                      if (!isTrial && !isSubscriptionActive)
                                        {
                                          contexts.pushNamed('subscription',
                                              queryParameters: {
                                                "screen": 'create'
                                              })
                                        }
                                      else
                                        {
                                          if (!isTrial &&
                                              isSubscriptionActive)
                                            {
                                              contexts.pushNamed(
                                                  'subscription',
                                                  queryParameters: {
                                                    "screen": 'create'
                                                  })
                                            }
                                          else
                                            {

                                              contexts.pushNamed(
                                                  'add-payment',
                                                  queryParameters: {
                                                    'amount': amount,
                                                    "subscriptionId": subId,
                                                    "planType": plan,
                                                    "screen": 'create',
                                                  })
                                            }
                                        }
                                    }
                                  else
                                    {
                                      contexts.pushNamed('subscription',
                                          queryParameters: {
                                            "screen": 'create',
                                          })
                                    },
                                  Navigator.pop(context),
                                },
                                size: 12,
                                deco: kButtonBox10Decoration),
                          ),
                        ],
                      )
                    ],
                  )));
        });
  }

  Future dialogAnAccount(String title, String password, BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            content: Text(password),
            backgroundColor: kTransBaseNew,
            actions: [
              TextButton(
                child: const Text(
                  "OK",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                onPressed: () {
                  _navigateToHomeScreen(context);
                },
              ),
            ],
          ),
    );
  }

  showAlertDialog(BuildContext context, String title) {
    Widget cancelButton = TextButton(
      child: const Text(
        "No",
        style: TextStyle(
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: Colors.white),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Buy Subscription",
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: Colors.white)),
      onPressed: () {
        context.push(Routes.subscription);
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      content: Text(title),
      backgroundColor: kTransBaseNew,
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => const HomePage(),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToHomeScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DiscoverPage()),
            (Route<dynamic> route) => false);
  }
}
