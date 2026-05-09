import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class CompanyFormWeb extends StatefulWidget {
  const CompanyFormWeb({super.key});
  @override
  State<CompanyFormWeb> createState() => _CompanyFormWebState();
}
class _CompanyFormWebState extends State<CompanyFormWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKeyAddWebCompanyWeb = GlobalKey<FormState>();
  final planController=Get.put(PlanController());
  String? selectedCategory;
  @override
  void initState(){
    super.initState();
    planController.getCompanyDetails();
  }
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
      drawer: !isDesktop ? const Drawer(width: 250, child: AdminSideBar()) : null,
      // appBar: CommonWebAppBar(
      //   height: isMobile ? 60 : 80,
      //   title: "LYD",
      //   onLogout: () {},
      //   onNotification: () {},
      // ),
      body: GetBuilder<PlanController>(
          builder: (controller) {
            return Row(
              children: [
               // if (isDesktop) const AdminSideBar(),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(isMobile ? 10 : 30),
                        decoration: BoxDecoration(
                          color:AppColors.white,
                           borderRadius: BorderRadius.circular(12),
                           boxShadow: const [
                             BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                           ],
                        ),
                        child: Form(
                          key: _formKeyAddWebCompanyWeb,
                          child: Stack(
                            children: [
                              // if (!isDesktop)
                              //   Positioned(
                              //     top: 10,
                              //     left: 10,
                              //     child: IconButton(
                              //       icon: const Icon(Icons.menu),
                              //       onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                              //     ),
                              //   ),
                              SingleChildScrollView(
                                padding: EdgeInsets.all(isMobile ? 15 : 30),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20,),
                                    Text('Add Company Details',style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                                    const SizedBox(height: 20,),
                                    
                                    if (controller.isLoading)
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 20.0),
                                        child: CircularProgressIndicator(),
                                      ),
                
                                    CustomTextField(
                                      hint: "Company Name",
                                      icon: Icons.business,
                                      controller: planController.companyNameController,
                                    ),
                                    const SizedBox(height: 15),
                
                                    CustomTextField(
                                      hint: "GST",
                                      icon: Icons.receipt_long,
                                      controller: planController.gstinController,
                                    ),
                                    const SizedBox(height: 15),
                
                                    CustomTextField(
                                      hint: "Street",
                                      icon: Icons.receipt_long,
                                      controller: planController.streetController,
                                    ),
                                    const SizedBox(height: 15),
                
                                    CustomTextField(
                                      hint: "City",
                                      icon: Icons.receipt_long,
                                      controller: planController.cityController,
                                    ),
                                    const SizedBox(height: 15),
                                    CustomTextField(
                                      hint: "State",
                                      icon: Icons.receipt_long,
                                      controller: planController.stateController,
                                    ),
                                    const SizedBox(height: 15),
                                    CustomTextField(
                                      hint: "pin code",
                                      icon: Icons.receipt_long,
                                      controller: planController.zipController,
                                      maxLength: 6,
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 15),
                                    CustomTextField(
                                      hint: "Email",
                                      icon: Icons.email,
                                      controller: planController.emailController,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 15),
                
                                    CustomTextField(
                                      hint: "Phone",
                                      icon: Icons.phone,
                                      controller: planController.phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                    ),
                                    const SizedBox(height: 30),
                
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                        width: isMobile ? double.infinity : 200,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppColors.primary, AppColors.secondary],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ElevatedButton(
                
                                          onPressed: () async{
                                            if (_formKeyAddWebCompanyWeb.currentState!.validate()) {
                                              final address = {
                                                "street": planController.streetController.text,
                                                "city": planController.cityController.text,
                                                "state": planController.stateController.text,
                                                "pincode": planController.zipController.text,
                                              };
                                              await  planController.addCompanyDetails(
                                                  Api.userInfo.read('userId') ?? "",
                                                  planController.companyNameController.text.toString(),
                                                  planController.gstinController.text.toString(),
                                                  address,
                                                  planController.emailController.text.toString(),
                                                  planController.phoneController.text.toString(),
                                                  context);
                                            }
                                            //print("Company Saved: $companyData");
                                            planController.streetController.clear();
                                            planController.cityController.clear();
                                            planController.stateController.clear();
                                            planController.zipController.clear();
                                            planController.companyNameController.clear();
                                            planController.gstinController.clear();
                                            planController.emailController.clear();
                                            planController.phoneController.clear();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,shadowColor:Colors.transparent ,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child:  Text("Save", style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 40,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }
}
