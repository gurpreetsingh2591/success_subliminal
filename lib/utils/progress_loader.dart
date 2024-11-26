import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'constant.dart';

showProgressCenterLoader(
    BuildContext context, double downloadProgress, String downloadmessage) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => buildContainer(downloadProgress, downloadmessage));
}

Widget buildContainer(double downloadProgress, String downloadmessage) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SpinKitDualRing(
          color: kBaseLightColor,
          size: 50.0,
        ),
        const SizedBox(height: 16),
        DefaultTextStyle(
          style: const TextStyle(
              fontSize: 16, color: Colors.blueAccent, fontFamily: 'DPClear'),
          child: Text(downloadmessage),
        )
      ],
    ),
  );
}
