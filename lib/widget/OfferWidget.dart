import 'package:flutter/material.dart';

import '../utils/constant.dart';

class OfferWidget extends StatelessWidget {


  const OfferWidget({
    Key? key,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
      decoration: kAllCornerBackgroundBoxDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: kAllCornerBackgroundBoxDecoration,
            margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/images/dummy_image.png', scale: 1.5),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 10, left: 15),
            child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Limited Time Offer',
                  style: TextStyle(
                      fontSize: 32,
                      color: kYellow,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600),
                )),
          ),
          Container(
            padding: const EdgeInsets.only(top: 10, left: 15),
            child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  kCancelAnyTimeMsg,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600),
                )),
          ),
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/images/ic_step.png', scale: 1.30),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                top: 12,
                              ),
                              alignment: Alignment.topLeft,
                              child: const Text(
                                kOffer1,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w400,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ),
                        ]),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/ic_step.png',
                                scale: 1.3),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  top: 12,
                                ),
                                alignment: Alignment.bottomLeft,
                                child: const Text(
                                  kOffer2,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ])),
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 30),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/ic_step.png', scale: 1.3),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                              ),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                kOffer3,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w400,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ),
                        ]),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
