import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_app_logo_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_company_web.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_contact_details.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/add_gst_web.dart';
import 'package:get/get.dart';


class SettingsPageWeb extends StatefulWidget {
  const SettingsPageWeb({super.key});

  @override
  State<SettingsPageWeb> createState() => _SettingsPageWebState();
}

class _SettingsPageWebState extends State<SettingsPageWeb> {
  @override
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final loginController=Get.put(LoginController());

  final _formKeyChangePasswordWeb1 = GlobalKey<FormState>();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  String? confirmPasswordValidator(
      String? value, TextEditingController passwordController) {
    if (value == null || value.isEmpty) return "Confirm Password cannot be empty";
    if (value != passwordController.text) return "Passwords do not match";
    return null;
  }

  // Common Password Field
  Widget passwordField() {
    return   CustomTextField(
      hint: "Password",
      icon: Icons.lock,
      isPassword: true,
      controller: loginController.passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password cannot be empty";
        }
        if (value.length < 4) {
          return "Password must be at least 4 characters";
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
    );
  }

  // Common Confirm Password Field
  Widget confirmPasswordField() {
    return CustomTextField(
      hint: "Confirm Password",
      icon: Icons.lock,
      isPassword: true,
      controller: loginController.confirmPasswordController,
      validator: (value) => confirmPasswordValidator(value, loginController.passwordController),
    );
  }
  Widget submitButton() {
    return SizedBox(
      width: 100,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_formKeyChangePasswordWeb1.currentState!.validate()) {
            loginController.changePassword(Api.userInfo.read('userId')??"",loginController.oldPasswordController.text,loginController.confirmPasswordController.text,context);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.transparent,
          elevation: 5,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "Submit",
              style: AppTextStyles.caption(
                context,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget build(BuildContext context) {
    double s=MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        //backgroundColor: const Color(0xffF5F7FB),
        backgroundColor: AppColors.scaffoldBg,
        appBar: CommonWebAppBar(
          height: s * 0.08,
          title: "LYD",
          onLogout: () {
          },
          onNotification: () {
          },
         ),
        body:  Row(
          children: [
            const AdminSideBar(),

            Expanded(
              child: Padding(
                padding:  const EdgeInsets.all(30.0),
                child:Center(
                  child: ConstrainedBox(
                    constraints:  const BoxConstraints(maxWidth: 900),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Settings',style: AppTextStyles.subtitle(context),),
                         SizedBox(height: s*0.005,),
                        Text(
                          'Manage your account, company details and preferences',
                          style: AppTextStyles.caption(
                            context,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: s*0.01,),
                        TabBar(
                          indicatorWeight: 3,
                          indicatorColor: AppColors.black,
                          labelColor: AppColors.black,
                          tabs: [
                            Tab(child: SizedBox(
                              width: s*0.07,
                              child: Center(child: Text("Change Password",style: AppTextStyles.caption(context,fontWeight: FontWeight.w500),)),
                            )),
                            Tab(child: SizedBox(
                              width: s*0.07,
                              child: Center(child: Text("Change Logo",style: AppTextStyles.caption(context,fontWeight: FontWeight.w500),)),
                            )),
                            Tab(child: SizedBox(
                              width: s*0.07,
                              child: Center(child: Text("Add GST",style: AppTextStyles.caption(context,fontWeight: FontWeight.w500),)),
                            )),
                            Tab(child: SizedBox(
                              width: s*0.07,
                              child: Center(child: Text("Add Company Details",style: AppTextStyles.caption(context,fontWeight: FontWeight.w500))),
                            )),
                            Tab(child: SizedBox(
                              width: s*0.07,
                              child: Center(child: Text("Add Contact Details",style: AppTextStyles.caption(context,fontWeight: FontWeight.w500))),
                            )),
                          ],
                        ),
                          Expanded(
                          child: TabBarView(
                            children: [
                              //ChangePasswordTab(),
                            // ChangePasswordWebPage(),
                              Container(
                                width: double.infinity,
                                //color: Colors.grey[100],
                                decoration: BoxDecoration(
                                  color:AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  // boxShadow: const [
                                  //   BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                  // ],
                                ),

                                child: Column(
                                  children: [
                                    Form(
                                      key: _formKeyChangePasswordWeb1,
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [ AppColors.scaffoldBg, AppColors.scaffoldBg,],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                          ),

                                          Center(
                                            child: Container(
                                              width: double.infinity,
                                              //width: size.width > 800 ? 450 : size.width * 0.85,
                                              padding: const EdgeInsets.all(40),
                                              decoration: BoxDecoration(
                                                color: AppColors.white,
                                                //.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(0),
                                                // boxShadow: [
                                                //   BoxShadow(
                                                //     color: Colors.black.withOpacity(0.2),
                                                //     blurRadius: 20,
                                                //     offset: const Offset(0, 10),
                                                //   ),
                                                // ],
                                                border: Border.all(
                                                  color: Colors.white,
                                                  //.withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child:  GetBuilder<LoginController>(
                                                  init: loginController,
                                                  builder: (controller) {
                                                    return Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        SizedBox(
                                                          height: 80,
                                                          width: 80,
                                                          child: ClipOval(
                                                            child: loginController.appLogoUrl != null
                                                                ? Image.network(
                                                              loginController.appLogoUrl!,
                                                              fit: BoxFit.cover,
                                                              width: 80,
                                                              height: 80,
                                                            )
                                                                : Container(
                                                              color: Colors.white.withOpacity(0.3),
                                                              child: const Icon(
                                                                Icons.medical_services,
                                                                size: 50,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 20),

                                                        Text(
                                                          "Change Password",
                                                          style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                                                        //const SizedBox(height: 10),
                                                        // Text(
                                                        //   "Forgot Password",
                                                        //   style: AppTextStyles.caption(context,color: AppColors.white),),
                                                        // const SizedBox(height: 30),
                                                        const SizedBox(height: 20),

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
                                                        const SizedBox(height: 20),
                                                        passwordField(),
                                                        const SizedBox(height: 20),
                                                        confirmPasswordField(),
                                                        const SizedBox(height: 30),
                                                        submitButton(),
                                                        const SizedBox(height: 20),

                                                      ],
                                                    );
                                                  }
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const ChangeAppLogoWeb(),
                              const AddGstDetailsWeb(),
                              const CompanyFormWeb(),

                              AddContactFormWeb()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
