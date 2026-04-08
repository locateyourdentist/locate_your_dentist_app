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

class AddGstDetailsWeb extends StatefulWidget {
  const AddGstDetailsWeb({super.key});

  @override
  State<AddGstDetailsWeb> createState() => _AddGstDetailsWebState();
}

class _AddGstDetailsWebState extends State<AddGstDetailsWeb> {
  final planController=Get.put(PlanController());
  final _formKeyGstWeb = GlobalKey<FormState>();
  @override
  void initState(){
    super.initState();
    planController.getGstDetails(context);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Form(
        key: _formKeyGstWeb,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child:  Container(
                width: double.infinity,
                //color: Colors.grey[100],
                decoration: BoxDecoration(
                  color:AppColors.white,
                  borderRadius: BorderRadius.circular(12),),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(height: size*0.01,),
                      Text('Add GST Details',style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                      SizedBox(height: size*0.02,),

                      buildSwitchRow(
                        label: "Show GST",
                        value: planController.isShowGst,
                        onChanged: (val) => setState(() {
                          planController.isShowGst = val;
                          planController.update();
                        }),
                      ),
                      SizedBox(height: size * 0.02),

                      CustomTextField(
                        hint: "SGST",
                        icon: Icons.receipt_long,
                        controller: planController.cgstController,
                        //fillColor: Colors.white,
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        //borderColor: Colors.grey,
                      ),
                      SizedBox(height: size * 0.02),
                      CustomTextField(
                        hint: "CGST",
                        icon: Icons.receipt_long,
                        controller: planController.sgstController,
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        // fillColor: Colors.white,
                        // borderColor: Colors.grey,
                      ),
                      SizedBox(height: size * 0.02),
                      CustomTextField(
                        hint: "IGST",
                        icon: Icons.receipt_long,
                        controller: planController.igstController,
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        // fillColor: Colors.white,
                        // borderColor: Colors.grey,
                      ),
                      SizedBox(height: size * 0.02),
                      Container(
                        width: size*0.15,
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
                            if (_formKeyGstWeb.currentState!.validate()) {
                              await  planController.addGstDetails(
                                  Api.userInfo.read('userId') ?? "",
                                  planController.selectedState.toString(),
                                  planController.cgstController.text.toString(),
                                  planController.sgstController.text.toString(),
                                  planController.igstController.text.toString(),planController.isShowGst,
                                  context);
                            }
                            planController.cgstController.clear();
                            planController.igstController.clear();
                            planController.sgstController.clear();
                            planController.selectedState=='';
                            planController.selectedState==null;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  Colors.transparent,shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:  Text("Save", style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(height: size * 0.03),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GetBuilder<PlanController>(
        builder: (controller) {
          return  Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body(context, fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                activeColor: AppColors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.blueGrey.shade600,
                inactiveTrackColor: Colors.grey.shade400,
                splashRadius: 50.0,
                value: value,
                onChanged: onChanged,
              ),
            ],
          );
        }
    );
  }
}
