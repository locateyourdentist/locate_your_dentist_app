import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
double getResponsiveFontSize(BuildContext context) {
  double width = MediaQuery.of(context).size.width;

  double base;

  if (width < 600) {
    base = 14; // mobile
  } else if (width < 1000) {
    base = 16; // tablet
  } else {
    base = 15; // desktop
  }

  return base;
}
void showCustomToast(
    BuildContext context,

    String message, {
      Color? backgroundColor,
      Color? textColor,
      Duration duration = const Duration(seconds: 2),
    }) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary,AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              color: backgroundColor ?? AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Text(
              message,
              softWrap: true,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: getResponsiveFontSize(context),
             //  fontSize: MediaQuery.of(context).size.width * 0.006,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
