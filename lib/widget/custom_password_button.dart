import 'package:flutter/material.dart';
import 'package:notes_sqflite/utils/app_colors.dart';

class CustomPasswordButton extends StatefulWidget {
  CustomPasswordButton({
    super.key,
    required this.onTap,
    required this.text,
  });
  void Function() onTap;
  String text;
  @override
  State<CustomPasswordButton> createState() => _CustomPasswordButtonState();
}

class _CustomPasswordButtonState extends State<CustomPasswordButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      splashColor: AppColors.canvasColor.withOpacity(0.5),
      highlightColor: Colors.transparent,
      onTap: widget.onTap,
      child: Container(
        height: 65,
        width: 65,
        // decoration: BoxDecoration(
        //     color: Theme.of(context).highlightColor.withOpacity(0.1),
        //     border: Border.all(
        //       color: Theme.of(context).highlightColor.withOpacity(0.2),
        //     ),
        //     shape: BoxShape.circle),
        child: Center(
          child: Text("${widget.text}",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 22)),
        ),
      ),
    );
  }
}
