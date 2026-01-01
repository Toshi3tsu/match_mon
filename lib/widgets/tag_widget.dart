import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String label;
  final TagVariant variant;

  const TagWidget({
    super.key,
    required this.label,
    this.variant = TagVariant.default_,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case TagVariant.success:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case TagVariant.warning:
        backgroundColor = Colors.yellow.shade100;
        textColor = Colors.yellow.shade800;
        break;
      case TagVariant.danger:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      default:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum TagVariant {
  default_,
  success,
  warning,
  danger,
}







