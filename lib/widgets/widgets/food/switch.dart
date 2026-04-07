import 'package:flutter/material.dart';

class CustomTextSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  final double width;
  final double height;
  final double borderRadius;
  final double toggleSize;

  final Color activeColor;
  final Color inactiveColor;

  final String activeText;
  final String inactiveText;

  final TextStyle activeTextStyle;
  final TextStyle inactiveTextStyle;

  const CustomTextSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 60,
    this.height = 30,
    this.borderRadius = 20,
    this.toggleSize = 28,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.red,
    this.activeText = "ON",
    this.inactiveText = "OFF",
    required this.activeTextStyle,
    required this.inactiveTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: value ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            /// Text - Opposite to toggle circle
            Align(
              alignment:
              value ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  value ? activeText : inactiveText,
                  style: value ? activeTextStyle : inactiveTextStyle,
                ),
              ),
            ),

            /// Toggle Circle
            AnimatedAlign(
              duration: Duration(milliseconds: 250),
              alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: toggleSize,
                height: toggleSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
