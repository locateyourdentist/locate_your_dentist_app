import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class ChangePasswordWebPage extends StatefulWidget {
  const ChangePasswordWebPage({super.key});
  @override
  State<ChangePasswordWebPage> createState() => _ChangePasswordWebPageState();
}

class _ChangePasswordWebPageState extends State<ChangePasswordWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKeyPassword = GlobalKey<ScaffoldState>();
  final loginController = Get.put(LoginController());
  final _formKeyChangePasswordWeb = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loginController.getAppLogoImage(context);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    return Scaffold(
      key: _scaffoldKeyPassword,
      backgroundColor: AppColors.scaffoldBg,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: Form(
        key: _formKeyChangePasswordWeb,
        child: Row(
          children: [
            if (isLoggedIn && isDesktop) const AdminSideBar(),
            Expanded(
              child: Stack(
                children: [
                  if (isLoggedIn && !isDesktop)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => _scaffoldKeyPassword.currentState?.openDrawer(),
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Container(
                        width: 600,
                        padding: EdgeInsets.all(isMobile ? 20 : 40),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, 10))],
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: GetBuilder<LoginController>(
                          builder: (controller) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLogo(),
                                const SizedBox(height: 20),
                                Text("Change Password", style: AppTextStyles.body(context, color: AppColors.black, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 30),
                                CustomTextField(
                                  hint: "Old Password",
                                  icon: Icons.lock,
                                  isPassword: true,
                                  controller: loginController.oldPasswordController,
                                  validator: (v) => (v == null || v.isEmpty) ? "Password cannot be empty" : null,
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  hint: "New Password",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  controller: loginController.passwordController,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return "Password cannot be empty";
                                    if (v.length < 4) return "Too short";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  hint: "Confirm Password",
                                  icon: Icons.lock_reset,
                                  isPassword: true,
                                  controller: loginController.confirmPasswordController,
                                  validator: (v) => (v != loginController.passwordController.text) ? "Passwords do not match" : null,
                                ),
                                const SizedBox(height: 30),
                                _buildSubmitButton(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 80, width: 80,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: ClipOval(
        child: loginController.appLogoUrl != null
            ? Image.network(loginController.appLogoUrl!, fit: BoxFit.cover)
            : const Icon(Icons.medical_services, size: 40, color: AppColors.primary),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity, height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        onPressed: () {
          if (_formKeyChangePasswordWeb.currentState!.validate()) {
            loginController.changePassword(Api.userInfo.read('userId')??"", loginController.oldPasswordController.text, loginController.confirmPasswordController.text, context);
          }
        },
        child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
