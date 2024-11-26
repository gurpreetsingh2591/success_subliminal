import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../app/router.dart';

class BottomBarStateFull extends StatefulWidget {
  final String screen;
  final bool isUserLogin;

  const BottomBarStateFull(
      {Key? key, required this.screen, required this.isUserLogin})
      : super(key: key);

  @override
  BottomBarStateFullState createState() => BottomBarStateFullState();
}

class BottomBarStateFullState extends State<BottomBarStateFull> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return widget.isUserLogin
        ? Positioned(
            bottom: 0,
            width: MediaQuery.of(context).size.width,
            child: Container(
                decoration: kBottomBarBgDecoration,
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1,
                      color: Colors.white24,
                    ),
                    Container(
                        decoration: kBottomBarBgDecoration,
                        height: 69,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        {context.push(Routes.dashboard)},
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        widget.screen == "dashboard"
                                            ? Image.asset(
                                                'assets/images/ic_home_yellow.png',
                                                scale: 1.8,
                                              )
                                            : Image.asset(
                                                'assets/images/ic_home_white.png',
                                                scale: 1.8,
                                              ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            'Home',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    widget.screen == "dashboard"
                                                        ? kYellow
                                                        : Colors.white,
                                                fontFamily: 'DPClear',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        {context.push(Routes.discover)},
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        widget.screen == "discover"
                                            ? Image.asset(
                                                'assets/images/ic_discover_yellow.png',
                                                scale: 1.8,
                                              )
                                            : Image.asset(
                                                'assets/images/ic_discover_white.png',
                                                scale: 1.8,
                                              ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            'Discover',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    widget.screen == "discover"
                                                        ? kYellow
                                                        : Colors.white,
                                                fontFamily: 'DPClear',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        {context.push(Routes.libraryNew)},
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        widget.screen == "library"
                                            ? Image.asset(
                                                'assets/images/ic_library_yellow.png',
                                                scale: 1.8,
                                              )
                                            : Image.asset(
                                                'assets/images/ic_library_white.png',
                                                scale: 1.8,
                                              ),
                                        Container(
                                            margin:
                                                const EdgeInsets.only(top: 5),
                                            child: Text(
                                              'Library',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      widget.screen == "library"
                                                          ? kYellow
                                                          : Colors.white,
                                                  fontFamily: 'DPClear',
                                                  fontWeight: FontWeight.w400),
                                            )),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => {context.push(Routes.create)},
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        widget.screen == "create"
                                            ? Image.asset(
                                                'assets/images/ic_create_yellow.png',
                                                scale: 1.8,
                                              )
                                            : Image.asset(
                                                'assets/images/ic_create_white.png',
                                                scale: 1.8,
                                              ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            'Create',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: widget.screen == "create"
                                                    ? kYellow
                                                    : Colors.white,
                                                fontFamily: 'DPClear',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => {context.push(Routes.account)},
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        widget.screen == "account"
                                            ? Image.asset(
                                                'assets/images/ic_account_yellow.png',
                                                scale: 1.8,
                                              )
                                            : Image.asset(
                                                'assets/images/ic_account_white.png',
                                                scale: 1.8,
                                              ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            'Account',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    widget.screen == "account"
                                                        ? kYellow
                                                        : Colors.white,
                                                fontFamily: 'DPClear',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ]))
                  ],
                )),
          )
        : Positioned(
            bottom: 0,
            width: MediaQuery.of(context).size.width,
            child: Container(
                decoration: kBottomBarBgWithoutLoginDecoration,
                height: 70,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 1,
                        color: Colors.white24,
                      ),
                      Container(
                          decoration: kBottomBarBgWithoutLoginDecoration,
                          height: 69,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => {context.push(Routes.home)},
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            widget.screen == "home"
                                                ? Image.asset(
                                                    'assets/images/ic_home_yellow.png',
                                                    scale: 1.8,
                                                  )
                                                : Image.asset(
                                                    'assets/images/ic_home_white.png',
                                                    scale: 1.8,
                                                  ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text('Home',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: widget.screen ==
                                                              "home"
                                                          ? Colors.yellow
                                                          : Colors.white,
                                                      fontFamily: 'DPClear',
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => {
                                        controllers!.pause(),
                                        if (Platform.isIOS)
                                          {context.push(Routes.signIn)}
                                        else
                                          {context.push(Routes.signIn)}
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            widget.screen == "discover"
                                                ? Image.asset(
                                                    'assets/images/ic_discover_yellow.png',
                                                    scale: 1.8,
                                                  )
                                                : Image.asset(
                                                    'assets/images/ic_discover_white.png',
                                                    scale: 1.8,
                                                  ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text('Discover',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: widget.screen ==
                                                              "discover"
                                                          ? kYellow
                                                          : Colors.white,
                                                      fontFamily: 'DPClear',
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ]))
                    ])),
          );
  }
}
