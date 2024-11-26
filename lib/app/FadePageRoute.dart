import 'package:flutter/cupertino.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  FadePageRoute({required this.builder})
      : super(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = 0.0;
              var end = 1.0;
              var tween = Tween(begin: begin, end: end);
              var fadeAnimation = animation.drive(tween);

              return FadeTransition(
                opacity: fadeAnimation,
                child: child,
              );
            });

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
