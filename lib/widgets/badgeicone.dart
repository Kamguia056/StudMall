import 'package:flutter/material.dart';

class BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color badgeColor;
  final Color iconColor;
  final double iconSize;
  final double badgeSize;
  final VoidCallback? onPressed;

  const BadgedIcon({
    Key? key,
    required this.icon,
    this.count = 0,
    this.badgeColor = Colors.red,
    this.iconColor = Colors.black,
    this.iconSize = 24,
    this.badgeSize = 16,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          if (count > 0)
            Positioned(
              top: -badgeSize / 4,
              right: -badgeSize / 4,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: badgeSize * 0.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
