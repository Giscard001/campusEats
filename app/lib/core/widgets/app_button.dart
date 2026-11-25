import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final Widget? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isLoading) {
      child = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.primary
                ? AppColors.onPrimary
                : (variant == ButtonVariant.secondary ? AppColors.onSecondary : AppColors.primary),
          ),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      child = Text(text);
    }

    final buttonStyle = switch (variant) {
      ButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: AppTextStyles.button,
        ),
      ButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: AppTextStyles.button,
        ),
      ButtonVariant.outline => OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: AppTextStyles.button,
        ),
      ButtonVariant.text => TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.button,
        ),
    };

    Widget btn = switch (variant) {
      ButtonVariant.primary || ButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
      ButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
      ButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        ),
    };

    if (fullWidth) {
      btn = SizedBox(width: double.infinity, child: btn);
    }

    return btn;
  }
}
