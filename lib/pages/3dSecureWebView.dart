import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Secure3DWebViewScreen extends StatefulWidget {
  final String isTermPolicy;

  const Secure3DWebViewScreen({super.key, required this.isTermPolicy});

  @override
  Secure3DWebViewState createState() => Secure3DWebViewState();
}

class Secure3DWebViewState extends State<Secure3DWebViewScreen> {
  late WebViewController controller;
  String? htmlFilePath;
  final _key = UniqueKey();
  bool _isLoadingPage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("3D Secure Authentication"),
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: WebView(
                key: _key,
                initialUrl: "",
                onWebViewCreated: (WebViewController webViewController) {
                  controller = webViewController;
                },
                // Set your initial URL here
                onPageStarted: (String url) {
                  setState(() {
                    _isLoadingPage = true;
                  });
                },
                onPageFinished: (String url) {
                  setState(() {
                    _isLoadingPage = false;
                  });
                },
              ),
            ),
            if (_isLoadingPage)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ));
  }
}
