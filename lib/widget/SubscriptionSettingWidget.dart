import 'package:flutter/material.dart';

import '../utils/constant.dart';

class SubscriptionWidget extends StatelessWidget {
  final dynamic subscription;
  final dynamic subscriptionPriceList;
  final int index;
  final bool currentPlan;
  final VoidCallback onTap;
  final double width;
  final double radius;

  const SubscriptionWidget(
      {Key? key,
      required this.subscription,
      required this.subscriptionPriceList,
      required this.index,
      required this.onTap,
      required this.currentPlan,
      required this.width,
      required this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: width,
          margin: const EdgeInsets.only(top: 20, right: 20),
          padding: const EdgeInsets.all(15),
          decoration: planImageDeco(subscription['name'], radius),
          child: Column(children: [
            SizedBox(
                height: 30,
                child: Visibility(
                  visible: currentPlan,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Image.asset('assets/images/ic_tick_circle.png',
                        color: Colors.green, scale: 1.5),
                  ),
                )),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "\$${subscriptionPriceList['unit_amount'] / 100}",
                      style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w500),
                      /*defining default style is optional */
                      children: <TextSpan>[
                        const TextSpan(
                            text: "/ monthly",
                            style: TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w500)),
                        TextSpan(
                            text: "\nfor a " + subscription['name'],
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white54,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25, left: 10),
                      child: Image.asset('assets/images/ic_step.png', scale: 2),
                    ),
                    Flexible(
                        child: Container(
                            margin: const EdgeInsets.only(top: 25, left: 10),
                            child: Text(
                              planChargeFeatures(subscription['name']),
                              style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.3,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w400),
                            ))),
                  ]),
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Image.asset('assets/images/ic_step.png', scale: 2),
                    ),
                    Flexible(
                        child: Container(
                            margin: const EdgeInsets.only(top: 10, left: 10),
                            child: Text(
                              planCreateSubFeatures(subscription['name']),
                              style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.3,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w400),
                            ))),
                  ]),
                ]),
          ])),
    );
  }
}
