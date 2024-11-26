import 'package:flutter/material.dart';

class ButtonWidget400 extends StatelessWidget {
  final String name;
  final double size;
  final String icon;
  final bool visibility;
  final double padding;
  final double buttonSize;
  final VoidCallback onTap;
  final Decoration deco;

  const ButtonWidget400({
    Key? key,
    required this.name,
    required this.icon,
    required this.visibility,
    required this.padding,
    required this.onTap,
    required this.size,
    required this.buttonSize,
    required this.deco,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: padding, right: padding),
      decoration: deco,
      height: buttonSize,
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
                    margin: const EdgeInsets.only(right: 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        icon,
                        scale: 2,
                      ),
                    ),
                  )),
              Text(name.toUpperCase(),
                  style: TextStyle(
                    fontSize: size,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w400,
                  )),
            ],
          )),
    );
  }
}
