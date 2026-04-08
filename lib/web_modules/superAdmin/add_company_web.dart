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
    final size = MediaQuery.of(context).size.height * 0.01;
    return Scaffold(
      body: GetBuilder<PlanController>(
          builder: (controller) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Container(
                  width: double.infinity,
                  //color: Colors.grey[100],
                  decoration: BoxDecoration(
                    color:AppColors.white,
                     borderRadius: BorderRadius.circular(12),
                    // boxShadow: const [
                    //   BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                    // ],
                  ),
                  child: Form(
                    key: _formKeyAddWebCompanyWeb,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(height: size*0.01,),
                          Text('Add Company Details',style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                          SizedBox(height: size*1,),

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

                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.09,
                              height:MediaQuery.of(context).size.width*0.02,
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
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}
