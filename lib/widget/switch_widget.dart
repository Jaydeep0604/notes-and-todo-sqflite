import 'package:flutter/material.dart';
import 'package:notes_sqflite/utils/app_colors.dart';

class SwitchWidget extends StatefulWidget {
  SwitchWidget({
    super.key,
    required this.value,
    required this.onTap,
  });
  bool value;
  void Function() onTap;
  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(2),
        width: 48,
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              20,
            ),
            border: Border.all(color: Theme.of(context).iconTheme.color!)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.value) Spacer(),
            if (!widget.value)
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).iconTheme.color!,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "off",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 12,color: Theme.of(context).cardColor),
                  ),
                ),
              ),
            if (widget.value)
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: AppColors.greenSplashColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text("on",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 12, color: AppColors.blackColor)),
                ),
              ),
            if (!widget.value) Spacer(),
          ],
        ),
      ),
    );
  }
}
