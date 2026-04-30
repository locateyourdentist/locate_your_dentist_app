import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';

class AppTextStyles {
  static double _scaleText(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;

    const mobileBase = 375.0;
    const webBase = 1400.0;

    if (width < 600) {
      return size * (width / mobileBase);
    } else {
      final scale = (width / webBase).clamp(0.8, 1.5);
      return size * scale;
    }
  }

  static TextStyle headline1(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: _scaleText(context, 30),
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
      color: color ?? const Color(0xFF111111),
    );
  }

  static TextStyle headline(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: _scaleText(context, 24),
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.25,
      color: color ?? const Color(0xFF111111),
    );
  }

  static TextStyle subtitle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: _scaleText(context, 15),
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: color ?? const Color(0xFF333333),
    );
  }
  static TextStyle body(BuildContext context,
      {Color? color, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: _scaleText(context, 13),
      fontWeight: fontWeight ?? FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.1,
      color: color ?? const Color(0xFF444444),
    );
  }

  static TextStyle caption(BuildContext context,
      {Color? color, FontWeight? fontWeight, double? height}) {
    return GoogleFonts.poppins(
      fontSize: _scaleText(context, 10),
      fontWeight: fontWeight ?? FontWeight.w400,
      height: height ?? 1.2,
      letterSpacing: 0.1,
      color: color ?? AppColors.black,
    );
  }
}