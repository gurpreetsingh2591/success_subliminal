import 'package:flutter/material.dart';

import '../utils/constant.dart';

class OfferWidgetWeb extends StatelessWidget {
  final double limitedTextSize;

  const OfferWidgetWeb({
    Key? key,
    required this.limitedTextSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          decoration: kDummyImageDecoration,
          margin: const EdgeInsets.only(left: 40, right: 10, top: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/discover_dummy_img.png',
                scale: 1,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 40, left: 40),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Limited Time Offer',
                style: TextStyle(
                    fontSize: limitedTextSize,
                    color: kYellow,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500),
              )),
        ),
        Container(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 40,
          ),
          child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                kCancelAnyTimeMsg,
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500),
              )),
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 40,
            right: 15,
          ),
          // padding: const EdgeInsets.only( right: 15,top:45,),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(children: <Widget>[
                  Image.asset('assets/images/ic_step.png', scale: 1.5),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                      ),
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kOffer1,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
                Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Image.asset('assets/images/ic_step.png', scale: 1.5),
                  ),
                  Flexible(
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 20, top: 15, right: 15),
                      child: const Text(
                        kOffer2,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontStyle: FontStyle.normal,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                ]),
                Row(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Image.asset('assets/images/ic_step.png', scale: 1.5),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, top: 15),
                      alignment: Alignment.bottomLeft,
                      child: const Text(
                        kOffer3,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                ]),
              ]),
        ),
      ],
    );
  }
}
