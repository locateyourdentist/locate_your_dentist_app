import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/profiles/jobseeker_edit_profile.dart';
import 'package:locate_your_dentist/modules/profiles/pdf_path_view_page.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:flutter_quill/flutter_quill.dart';

class JobSeekerProfilePage extends StatefulWidget {
  const JobSeekerProfilePage({super.key});
  @override
  State<JobSeekerProfilePage> createState() => _JobSeekerProfilePageState();
}
class _JobSeekerProfilePageState extends State<JobSeekerProfilePage> {
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
    } catch (e) {
      print("Quill load error: $e");
      _controller = QuillController.basic();
    }
  }
  @override
  void initState() {
    super.initState();
    //loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
        ),

      ),
    );
    _refresh();
  }
  Future<void> _refresh() async {
    await loginController.getProfileByUserId(Api.userInfo.read('selectUId')??"", context);
    loadJobDescription(loginController.descriptionData);
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    String userType=Api.userInfo.read('userType')??"";
    final hasData = loginController.userData.isNotEmpty;
    final user = hasData ? loginController.userData.first : null;
    final collegeDetails = (hasData) ? user!.details['collegeDetails'] ?? {} : {};
    final ug = collegeDetails['ugDegree'] ?? {};
    final pg = collegeDetails['pgDegree'] ?? {};
    final experiences = (hasData) ? user!.details['experienceDetails'] ?? [] : [];
    final description = (hasData && user!.details["description"] != null)
        ? user.details["description"].toString() : "";
    final categoryString = (user!.details['jobCategory'] is List)
        ? (user.details['jobCategory'] as List).join(", ")
        : user.details['jobCategory']?.toString() ?? "";
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasData)
                  Column(
                    children: [
                      const SizedBox(height: 20,),
                      Center(
                        child: Text('No data found', style: AppTextStyles.caption(context)),
                      ),
                    ],
                  ),
                if (hasData)
                Stack(
                    children: [
                      const SizedBox(height: 15,),
                        Positioned(
                        top: 10,
                        left: 10,
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
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
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,AppColors.secondary
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: size * 0.16,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: size * 0.155,
                              backgroundImage: (user!.images.isNotEmpty &&
                                  user.images[0].isNotEmpty)
                                  ? NetworkImage(user.images[0])
                                  : null,
                              child: (user.images.isEmpty ||
                                  user.images[0].isEmpty)
                                  ? const Icon(Icons.person, size: 40)
                                  : null,
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                const SizedBox(height: 12),
                Center(
                  child: Text(user?.name ?? "",
                    style: TextStyle(fontSize: size * 0.05, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),

                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('About',
                              textAlign: TextAlign.start,
                              style: AppTextStyles.body(context, fontWeight: FontWeight.bold)),

                          if (userType=='admin'||userType=='superAdmin'||user?.userId==(Api.userInfo.read('userId') ?? ""))
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const EditProfilePage()));
                                  },
                                  child: Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                        fontSize: size * 0.035,
                                        decoration: TextDecoration.underline,
                                        color: Colors.blueAccent),
                                  ),
                                ),
                              ),
                            ),

                        ],
                      ),
                      const SizedBox(height: 10),
                     // Text(description, style: AppTextStyles.caption(context, fontWeight: FontWeight.normal)),
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
                        //Text( getPlainText(job.jobDescription), style: AppTextStyles.caption(context, fontWeight: FontWeight.normal, color: AppColors.black, height: 1.5)),
                      ),
                      const SizedBox(height: 10),
                      _sectionTitle("Resume", size),
                      GestureDetector(
                        onTap: () {
                          if (user!.certificates.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewPDFPage(pdfUrl: user.certificates[0]),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.file_open, color: AppColors.primary, size: size * 0.07),
                            const SizedBox(width: 8),
                            // Text(
                            //   (user!.certificates.isNotEmpty && user.certificates[0].isNotEmpty)
                            //       ? "Resume.pdf"
                            //       : "Upload PDF",
                            //   style: TextStyle(fontSize: size * 0.03, fontWeight: FontWeight.bold, color: Colors.black),
                            // ),
                            Text(
                              (user != null &&
                                  user.certificates != null &&
                                  user.certificates.isNotEmpty &&
                                  (user.certificates[0] ?? "").isNotEmpty)
                                  ? "Resume.pdf"
                                  : "Upload PDF",
                              style: TextStyle(
                                  fontSize: size * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.edit, size: size * 0.036, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
        
                       const SizedBox(height: 20),
                      _sectionTitle("Contact Information", size),
                      // _contactTile(Icons.email_rounded, "Email", user!.email ?? "", size),
                      // _contactTile(Icons.call, "Mobile", user.mobileNumber ?? "", size),
                      // _contactTile(Icons.favorite, "Marital Status", user.martialStatus ?? "", size),
                      // _contactTile(Icons.cake, "Date of Birth", user.dob ?? "", size),
                      // _contactTile(Icons.location_on, "Location", "${user.address['city'] ?? ''}, ${user.address['district'] ?? ''}, ${user.address['state'] ?? ''}", size),
                      _contactTile(
                        Icons.email_rounded,
                        "Email",
                        (user != null && user.email != null) ? user.email! : "",
                        size,
                      ),
                      _contactTile(
                        Icons.call,
                        "Mobile",
                        (user != null && user.mobileNumber != null) ? user.mobileNumber! : "",
                        size,
                      ),
                      // _contactTile(
                      //   Icons.favorite,
                      //   "Marital Status",
                      //   (user != null && user.martialStatus != null) ? user.martialStatus! : "",
                      //   size,
                      // ),
                      _contactTile(
                        Icons.cake,
                        "Date of Birth",
                        (user != null && user.dob != null) ? user.dob! : "",
                        size,
                      ),
                      _contactTile(
                        Icons.location_on,
                        "Location",
                        (user != null && user.address != null)
                            ? "${user.address['city'] ?? ''}, ${user.address['district'] ?? ''}, ${user.address['state'] ?? ''}"
                            : "",
                        size,
                      ),
        
                      const SizedBox(height: 10),
                      _sectionTitle("Job Category", size),
                      _contactTile(
                        Icons.category,
                        "Preferences",categoryString,
                        // (user != null &&
                        //     user.details != null &&
                        //     user.details['jobCategory'] != null &&
                        //     user.details['jobCategory'] is List)
                        //     ? (user.details['jobCategory'] as List).join(", ")
                        //     : "",
                        size,
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle("Academic Details", size),
                      if (ug.isNotEmpty)
                        _infoPanel(
                            icon: Icons.school,
                            title: "UG Details",
                            desc:
                            "College: ${ug['name'] ?? ""}\nDegree: ${ug['degree'] ?? ""}\nPercentage: ${ug['percentage'] ?? ""}",
                            size: size),
                      if (pg.isNotEmpty)
                        _infoPanel(
                            icon: Icons.school,
                            title: "PG Details",
                            desc:
                            "College: ${pg['name'] ?? ""}\nDegree: ${pg['degree'] ?? ""}\nPercentage: ${pg['percentage'] ?? ""}",
                            size: size),
        
                      const SizedBox(height: 20),
                      _sectionTitle("Experience", size),
                      if (experiences.isNotEmpty)
                        Column(
                          children: experiences.map<Widget>((exp) {
                            return _infoPanel(
                              icon: Icons.work_outline_rounded,
                              title: "${exp['companyName'] ?? ""}",
                              desc:
                              "Duration: ${exp['experience'] ?? ""} \nDescription: ${exp['jobDescription'] ?? ""}",
                              size: size,
                            );
                          }).toList(),
                        )
                      else
                        Text("No experience available",
                            style: TextStyle(fontSize: size * 0.038, color: Colors.grey[700])),
        
                      const SizedBox(height: 30),
                    ],
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

  Widget _sectionTitle(String title, double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: size * 0.04, fontWeight: FontWeight.bold, color: AppColors.primary),
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
          Icon(icon, size: size * 0.055, color: Colors.grey),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: size * 0.04, color: Colors.black87, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: size * 0.038, color: Colors.grey[700])),
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
          Icon(icon, size: size * 0.085, color: Colors.black54),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: size * 0.04, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 6),
                  Text(desc, style: TextStyle(fontSize: size * 0.038, height: 1.4, color: Colors.grey[800])),
                ],
              )),
        ],
      ),
    );
  }
}
