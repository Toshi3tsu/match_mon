import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final bool disabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    
    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onPrimary;
        break;
      case ButtonVariant.secondary:
        backgroundColor = theme.colorScheme.secondary;
        textColor = theme.colorScheme.onSecondary;
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = theme.colorScheme.primary;
        break;
    }

    double padding;
    double fontSize;
    
    switch (size) {
      case ButtonSize.small:
        padding = 8;
        fontSize = 12;
        break;
      case ButtonSize.medium:
        padding = 12;
        fontSize = 14;
        break;
      case ButtonSize.large:
        padding = 16;
        fontSize = 16;
        break;
    }

    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled
            ? backgroundColor.withOpacity(0.5)
            : backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.all(padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}

enum ButtonVariant {
  primary,
  secondary,
  ghost,
}

enum ButtonSize {
  small,
  medium,
  large,
}







