import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/dashboard/view_profile_web.dart';
import 'package:flutter_quill/flutter_quill.dart';

class WebinarViewWebPage extends StatefulWidget {
  const WebinarViewWebPage({super.key});

  @override
  State<WebinarViewWebPage> createState() => _WebinarViewWebPageState();
}

class _WebinarViewWebPageState extends State<WebinarViewWebPage> {
  final jobController = Get.put(JobController());
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
    _refresh();
  }
  Future<void> _refresh() async {
    await jobController.getWebinarById(Api.userInfo.read('webinarId')??"", Api.userInfo.read('activeStatus1')??"", context);
    await jobController.getAppliedWebinarsAdmin(Api.userInfo.read('webinarId')??"",context);
    loadJobDescription(jobController.webDescriptionData);
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: AppColors.white,
      //   iconTheme: const IconThemeData(color: AppColors.black),
      // ),
      appBar: CommonWebAppBar(
        height: screenWidth * 0.03,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (controller.webinar.isEmpty) return  Center(child: Text("No data found",style: AppTextStyles.caption(context),));
          final webinar = controller.webinar.first;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Row(
              children: [
                const AdminSideBar(),
                Expanded(
                  child: Center(
                    child: DefaultTabController(
                      length: 2,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenWidth > 900 ? 350 : 220,
                                  width: double.infinity,
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          print( loginController.webinarFileImages.first.url.toString());
                                          Get.toNamed('/viewImagePage', arguments: {'url':  loginController.webinarFileImages.first.url.toString()});

                                        },
                                        child: Image.network(
                                          loginController.webinarFileImages.isNotEmpty
                                              ? loginController.webinarFileImages.first.url.toString()
                                              : '',
                                          width: double.infinity,
                                          height: screenWidth > 900 ? 350 : 220,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.grey.shade200,
                                            alignment: Alignment.center,
                                            child:  Icon(Icons.image, color:AppColors.grey,size:screenWidth*0.015 ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Text(
                                            webinar.webinarTitle ?? "",
                                            style: AppTextStyles.body(context,
                                              fontWeight: FontWeight.bold,color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TabBar(
                                  indicatorColor: AppColors.primary,
                                  indicatorWeight: 3,
                                  labelColor: AppColors.black,
                                  unselectedLabelColor: AppColors.black,
                                  tabs: [
                                    const Tab(text: 'Webinar Description'),
                                    Tab(
                                      text: Api.userInfo.read('userType').toString() == 'Job Seekers'
                                          ? 'Clinic Description'
                                          : "Applicants List",
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      SingleChildScrollView(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _leftSection(webinar),
                                            const SizedBox(height: 20),
                                            _rightSection(webinar),
                                          ],
                                        ),
                                      ),
                                      Api.userInfo.read('userType') != 'Job Seekers'
                                          ? _buildApplicationsTab(
                                        jobController.appliedWebinarList,
                                        screenWidth,
                                        context,
                                      )
                                          : (webinar.description != null &&
                                          webinar.description
                                              .toString()
                                              .isNotEmpty) ?
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
                                          ))
                                      // Padding(
                                      //       padding: const EdgeInsets.all(15.0),
                                      //       child: Text(
                                      //         webinar.description.toString(),
                                      //         style: AppTextStyles.caption(context),
                                      //       ),
                                      //     )
                                          : const SizedBox()     ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _leftSection(var webinar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconText(Icons.business, webinar.orgName ?? "N/A",context),
        _iconText(Icons.location_on, webinar.place ?? "N/A",context),
        _iconText(Icons.calendar_today, formatDate(webinar.createdDate.toString()),context),
        _iconText(Icons.access_time, "${webinar.startTime} - ${webinar.endTime}",context),
      ],
    );
  }

  Widget _rightSection(var webinar) {
    double size=MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text("About Webinar", style: AppTextStyles.body(context, fontWeight: FontWeight.bold)),
       // const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.all(10.0),
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
        //Text(webinar.webinarDescription ?? "", style:  AppTextStyles.body(context, color: Colors.black87)),
        const SizedBox(height: 10),
         Text("Webinar Link", style:  AppTextStyles.caption(context,fontWeight: FontWeight.bold)),
        InkWell(
          onTap: () {
            Get.toNamed('/webViewProfilePage', arguments: {
              "url": webinar.webinarLink ?? "",
              "clinicName": webinar.webinarTitle ?? ""
            });
          },
          child: Text(
            webinar.webinarLink ?? "",
            style:  TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize:size*0.009,decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _iconText(IconData icon, String text,dynamic context) {
    double size=MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: size*0.012, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style:AppTextStyles.body(context,))),
        ],
      ),
    );
  }
}

String formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return "N/A";
  try {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat('MMM dd, yyyy').format(date);
  } catch (_) {
    return "N/A";
  }
}
Widget _buildApplicationsTab(List applicants, double width, BuildContext context) {
  if (applicants.isEmpty) {
    return Center(
      child: Text(
        'No data found',
        style: AppTextStyles.caption(context,
            color: AppColors.black, fontWeight: FontWeight.normal),
      ),
    );
  }

  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width > 900 ? width * 0.1 : 16, vertical: 20),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: applicants.map<Widget>((applier) {
          return _applicationCard(applier, width, context);
        }).toList(),
      ),
    ),
  );
}

Widget _applicationCard(dynamic applier, double width, BuildContext context) {
  double cardWidth = width > 1200 ? 400 : width * 0.45;
  final loginController = Get.put(LoginController());
  final screenWidth = MediaQuery.of(context).size.width;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () async {
        await loginController.getProfileByUserId(applier.jobSeekerId ?? "", context);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) =>  ViewWebProfilePage()));
      },
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth*0.14,
                  backgroundColor: AppColors.primary,
                  child: ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/doctor1.jpg',
                      image: "${AppConstants.baseUrl}${applier.image}",
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_outlined,
                              color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(applier.name ?? "",
                      style: AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
                      SizedBox(height: screenWidth*0.01,),
                      Text("Email: ${applier.email ?? ""}",
                          style: AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
                      // Text("JobId: ${applier.webinarId ?? ""}",
                      //     style: AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.call, color: Colors.green,size: screenWidth*0.012,),
                  onPressed: () {
                    launchCall(applier.mobileNumber ?? "");
                  },
                ),
                Text(applier.mobileNumber ?? "",
                    style: AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: AppColors.grey,size: screenWidth*0.012,),
                  onPressed: () async {
                    await loginController.getProfileByUserId(
                        applier.jobSeekerId ?? "", context);
                    Get.toNamed('/viewProfilePageWeb');
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (_) => const JobSeekerProfilePage()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
