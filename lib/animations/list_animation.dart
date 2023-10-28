import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class VerticalAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  VerticalAnimation({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 150),
      child: SlideAnimation(
        verticalOffset: 30.0,
        horizontalOffset: 0.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}
