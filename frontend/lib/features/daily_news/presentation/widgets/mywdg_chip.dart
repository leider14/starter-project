
import 'package:flutter/material.dart';

class MywdgChip extends StatelessWidget {
  final String text ;
  final VoidCallback onTap;
  final IconData icon;
  final bool isSelected;
  const MywdgChip({super.key, required this.text,required this.onTap, required this.icon, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 10,
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 15,),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Icon( 
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            SizedBox(width: 8,),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

