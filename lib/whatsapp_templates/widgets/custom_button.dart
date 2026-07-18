import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';

/// Reusable gradient/outlined action button for the WhatsApp template
/// feature. No CustomButton exists elsewhere in the app yet — this mirrors
/// the gradient-container-over-ElevatedButton recipe already used inline in
/// create_notification_web.dart.
class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool isLoading;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.outlined = false,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? (color ?? AppColors.primary) : Colors.white,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18, color: outlined ? (color ?? AppColors.primary) : Colors.white),
        if (isLoading || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AppTextStyles.caption(
              context,
              fontWeight: FontWeight.w600,
              color: outlined ? (color ?? AppColors.primary) : Colors.white,
            ),
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color ?? AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: content,
      );
    }

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color ?? AppColors.primary, color ?? AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: content,
        ),
      ),
    );
  }
}
