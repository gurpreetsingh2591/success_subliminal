import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/constant.dart';

class ButtonWidget extends StatelessWidget {
  final String name;
  final double size;
  final String icon;
  final bool visibility;
  final double padding;
  final double scale;
  final double height;
  final VoidCallback onTap;

  const ButtonWidget({
    Key? key,
    required this.name,
    required this.icon,
    required this.visibility,
    required this.padding,
    required this.onTap,
    required this.size,
    required this.scale,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: padding, right: padding),
      decoration: kIsWeb ? kButtonBox10Decoration : kButtonBox10Decoration,
      height: height,
      alignment: Alignment.center,
      child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
              primary: Colors.transparent, shadowColor: Colors.transparent),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                  visible: visibility,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(right: 5),
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        icon,
                        scale: scale,
                        color: Colors.white,
                      ),
                    ),
                  )),
              Flexible(
                  child: Text(name.toUpperCase(),
                      style: TextStyle(
                        fontSize: size,
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w400,
                      ))),
            ],
          )),
    );
  }
}
