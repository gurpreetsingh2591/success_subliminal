import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String isTermPolicy;

  const WebViewScreen({super.key, required this.isTermPolicy});

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebViewScreen> {
  late WebViewController controller;
  String? htmlFilePath;
  final _key = UniqueKey();
  bool _isLoadingPage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isTermPolicy == 'term'
              ? 'Terms & Conditions'
              : "Privacy Policy"),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.yellow, // Set your desired background color here
              child: WebView(
                key: _key,
                initialUrl: widget.isTermPolicy == 'term'
                    ? 'https://app.successsubliminals.net/terms-conditions'
                    : 'https://app.successsubliminals.net/privacy-policy',
                onWebViewCreated: (WebViewController webViewController) {
                  controller = webViewController;
                  /* kIsWeb
                  ? webViewController.loadUrl(Uri.dataFromString(
                      '<!DOCTYPE html><html><head></head><body><embed src="assets/file/termsFile.html"></embed></body></html>',
                      mimeType: 'text/html',
                      encoding: Encoding.getByName('utf-8'),
                    ).toString())
                  : webViewController;*/
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
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ));
  }
}
