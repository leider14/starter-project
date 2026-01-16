import 'package:flutter/material.dart';

class MyWdgFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? heroTag;
  final bool isActive;

  const MyWdgFloatingButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.heroTag,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: isActive ? Colors.blue : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.blue,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.blue,
        size: 28,
      ),
    );
  }
}
