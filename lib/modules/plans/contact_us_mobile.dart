import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:get/get.dart';

import '../../model/contact_model_web.dart';
class ContactsMobilePage extends StatefulWidget {
  const ContactsMobilePage({super.key});

  @override
  State<ContactsMobilePage> createState() => _ContactsMobilePageState();
}

class _ContactsMobilePageState extends State<ContactsMobilePage> {
  String? selectedState;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final contactController=Get.put(ContactController());
  final _formKeyPublicContactProfile = GlobalKey<FormState>();
  final loginController=Get.put(LoginController());

  List<Map<String, dynamic>> contacts = [];

  List<String> states = [
    "All",
    "Tamil Nadu",
    "Kerala",
    "Andhra Pradesh",
  ];

  @override
  void initState() {
    super.initState();
    loginController.getAllContacts(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/contactss.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary
                        // color: Colors.black.withOpacity(0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Get In Touch",
                            style: AppTextStyles.headline(
                              context,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Have questions or need help? Our team is here to support you.",
                            style: AppTextStyles.caption(
                              context,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Contact Locations",
                      style: AppTextStyles.subtitle(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.contactListApi.length,
                    itemBuilder: (context, index) {
                      return _modernContactCard(
                        controller.contactListApi[index],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: contactForm(),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),

    );
  }
  Widget _buildContactList(LoginController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: controller.contactListApi.length,
      itemBuilder: (context, index) {
        return _modernContactCard(
          controller.contactListApi[index],
        );
      },
    );
  }
  Widget contactForm() {
    final size = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
          )
        ],
      ),
      child: Form(
        key: _formKeyPublicContactProfile,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Send a Contact Request",
              style: AppTextStyles.subtitle(context),
            ),

            const SizedBox(height: 20),

            CustomTextField(
              hint: "Name",
              icon: Icons.person,
              controller: nameController,
            ),
            SizedBox(height: size * 0.03),
            CustomTextField(
                hint: "Email",
                icon: Icons.email,
                controller: emailController,
                keyboardType: TextInputType.emailAddress
            ),
            SizedBox(height: size * 0.03),

            CustomTextField(
              hint: "Mobile Number",
              icon: Icons.phone,
              controller: phoneController,
              keyboardType: TextInputType.number,
              maxLength: 10,
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
            SizedBox(height: size * 0.03),

            CustomTextField(
              hint: " Message",
              icon: Icons.text_fields,
              controller: messageController,
              fillColor: Colors.grey.shade100,
              borderColor: AppColors.white,maxLines: 5,
            ),

            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: size*0.25,
                child: ElevatedButton(
                  onPressed: ()async{
                    if (_formKeyPublicContactProfile.currentState!.validate()) {
                      await contactController.postPublicContactDetail(
                          emailController.text, phoneController.text,
                          nameController.text, messageController.text, context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child:  Text("Submit",style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _modernContactCard(ContactApiModel contact) {
    final size = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.06),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// STATE HEADER
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.white, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  contact.state,
                  style: AppTextStyles.caption(
                    context,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// NAME
          Text(
            contact.name,
            style: AppTextStyles.caption(
              context,                    color: AppColors.black,

              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: () {
              launchCall("tel:${contact.mobileNumber}");
            },
            child: Row(
              children: [
                 Icon(Icons.phone, size: size*0.04, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  contact.mobileNumber,
                  style: AppTextStyles.caption(context,                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          InkWell(
            onTap: () {
              sendEmail("mailto:${contact.email}");
            },
            child: Row(
              children: [
                 Icon(Icons.email, size: size*0.04, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contact.email,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(context,                    color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}