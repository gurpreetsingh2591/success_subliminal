import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLogin = false;
  double screenWidth = 900;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {});
    isLogin = SharedPrefs().isLogin();
    if (kDebugMode) {
      print("loginStatus--$isLogin");
    }

    Future.delayed(const Duration(seconds: 2)).then((value) => {
          if (!isLogin)
            {context.pushReplacement(Routes.mainHome)}
          else
            {context.pushReplacement(Routes.create)}
        });
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: statusBarGradient),
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 900) {
              screenWidth = 1000;
              if (kDebugMode) {
                print(screenWidth);
              }
              return buildHomeContainer(context, mq);
            } else {
              screenWidth = 800;
              if (kDebugMode) {
                print(screenWidth);
              }
              return buildHomeContainer(context, mq);
            }
          },
        ));
  }

  Widget buildHomeContainer(BuildContext context, Size mq) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: mq.height,
        ),
        child: Image.asset(
          'assets/images/bg_web.png',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
