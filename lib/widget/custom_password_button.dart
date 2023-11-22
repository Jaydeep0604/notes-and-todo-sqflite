import 'package:flutter/material.dart';

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
      onTap: widget.onTap,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
            color: Theme.of(context).highlightColor.withOpacity(0.1),
            border: Border.all(
              color: Theme.of(context).highlightColor,
            ),
            shape: BoxShape.circle),
        child: Center(
          child: Text(
            "${widget.text}",
            style: TextStyle(fontSize: 26),
          ),
        ),
      ),
    );
  }
}
