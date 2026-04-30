import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:get/get.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class AddContactFormWeb extends StatefulWidget {
  const AddContactFormWeb({super.key});
  @override
  State<AddContactFormWeb> createState() => _AddContactFormWebState();
}
class _AddContactFormWebState extends State<AddContactFormWeb> {
  final _formKeyAddContactStateWeb = GlobalKey<FormState>();
  final planController=Get.put(PlanController());
  final loginController=Get.put(LoginController());
  String? selectedCategory;
  @override
  void initState(){
    super.initState();
    loginController.fetchStates();
    loginController.addContactField();
    loginController.getAllContacts(context);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height * 0.01;
    return Scaffold(
      body: GetBuilder<LoginController>(
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
                  child:Form(
                    key: _formKeyAddContactStateWeb,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(height: size*0.01,),
                          Text('Add Contact Details',style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                          SizedBox(height: size*1,),

                          if (controller.isLoading)
                            const CircularProgressIndicator(),
                          SizedBox(height: size * 3),
                          Align(
                            alignment: Alignment.topRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              onPressed: () => loginController.addContactField(),
                              icon:  Icon(Icons.add,size: size*0.05,color: AppColors.primary),
                              label:  Text("Add Contact",style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold),),
                            ),
                          ),
                          GetBuilder<LoginController>(
                          builder: (controller) {
                          return Column(
                          children: [
                            for (int i = 0; i < loginController.contactList.length; i++)
                              _addContactFields(i,size),
                          ]);}),
                          const SizedBox(height: 40,),

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


                                onPressed: () async {
                                    if (_formKeyAddContactStateWeb.currentState!.validate()) {
                                      bool hasInvalidState = loginController.contactList.any(
                                            (e) => e.state.text.trim().isEmpty,
                                      );

                                      if (hasInvalidState) {
                                        Get.snackbar("Error", "Please select state for all contacts");
                                        return;
                                      }
                                      final List<Map<String, dynamic>> contactListJson = loginController.contactList.map((e) {
                                        return {
                                          "name": e.name.text.trim(),
                                          "state": e.state.text.trim(),
                                          "mobileNumber": e.mobile.text.trim(),
                                          "whatsapp": e.whatsapp.text.trim(),
                                          "email": e.email.text.trim(),
                                        };
                                      }).toList();

                                      final Map<String, dynamic> finalJson = {
                                        "userId": Api.userInfo.read('userId'),
                                        "details": contactListJson,
                                      };
                                      print('final JSON map: $finalJson');
                                      await planController.addContactDetailsStateWise(
                                        details: finalJson, context: context,
                                      );
                                    }
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
  Widget _addContactFields(int index,size) {
    final loginController=Get.put(LoginController());
    final exp = loginController.contactList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text("Contact ${index + 1}", style: AppTextStyles.caption(context,fontWeight: FontWeight.bold)),
              SizedBox(height: size*2,),
              if (index > 0)
                GetBuilder<LoginController>(
                    builder: (controller) {
                      return IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => loginController.removeContactListField(index),
                      );
                    }
                ),
            ],
          ),
          GetBuilder<LoginController>(
            builder: (controller) {
              final items=controller.states.map((d) => d.toString()).toList();
              return CustomDropdown<String>.search(
                hintText: "Select State",
                decoration: CustomDropdownDecoration(
                  closedFillColor: Colors.grey[100],
                  expandedFillColor: Colors.white,
                  closedBorder: Border.all(
                    color: AppColors.white,
                    width: 1.5,
                  ),
                  expandedBorder: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  closedBorderRadius: BorderRadius.circular(10),
                  expandedBorderRadius: BorderRadius.circular(10),
                  hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                  headerStyle: AppTextStyles.caption(context, color: Colors.black),
                  listItemStyle: AppTextStyles.caption(context, color: Colors.black),),
                items: controller.states.map((s) => s.toString()).toList(),
                //initialItem: controller.selectedState,
                initialItem: items.contains(exp.state.text)
                    ? exp.state.text
                    : null,
                onChanged: (val) {
                  if (val != null) {
                    //controller.selectedState = val;
                    exp.state.text=val;
                    controller.districts.clear();
                    controller.selectedDistrict = null;
                    controller.selectedTaluka = null;
                    controller.selectedVillage = null;
                    final state = controller.states.firstWhere((s) => s == val);
                    print('state  selected$state');
                    controller.fetchDistricts(state.toString());
                    controller.update();
                  }
                },
              );
            },
          ),
          SizedBox(height: size * 2),

          CustomTextField(
            hint: "Name",
            controller: exp.name,
          ),
          SizedBox(height: size * 2),
          CustomTextField(
            hint: "Whatsapp",
            controller: exp.whatsapp,
            maxLength: 10,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Mobile Number cannot be empty";
              }
              if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                return "Enter a valid 10-digit mobile number starting with 6-9";
              }
              return null;
            },
          ),
          SizedBox(height: size * 2),
          CustomTextField(
            hint: "email",
            controller: exp.email,
            keyboardType: TextInputType.emailAddress,

          ),
          SizedBox(height: size * 2),

          CustomTextField(
            hint: "Mobile Number",
            controller: exp.mobile,
            maxLength: 10,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Mobile Number cannot be empty";
              }
              if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                return "Enter a valid 10-digit mobile number starting with 6-9";
              }
              return null;
            },
          ),
          SizedBox(height: size * 3),

        ],
      ),
    );
  }

}
