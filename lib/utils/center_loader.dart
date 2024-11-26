import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'constant.dart';

showCenterLoader(BuildContext context) {
  showDialog(context: context, barrierDismissible: false,builder: (ctx) => buildContainer());
}

Widget buildContainer() {
  return const SpinKitDualRing(
            color: kBaseLightColor,
            size: 50.0,
          );
}
