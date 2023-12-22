import 'package:flutter/material.dart';
import 'package:auto_animated/auto_animated.dart';

class FadeLiveWidget extends StatelessWidget {
  final Widget child;
  const FadeLiveWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimateIfVisible(
      key: key!,
      builder: (context, animation) => FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.3, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
    );
  }
}
