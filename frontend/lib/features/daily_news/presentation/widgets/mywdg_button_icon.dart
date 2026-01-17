import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyWdgButtonIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isActive;

  const MyWdgButtonIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child:  (isLoading) ?
        const CupertinoActivityIndicator(color: Colors.white)
        :
        Icon(icon, color: isActive ? Colors.white : Colors.blue, size: 26),
            
        
      ),
    );
  }
}
