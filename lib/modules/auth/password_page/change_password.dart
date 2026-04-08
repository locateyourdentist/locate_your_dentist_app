import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/utills/constants.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});
  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}
class _ChangePasswordState extends State<ChangePassword> {
  final loginController=Get.put(LoginController());
  final _formKeyPassword = GlobalKey<FormState>();
  String? confirmPasswordValidator(String? value, TextEditingController passwordController) {
    if (value == null || value.isEmpty) return "Confirm Password cannot be empty";
    if (value != passwordController.text) return "Passwords do not match";
    //if(passwordController.text.length>6) return "Password length must be 6 characters";
    return null;
  }
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
       // title: Text('Change Password',style: AppTextStyles.subtitle(context,color: AppColors.black),),
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKeyPassword,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    loginController.appLogoUrl ?? "",
                    // AppConstants.logoUrl,
                  width: size * 0.6,
                  height: size * 0.45,
                  fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: size * 0.6,
                        height: size * 0.45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade400,
                          size: size * 0.08,
                        ),
                      );
                    },
                              ),
                ),
              ),
                SizedBox(height: size * 0.06),

                Center(child: Text('Change Password',style: AppTextStyles.subtitle(context,color: AppColors.primary),)),
                 const SizedBox(height: 15,),

                // Text('Old Password',style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                // SizedBox(height: size * 0.03),
                CustomTextField(
                  hint: "Old Password",
                  icon: Icons.lock,
                  isPassword: true,
                  controller: loginController.oldPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password cannot be empty";
                   // if (value.length < 6) return "Password must be at least 6 characters";
                    return null;
                  },
                ),
                SizedBox(height: size * 0.03),
                // Text('New Password',style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                // SizedBox(height: size * 0.03),
                CustomTextField(
                  hint: "New Password",
                  icon: Icons.lock,
                  isPassword: true,
                  controller: loginController.passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password cannot be empty";
                    }
                    if (value.length < 4) {
                      return "Password must be at least 6 characters";
                    }
                    // if (!RegExp(r'[a-z]').hasMatch(value)) {
                    //   return "Password must contain at least one lowercase letter";
                    // }
                    // if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    //   return "Password must contain at least one uppercase letter";
                    // }
                    // if (!RegExp(r'[0-9]').hasMatch(value)) {
                    //   return "Password must contain at least one number";
                    // }
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return "Password must contain at least one special character";
                    }
                    return null;
                  },
                ),
                SizedBox(height: size * 0.03),
                // Text('Confirm Password',style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                // SizedBox(height: size * 0.03),

                CustomTextField(
                  hint: "Confirm Password",
                  icon: Icons.lock,
                  isPassword: true,
                  controller: loginController.confirmPasswordController,
                  validator: (value) => confirmPasswordValidator(value, loginController.passwordController),
                ),
                SizedBox(height: size * 0.12),

                Center(
                child: Container(
                  width: size,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent,shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),),
                      onPressed: () async {
                        if (_formKeyPassword.currentState!.validate()) {
                          loginController.changePassword(Api.userInfo.read('userId')??"",loginController.oldPasswordController.text,loginController.confirmPasswordController.text,context);
                        }
                        },
                    child: Text('Submit',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white),),
                  ),
                ),
              )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
