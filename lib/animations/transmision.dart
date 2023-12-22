import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FadeThroughTransitionSwitcher extends StatelessWidget {
 const FadeThroughTransitionSwitcher({
   required this.child,
 });

 final Widget child;

 @override
 Widget build(BuildContext context) {
   return PageTransitionSwitcher(
     transitionBuilder: (child, animation, secondaryAnimation) {
       return FadeThroughTransition(
         child: child,
         animation: animation,
         secondaryAnimation: secondaryAnimation,
       );
     },
     child: child,
   );
 }
}

