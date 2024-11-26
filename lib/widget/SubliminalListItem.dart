import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../utils/constant.dart';

class SubliminalItemContainer extends StatelessWidget {
  final BuildContext context;
  final String buttonName;
  final bool isWish;
  final dynamic subliminalList;
  final AudioPlayer player;

  const SubliminalItemContainer({
    Key? key,
    required this.context,
    required this.buttonName,
    required this.isWish,
    required this.subliminalList,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context = this.context;
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: kAllCornerBoxDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              subliminalList['cover_path'] != ""
                  ? SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Image.network(
                            subliminalList['cover_path'],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ))
                  : SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/images/bg_logo_image.png',
                          ),
                        ),
                      ),
                    ),
              Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 15,
                            bottom: 10,
                          ),
                          alignment: Alignment.topLeft,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              subliminalList['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w600,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 15,
                            bottom: 10,
                          ),
                          alignment: Alignment.topLeft,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              subliminalList['description'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w400,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ),
                      )
                    ]),
              ),
            ],
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 9,
                  child: buildListenButton(context),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    decoration: kTransButtonBoxDecoration,
                    alignment: Alignment.topRight,
                    margin: const EdgeInsets.only(left: 7, right: 2, top: 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/ic_download.png',
                          scale: 1.5),
                    ),
                  ),
                ),
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Visibility(
                    visible: isWish,
                    child: Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => {},
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, top: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 3),
                                  height: 50,
                                  decoration: kTransButtonBoxDecoration,
                                  alignment: Alignment.topRight,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                        'assets/images/ic_heart_empty.png',
                                        scale: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 50,
                    decoration: kTransButtonBoxDecoration,
                    margin: const EdgeInsets.only(top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.center,
                            child: Image.asset('assets/images/ic_edit.png',
                                scale: 1.5),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              buttonName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w600,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(right: 3),
                            height: 50,
                            decoration: kTransButtonBoxDecoration,
                            alignment: Alignment.topRight,
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                  'assets/images/ic_attachment.png',
                                  scale: 1.5),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(right: 3),
                            height: 50,
                            decoration: kTransButtonBoxDecoration,
                            alignment: Alignment.topRight,
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/ic_fb.png',
                                  scale: 1.5),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(right: 3),
                            height: 50,
                            decoration: kTransButtonBoxDecoration,
                            alignment: Alignment.topRight,
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/ic_twitter.png',
                                  scale: 1.5),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ])
        ],
      ),
    );
  }

  Widget buildListenButton(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          // height: 50,
          child: ElevatedButton(
            onPressed: () async {
              print(subliminalList['audio_path']);
              await player.setUrl(subliminalList['audio_path']);
              await player.play();
              //context.go(Routes.createSubliminal);
            },
            style: ElevatedButton.styleFrom(
              primary: kButtonColor1,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // <-- Radius
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 150),
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/ic_play.png', scale: 1.5),
                  ),
                ),
                Text('listen '.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ));
  }
}
