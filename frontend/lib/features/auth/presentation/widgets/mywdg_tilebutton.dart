import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyWdgTileButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool isLoading;

  const MyWdgTileButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CupertinoActivityIndicator(color: Colors.white)
            else ...[
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
