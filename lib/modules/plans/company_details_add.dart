import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:get/get.dart';

class CompanyForm extends StatefulWidget {
  const CompanyForm({super.key});
  @override
  State<CompanyForm> createState() => _CompanyFormState();
}
class _CompanyFormState extends State<CompanyForm> {
  final _formKeyAddCompany = GlobalKey<FormState>();
  final planController=Get.put(PlanController());
  String? selectedCategory;
  @override
  void initState(){
    super.initState();
    planController.getCompanyDetails();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height * 0.01;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text('Add Company Details',style: AppTextStyles.subtitle(context,color: AppColors.black),),
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
      body: GetBuilder<PlanController>(
          builder: (controller) {
            return Form(
            key: _formKeyAddCompany,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (controller.isLoading)
              const CircularProgressIndicator(),

                  CustomTextField(
                    hint: "Company Name",
                    icon: Icons.business,
                    controller: planController.companyNameController,
                    // fillColor: Colors.white,
                    // borderColor: Colors.grey,
                  ),
                  SizedBox(height: size * 2),

                  CustomTextField(
                    hint: "GST",
                    icon: Icons.receipt_long,
                    controller: planController.gstinController,
                    // fillColor: Colors.white,
                    // borderColor: Colors.grey,
                  ),
                  SizedBox(height: size * 2),

                  // CustomTextField(
                  //   hint: "Address",
                  //   icon: Icons.location_on,
                  //   controller: addressController,
                  //   fillColor: Colors.white,
                  //   borderColor: Colors.grey,
                  //   //maxLines: 3,
                  // ),

                  CustomTextField(
                    hint: "Street",
                    icon: Icons.receipt_long,
                    controller: planController.streetController,
                    // fillColor: Colors.white,
                    // borderColor: Colors.grey,
                  ),
                  SizedBox(height: size * 2),

                  CustomTextField(
                    hint: "City",
                    icon: Icons.receipt_long,
                    controller: planController.cityController,
                    // fillColor: Colors.white,
                    // borderColor: Colors.grey,
                  ),
                  SizedBox(height: size * 2),
                  CustomTextField(
                    hint: "State",
                    icon: Icons.receipt_long,
                    controller: planController.stateController,
                    // fillColor: Colors.white,
                    // borderColor: Colors.grey,
                  ),
                  SizedBox(height: size * 2),
                  CustomTextField(
                    hint: "pin code",
                    icon: Icons.receipt_long,
                    controller: planController.zipController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    // fillColor: Colors.white,
                    // borderColor: Colors.grey,
                  ),
                  SizedBox(height: size * 2),
                  CustomTextField(
                    hint: "Email",
                    icon: Icons.email,
                    controller: planController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    // fillColor: Colors.white,
                    // borderColor: Colors.grey,
                  ),
                  SizedBox(height: size * 2),

                  CustomTextField(
                    hint: "Phone",
                    icon: Icons.phone,
                    controller: planController.phoneController,
                    keyboardType: TextInputType.phone,
                    // fillColor: Colors.white,
                    // borderColor: Colors.grey,
                    maxLength: 10,
                  ),
                  SizedBox(height: size * 3),

                  Container(
                    width: double.infinity,
                    height:MediaQuery.of(context).size.width*0.13,
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
                        if (_formKeyAddCompany.currentState!.validate()) {
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
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:  Text("Save", style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold)),
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
