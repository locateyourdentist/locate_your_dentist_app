import 'package:flutter/material.dart';
import 'package:locate_your_dentist/utills/app_color.dart';

class ColorBackground extends StatelessWidget {
  final Widget child;
  const ColorBackground({required Key key, required this.child,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      color: AppColors.backgroundColor,
    );
  }
}
