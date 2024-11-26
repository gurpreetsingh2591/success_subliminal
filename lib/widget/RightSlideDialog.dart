import 'package:flutter/material.dart';

import '../utils/constant.dart';

class RightSlideDialog extends StatefulWidget {
  final Widget child;
  final double screenSize;
  final VoidCallback onClose;

  const RightSlideDialog({
    Key? key,
    required this.child,
    required this.onClose,
    required this.screenSize,
  }) : super(key: key);

  @override
  _RightSlideDialogState createState() => _RightSlideDialogState();
}

class _RightSlideDialogState extends State<RightSlideDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(_animation),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          //   _controller.reverse().then((value) => widget.onClose());
        },
        child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              color: accent,
              width: MediaQuery.of(context).size.width * widget.screenSize,
              height: MediaQuery.of(context).size.height,
              child: widget.child,
            )),
      ),
    );
  }
}
