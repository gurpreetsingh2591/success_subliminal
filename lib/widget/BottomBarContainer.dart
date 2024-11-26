import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../utils/constant.dart';

class BottomBarContainer extends StatelessWidget {
  final String screen;
  final bool isUserLogin;

  BottomBarContainer(
      {Key? key, required this.screen, required this.isUserLogin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isUserLogin
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
                                        Image.asset(
                                            'assets/images/ic_home_white.png',
                                            scale: 1.8,
                                            color: screen == "dashboard"
                                                ? kYellow
                                                : Colors.white),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            'Home',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: screen == "dashboard"
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
                                        Image.asset(
                                            'assets/images/ic_discover.png',
                                            scale: 1.8,
                                            color: screen == "discover"
                                                ? kYellow
                                                : Colors.white),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            'Discover',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: screen == "discover"
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
                                        Image.asset(
                                          'assets/images/ic_library_white.png',
                                          scale: 1.8,
                                          color: screen == "library"
                                              ? kYellow
                                              : Colors.white,
                                        ),
                                        Container(
                                            margin:
                                                const EdgeInsets.only(top: 5),
                                            child: Text(
                                              'Library',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: screen == "library"
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
                                        Image.asset(
                                          'assets/images/ic_create_yellow.png',
                                          scale: 1.8,
                                          color: screen == "create"
                                              ? kYellow
                                              : Colors.white,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            'Create',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: screen == "create"
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
                                        Image.asset(
                                          'assets/images/ic_account_white.png',
                                          scale: 1.8,
                                          color: screen == "account"
                                              ? kYellow
                                              : Colors.white,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            'Account',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: screen == "account"
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
                                            Image.asset(
                                              'assets/images/ic_home.png',
                                              scale: 1.8,
                                              color: screen == "home"
                                                  ? Colors.yellow
                                                  : Colors.white,
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text('Home',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: screen == "home"
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
                                      onTap: () =>
                                          {context.push(Routes.signIn)},
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              'assets/images/ic_discover.png',
                                              scale: 1.8,
                                              color: screen == "discover"
                                                  ? kYellow
                                                  : Colors.white,
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text('Discover',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          screen == "discover"
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
