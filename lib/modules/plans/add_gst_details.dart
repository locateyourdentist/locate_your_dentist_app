import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:get/get.dart';

class AddGstDetails extends StatefulWidget {
  const AddGstDetails({super.key});

  @override
  State<AddGstDetails> createState() => _AddGstDetailsState();
}

class _AddGstDetailsState extends State<AddGstDetails> {
  final planController=Get.put(PlanController());
  final _formKeyGst = GlobalKey<FormState>();
  @override
  void initState(){
    super.initState();
    planController.getGstDetails(context);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text('Add GST Details',style: AppTextStyles.subtitle(context,color: AppColors.black),),
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
        key: _formKeyGst,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                SizedBox(height: size * 0.06),
                // CustomDropdownField(
                //   hint: "Select State",
                //   //icon: Icons.person_outline,
                //   borderColor: AppColors.grey,
                //   fillColor: AppColors.white,
                //   items: const [
                //     "Tamilnadu",
                //     "Karnataka",
                //     "Andhra Pradesh",
                //     "Kerala",
                //   ],
                //   selectedValue: planController.selectedState?.isEmpty == true
                //       ? null
                //       : planController.selectedState,
                //   onChanged: (value) {
                //     setState(() {
                //       planController.selectedState = value;
                //       // _updateFields();
                //     });
                //   },
                // ),
                buildSwitchRow(
                  label: "Show GST",
                  value: planController.isShowGst,
                  onChanged: (val) => setState(() {
                    planController.isShowGst = val;
                    planController.update();
                  }),
                ),
                CustomTextField(
                  hint: "SGST",
                  icon: Icons.receipt_long,
                  controller: planController.cgstController,
                  //fillColor: Colors.white,
                  maxLength: 2,
                  keyboardType: TextInputType.number,
                  //borderColor: Colors.grey,
                ),
                SizedBox(height: size * 0.03),
                CustomTextField(
                  hint: "CGST",
                  icon: Icons.receipt_long,
                  controller: planController.sgstController,
                  maxLength: 2,
                  keyboardType: TextInputType.number,
                  // fillColor: Colors.white,
                  // borderColor: Colors.grey,
                ),
                SizedBox(height: size * 0.03),
                CustomTextField(
                  hint: "IGST",
                  icon: Icons.receipt_long,
                  controller: planController.igstController,
                  maxLength: 2,
                  keyboardType: TextInputType.number,
                  // fillColor: Colors.white,
                  // borderColor: Colors.grey,
                ),
                SizedBox(height: size * 0.03),
                Container(
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

                    onPressed: () async{
                      if (_formKeyGst.currentState!.validate()) {
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
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
