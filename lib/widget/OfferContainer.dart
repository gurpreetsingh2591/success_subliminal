import 'package:flutter/material.dart';

import '../utils/constant.dart';

class OfferContainerWidget extends StatelessWidget {
  const OfferContainerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  children: const [
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
                padding: const EdgeInsets.only(left: 20, top: 15, right: 15),
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
            )
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
        ]);
  }
}
