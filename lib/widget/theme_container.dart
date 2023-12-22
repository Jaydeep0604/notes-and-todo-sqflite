import 'package:flutter/material.dart';
import 'package:notes_sqflite/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemedContainer extends StatelessWidget {
  final Widget child;

  ThemedContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return Container(
        decoration: BoxDecoration(
          gradient: themeProvider.themeMode.name == ThemeMode.dark.name
              ? darkGradient
              : lightGradient,
        ),
        child: child,
      );
    });
  }
}

const Gradient darkGradient = RadialGradient(
  colors: [
  
    Color.fromARGB(255, 2, 78, 85),
    Color.fromARGB(255, 2, 78, 85),
    Colors.black,
  ],
  center: Alignment.topCenter,
  stops: [0.01, 0.01, 1.5],
  focal: Alignment.topCenter,
  focalRadius: 0.000001,
  radius: 0.99,
  tileMode: TileMode.decal,
  
);
const Gradient lightGradient = RadialGradient(
  colors: [
    Colors.white,
    Colors.white,
  ],
  
);
