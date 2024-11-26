import 'package:flutter/material.dart';

import '../utils/constant.dart';
import '../widget/ButtonWidget400.dart';

class CustomUpgradeDialog extends StatelessWidget {
  final BuildContext context;
  final int difference;
  final bool isSubscriptionActive;
  final bool isTrial;
  final VoidCallback onTap;

  const CustomUpgradeDialog(
      {Key? key,
      required this.difference,
      required this.isSubscriptionActive,
      required this.isTrial,
      required this.onTap,
      required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildUpgradeMobileSubscriptionDialogContainer(
        context, difference, isSubscriptionActive, isTrial, onTap);
  }

  buildUpgradeMobileSubscriptionDialogContainer(
      BuildContext contexts,
      int difference,
      bool isSubscriptionActive,
      bool isTrial,
      VoidCallback onTap) {
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
                                onTap: () => {onTap},
                                size: 12,
                                deco: kButtonBox10Decoration),
                          ),
                        ],
                      )
                    ],
                  )));
        });
  }
}
