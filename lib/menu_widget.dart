import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  final String title;
  // function for navigate
  final VoidCallback onPressed;
  const MenuWidget({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 180,
        height: 121,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: Colors.black.withValues(alpha: 0.25),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
