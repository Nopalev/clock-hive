import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final String heroTag;
  final void Function() onPressed;
  final Icon icon;
  const CustomFAB({
    super.key,
    required this.heroTag,
    required this.onPressed,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100)
      ),
      child: icon,
    );
  }
}
