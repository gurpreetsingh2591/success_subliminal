import 'package:flutter/material.dart';
import 'package:success_subliminal/app/router.dart';
import 'package:success_subliminal/app/theme.dart';

import '../utils/MyCustomScrollBehavior.dart';

class MyApp extends StatelessWidget /*with WidgetsBindingObserver */ {
  MyApp({super.key});

  final _appKey = GlobalKey();
  final _router = buildRouter();

  /* @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      */ /*  SharedPrefs().setIsSubPlaying(false);
      SharedPrefs().setPlayingSubId(-1);*/ /*
    } else if (state == AppLifecycleState.resumed) {}
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scrollBehavior: MyCustomScrollBehavior(),
      key: _appKey,
      title: 'Success Subliminals',
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      theme: mainTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success Subliminals'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}
