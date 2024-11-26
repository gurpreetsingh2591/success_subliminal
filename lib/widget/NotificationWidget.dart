import 'package:flutter/material.dart';

import 'TextFieldWidget400.dart';
import 'TextFieldWidget500.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 8, child: Container()),
              Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset('assets/images/ic_sms.png',
                                scale: 2),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: Text(
                              "EMail".toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset('assets/images/ic_push.png',
                                scale: 2),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: Text(
                              "push".toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ],
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return buildNotificationContainer(
                  context,
                );
              })
        ],
      ),
    );
  }

  Widget buildNotificationContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 8,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: const TextFieldWidget500(
                          text: "Music & Artist Recommendations",
                          size: 16,
                          color: Colors.white,
                          textAlign: TextAlign.center)),
                  Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: const TextFieldWidget(
                        text:
                            "Music and new releases from artists you follow or might like",
                        size: 16,
                        weight: FontWeight.w400,
                        color: Colors.white54,
                      )),
                ],
              )),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/ic_empty_tick.png',
                            scale: 2),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/ic_tick_yellow.png',
                            scale: 2),
                      ),
                    ],
                  )
                ],
              )),
        ],
      ),
    );
  }
}
