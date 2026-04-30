import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/profiles/pdf_path_view_page.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ViewWebProfilePage extends StatefulWidget {
  const ViewWebProfilePage({super.key});
  @override
  State<ViewWebProfilePage> createState() => _ViewWebProfilePageState();
}
class _ViewWebProfilePageState extends State<ViewWebProfilePage> {
  final loginController = Get.put(LoginController());
  final ScrollController _scrollController = ScrollController();
  late QuillController _controller;
  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      if (data == null) {
        delta = [{"insert": "\n"}];
      }

      else if (data is List) {
        delta = List<Map<String, dynamic>>.from(data);
      }

      else if (data is String) {
        delta = List<Map<String, dynamic>>.from(jsonDecode(data));
      }

      _controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );

      setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      _controller = QuillController.basic();
      setState(() {});
    }
  }
  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
        ),
      ),
    );

    loadData();
  }
  Future<void> loadData() async {
    await loginController.getProfileByUserId(
      Api.userInfo.read('selectUId') ?? "",
      context,
    );
    if (!mounted) return;
    final data = loginController.userData.isNotEmpty
        ? loginController.userData.first.details["description"]
        : null;
    loadJobDescription(data);
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    final hasData = loginController.userData.isNotEmpty;
    final user = hasData ? loginController.userData.first : null;
    final collegeDetails = (hasData) ? user!.details['collegeDetails'] ?? {} : {};
    final ug = collegeDetails['ugDegree'] ?? {};
    final pg = collegeDetails['pgDegree'] ?? {};
    final experiences = (hasData) ? user!.details['experienceDetails'] ?? [] : [];
    // final description = (hasData && user!.details["description"] != null)
    //     ? user.details["description"].toString() : "";
    loadJobDescription(user?.details["description"]);
    // final categoryString = (user?.details['jobCategory'] as List<dynamic>?)?.join(", ")
    //     ?? user?.details['jobCategory']?.toString()
    //     ?? "";
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: Row(
        children: [
          const AdminSideBar(),

          Expanded(
            child: Container(
              color: AppColors.scaffoldBg,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        _headerHero(user, size,context),

                         SizedBox(height: size*0.03),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 2,
                              child: _card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle("About",size),
                                    // const SizedBox(height: 10),
                                    // Text(description, style: AppTextStyles.caption(context)),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:  IgnorePointer(
                                          child: QuillEditor(
                                            controller: _controller,
                                            scrollController: _scrollController,
                                            focusNode: FocusNode(),
                                            config: const QuillEditorConfig(
                                              showCursor: false,
                                              expands: false,
                                            ),
                                          ),
                                        )
                                    ),

                                    const SizedBox(height: 10),
                                    if(Api.userInfo.read('userType')=='Job Seekers')
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                      _sectionTitle("Resume",size),
                                    const SizedBox(height: 10),
                                    _resumeTile(user, size, context),
                  ])
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 1,
                              child: _card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle("Contact Info",size),
                                    const SizedBox(height: 10),
                                    _contactTile(Icons.email, "Email", user?.email ?? "", size),
                                    _contactTile(Icons.call, "Mobile", user?.mobileNumber ?? "", size),
                                    _contactTile(Icons.cake, "DOB", user?.dob ?? "", size),
                                    _contactTile(Icons.location_on, "Location",
                                        "${user?.address['city'] ?? ''}, ${user?.address['state'] ?? ''}", size),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size*0.01),

                        Row(
                          children: [
                            if (ug.isNotEmpty)
                              Expanded(
                                child: _card(
                                  child: _infoPanel(
                                    icon: Icons.school,
                                    title: "UG Degree",
                                    desc: "${ug['degree']} - ${ug['name']}\n${ug['percentage']}%",
                                    size: size,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 20),
                            if (pg.isNotEmpty)
                              Expanded(
                                child: _card(
                                  child: _infoPanel(
                                    icon: Icons.school,
                                    title: "PG Degree",
                                    desc: "${pg['degree']} - ${pg['name']}\n${pg['percentage']}",
                                    size: size,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: size*0.01),
                      if(Api.userInfo.read('userType')=='Job Seekers')
                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle("Experience",size),
                              const SizedBox(height: 10),
                              if (experiences.isNotEmpty)
                                ...experiences.map((exp) => _infoPanel(
                                  icon: Icons.work_outline,
                                  title: exp['companyName'] ?? "",
                                  desc: "${exp['experience']}\n${exp['jobDescription']}",
                                  size: size,
                                ))
                              else
                                const Text("No experience available"),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _contactTile(IconData icon, String label, String value, double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: size * 0.012, color: Colors.grey),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption(context,color: Colors.black87, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.caption(context,color: Colors.black87, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPanel({
    required IconData icon,
    required String title,
    required String desc,
    required double size,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.9),
      ),
      child: Row(
        children: [
          Icon(icon, size: size * 0.012, color: Colors.black54),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.caption(context,fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 6),
                  Text(desc, style: AppTextStyles.caption(context,fontWeight: FontWeight.normal, color: Colors.black,)),
                ],
              )),
        ],
      ),
    );
  }
}
Widget _profileHeader(user, double size,dynamic context) {
  double size=MediaQuery.of(context).size.width;
  final loginController=Get.put(LoginController());
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
      ),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: size*0.15,
          backgroundImage: (user?.images.isNotEmpty ?? false)
              ? NetworkImage(user.images[0])
              : null,
          child: (user?.images.isEmpty ?? true)
              ? const Icon(Icons.person, size: 40)
              : null,
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.name ?? "",
                  style: AppTextStyles.caption(context)),

              const SizedBox(height: 6),

              Text(user?.email ?? "",
                  style: AppTextStyles.caption(context)),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async{
                 await loginController.getProfileByUserId(user?.userId??"", context);

                  Get.toNamed('/registerPageWeb');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
                child:  Text("Edit Profile",style: AppTextStyles.caption(context),),
              )
            ],
          ),
        )
      ],
    ),
  );
}
Widget _card({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        )
      ],
    ),
    child: child,
  );
}
Widget _title(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
}
Widget _resumeTile(user, double size,context) {
  return GestureDetector(
    onTap: () {
      print(user.certificates[0]);
      if (user!.certificates.isNotEmpty) {
        Get.to(() => ViewPDFPage(pdfUrl: user.certificates[0]));
      }
    },
    child:  Row(
      children: [
        Icon(Icons.picture_as_pdf, color: Colors.red,size: size*0.014,),
        const SizedBox(width: 10),
        Text("View Resume",style: AppTextStyles.caption(context),),
      ],
    ),
  );
}
Widget _headerHero(user, double size,context) {
  final loginController=Get.put(LoginController());
  return SizedBox(
    height: size*0.11,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: size*0.11,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              )
            ],
          ),
          padding:  const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              ElevatedButton.icon(
                onPressed: () async{
                  print('fwf${user.userId}');
                  await loginController.getProfileByUserId(user?.userId??"", context);
                  Get.toNamed('/registerPageWeb');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                icon:  Icon(Icons.edit, size: size*0.01,color: AppColors.grey,),
                label:  Text("Edit Profile",style: AppTextStyles.caption(context),),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: -30,
          left: 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: size*0.023,
                  backgroundImage: (user?.images.isNotEmpty ?? false)
                      ? NetworkImage(user.images[0])
                      : null,
                  child: (user?.images.isEmpty ?? true)
                      ?  Icon(Icons.person, size: size*0.012)
                      : null,
                ),
              ),

              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(user?.name ?? "",
                      style: AppTextStyles.body(context,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  // const SizedBox(height: 6),
                  Text(user?.userId ?? "",
                   style:   AppTextStyles.body(context,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      )),
                  // const SizedBox(height: 4),
                  // if (user?.mobileNumber != null)
                  //   OutlinedButton.icon(
                  //     onPressed: () {
                  //       // Launch Call or WhatsApp
                  //     },
                  //     style: OutlinedButton.styleFrom(
                  //       side: const BorderSide(color: AppColors.white),
                  //       foregroundColor: AppColors.primary,backgroundColor: AppColors.primary,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //     ),
                  //     icon:  Icon(Icons.phone, size: size*0.01,color: AppColors.white,),
                  //     label:  Center(child: Text("Contact",style: AppTextStyles.caption(context,color: AppColors.white),)),
                  //   ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}