import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';

class BranchSelectionPage extends StatefulWidget {
  const BranchSelectionPage({super.key});
  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}
class _BranchSelectionPageState extends State<BranchSelectionPage> with SingleTickerProviderStateMixin {
  String? selectedUserId;
final loginController=Get.put(LoginController());
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String? name1;
  String? pageRoute;
  @override
  void initState() {
    super.initState();
     pageRoute = Get.arguments?['page'] ??"";
     loginController.getBranchDetails(context);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final branches = loginController.userBranchesList;
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,backgroundColor: AppColors.white,
          title: Text("Select Branch",
            style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),),automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Get.back();
                //Navigator.pop(context);
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
      body: GetBuilder<LoginController>(
          builder: (controller) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  Expanded(
                    child: branches.isEmpty
                        ?  Center(child: Text("No branches found",style:AppTextStyles.caption(context),))
                        : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: branches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final branch = branches[index];
                        final name = branch.details['name'] ?? '';
                        final city = branch.address['city'] ?? '';
                        final district = branch.address['district'] ?? '';
                        final state = branch.address['state'] ?? '';

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedUserId == branch.userId
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            color: selectedUserId == branch.userId
                                ? Theme.of(context)
                                .primaryColor
                                .withOpacity(0.05)
                                : Colors.white,
                          ),
                          child: RadioListTile<String>(
                            value: branch.userId,
                            groupValue: selectedUserId,
                            title: Text(
                              name,
                              style:  const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text("$city, $district\n$state"),
                            isThreeLine: true,
                            onChanged: (value) {
                              setState(() {
                                selectedUserId = value;
                                name1=branch.details['name'] ??"";
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  //  Bottom Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child:  Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: selectedUserId == null
                            ? null
                            : () async{
                          pageRoute=='dashboard'?
                          Get.toNamed('/dentalClinicDashboard'): Get.toNamed('/viewPlanPage',arguments: {'selectedUserId':selectedUserId});
                          Api.userInfo.write("userId", selectedUserId ?? "");
                          Api.userInfo.write("name", name1);
                          //Get.back(result: selectedUserId);
                          String platform = kIsWeb
                              ? "Web"
                              : Platform.isAndroid
                              ? "Android"
                              : Platform.isIOS
                              ? "iOS"
                              : "Unknown";
                          await loginController.switchAccountLogin(
                            selectedUserId.toString(),platform,context);
                          await loginController.getProfileByUserId(selectedUserId.toString(), context);

                        },
                        style: ElevatedButton.styleFrom( backgroundColor:selectedUserId==null?  AppColors.transparent:AppColors.transparent,
                          shadowColor: AppColors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:  Text(
                          "Continue",
                          style: TextStyle(fontSize: size*0.035,color:selectedUserId==null?  AppColors.white:AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
