import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:get/get.dart';
import '../../model/contact_model_web.dart';


class ContactsWebPage extends StatefulWidget {
  const ContactsWebPage({super.key});

  @override
  State<ContactsWebPage> createState() => _ContactsWebPageState();
}

class _ContactsWebPageState extends State<ContactsWebPage> {
  String? selectedState;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final contactController=Get.put(ContactController());
  final _formKeyPublicContactProfile = GlobalKey<FormState>();
  final loginController=Get.put(LoginController());

  List<Map<String, dynamic>> contacts = [];
  @override
  void initState() {
    super.initState();
    loginController.getAllContacts(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    PreferredSizeWidget buildAppBar() {
      if (Api.userInfo.read('token') != null) {
        return CommonWebAppBar(
          height: width * 0.03,
          title: "LYD",
          onLogout: () {},
          onNotification: () {},
        );
      } else {
        return CommonHeader();
      }
    }
    return Scaffold(
      appBar: buildAppBar(),
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return Row(
            children: [
              Api.userInfo.read('token') != null?AdminSideBar():SizedBox(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      Container(
                        height: width * 0.25,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/cc.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                "Get In Touch",
                                style: AppTextStyles.headline(
                                  context,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Have questions or need help? Our team is here to support you.",
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption(
                                  context,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Transform.translate(
                        offset: const Offset(0, -80),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary,AppColors.secondary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: contactForm(),
                            ),
                          ),
                        ),
                      ),


                      SizedBox(
                          width: 1000,
                          child: Column(
                              children: [
                                Center(child: Text("All Contact Details",style: AppTextStyles.subtitle(context,color: AppColors.black),)),
                                const SizedBox(height: 20),

                                _buildContactList(controller)

                             ])
                             ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildContactList(LoginController controller) {
    double width = MediaQuery.of(context).size.width;

    int crossAxisCount = 3;
    if (width < 1000) crossAxisCount = 2;
    if (width < 600) crossAxisCount = 1;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.contactListApi.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
        ),
        itemBuilder: (context, index) {
          return _modernContactCard(controller.contactListApi[index]);
        },
      ),
    );
  }  Widget contactForm() {
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
            SizedBox(height: size * 0.01),
            CustomTextField(
                hint: "Email",
                icon: Icons.email,
                controller: emailController,
                keyboardType: TextInputType.emailAddress
            ),
            SizedBox(height: size * 0.01),

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
            SizedBox(height: size * 0.01),

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
                width: size*0.12,
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
                  child:  Text("Submit",style: AppTextStyles.caption(context,color: AppColors.white),),
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
      width: size*0.13,
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
        //border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.black, size: 18),
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
                const Icon(Icons.phone, size: 16, color: Colors.black),
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
                const Icon(Icons.email, size: 16, color: Colors.black),
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