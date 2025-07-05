import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onPressed;
  const MenuWidget({
    super.key,
    required this.title,
    required this.onPressed,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.sizeOf(context).width / 2.5,
        height: MediaQuery.sizeOf(context).height / 4,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF111221).withOpacity(0.8),
              Color(0xFF313131).withOpacity(0.8),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(image, scale: 7),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
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
