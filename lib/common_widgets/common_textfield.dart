import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;
  final Color? fillColor;
  final Color? borderColor;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  const CustomTextField({
    Key? key,
    required this.hint,
     this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.maxLength,
    this.maxLines,
    this.fillColor,
    this.borderColor,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}
class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }
  @override
  Widget build(BuildContext context) {
    final Color fill = widget.fillColor ?? Colors.grey[100]!;
    final Color outerBorderColor = widget.borderColor ?? Colors.white;
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      maxLines: widget.maxLines ?? 1,
      style: AppTextStyles.caption(context),
      keyboardType: widget.keyboardType ?? TextInputType.text,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
        labelText: widget.hint,
        labelStyle: AppTextStyles.caption(context, color: AppColors.grey),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
        filled: true,
        fillColor: fill,
        //keyboardType: widget.keyboardType ?? TextInputType.text,
        contentPadding: EdgeInsets.symmetric(
          vertical: widget.maxLines != null && widget.maxLines! > 1 ? 16 : 12,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outerBorderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outerBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: widget.validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return "${widget.hint} cannot be empty";
            }
            if (widget.hint.toLowerCase() == "email" &&
                !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                    .hasMatch(value)) {
              return "Enter a valid email";
            }
            return null;
          },
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final String hint;
 // final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final Color? fillColor;
  final Color? borderColor;
  const CustomDropdownField({
    Key? key,
    required this.hint,
    //required this.icon,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
     this.fillColor,
     this.borderColor
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //final Color outerBorderColor = borderColor ?? Colors.white;
    //final Color fill = fillColor ?? Colors.grey[100]!;
    final Color fill = fillColor ?? Colors.grey[100]!;
    final Color outerBorderColor = borderColor ?? Colors.white;
    return SizedBox(
      //height: size.width * 0.16,
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: hint,
          labelText: hint,
          hintStyle: AppTextStyles.caption(context,fontWeight: FontWeight.normal, color: AppColors.grey),
          labelStyle: AppTextStyles.caption(context,fontWeight: FontWeight.normal, color: AppColors.grey),
          //prefixIcon: Icon(icon, color: AppColors.grey),
          filled: true,
          fillColor: fill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: outerBorderColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: outerBorderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        //   border: OutlineInputBorder(
        //     borderRadius: BorderRadius.circular(12),
        //     borderSide:  BorderSide(color: outerBorderColor, width: 1.5),
        //   ),enabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(10),
        //   borderSide:  BorderSide(color: outerBorderColor, width: 1.5),
        // ),
        //   focusedBorder: OutlineInputBorder(
        //     borderRadius: BorderRadius.circular(10),
        //     borderSide: const BorderSide(color: AppColors.primary, width: 2),
        //   ),

          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedValue,
            style: AppTextStyles.caption(context, color: Colors.black,),
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e,textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(context, color: AppColors.black,fontWeight: FontWeight.normal),),
              ),
            ).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
