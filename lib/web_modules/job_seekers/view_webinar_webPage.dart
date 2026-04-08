// import 'package:flutter/material.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
// import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
// import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
// import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
// import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:locate_your_dentist/modules/profiles/jobseeker_viewprofile.dart';
// import 'package:locate_your_dentist/utills/constants.dart';
// import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
// import '../../common_widgets/color_code.dart';
//
//
// class WebinarViewWebPage extends StatefulWidget {
//   const WebinarViewWebPage({super.key});
//
//   @override
//   State<WebinarViewWebPage> createState() => _WebinarViewWebPageState();
// }
//
// class _WebinarViewWebPageState extends State<WebinarViewWebPage> {
//   final jobController=Get.put(JobController());
//   final loginController=Get.put(LoginController());
//   late String appliedKey;
//   bool isAlreadyApplied = false;
//   @override
//   void initState(){
//     super.initState();
//     final webinar = jobController.webinar.isNotEmpty ? jobController.webinar[0] : null;
//     jobController.getWebinarListJobSeekers('','','',context);
//     appliedKey = "${webinar?.webinarId.toString() ?? ''}_${Api.userInfo.read('userId')}";
//     if( appliedKey== Api.userInfo.read('appliedKey')){
//       isAlreadyApplied=true;
//     }
//     else{
//       isAlreadyApplied=false;
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     double size=MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         // title: Text('Webinars',style: AppTextStyles.subtitle(context,color: AppColors.primary),
//         // ),
//           backgroundColor: AppColors.white,iconTheme: const IconThemeData(color: AppColors.black),
//           actions:[PopupMenuButton<String>(
//             onSelected: (String isActive)async {
//               String webinarId1=jobController.webinar.isNotEmpty?jobController.webinar.first.webinarId.toString():"";
//               String isActive1=jobController.webinar.isNotEmpty?  jobController.webinar.first.isActive.toString():"";
//               await  jobController.updateWebinarStatusAdmin(webinarId1, isActive1, context,);
//               await jobController.getWebinarById(webinarId1, isActive1, context);
//               Get.toNamed('/viewWebinarPage');
//               await   jobController.getAppliedJobsAdmin(webinarId1,context);
//               // await  jobController.getJobListAdmin(context);
//             },
//             itemBuilder: (BuildContext context) {
//               return [
//                 PopupMenuItem(
//                   value: "true",
//                   child: Text("Open",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),
//                 ),
//                 PopupMenuItem(
//                   value: "false",
//                   child: Text("Close",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
//                 ),
//               ];
//             }, child: Icon(
//             Icons.more_vert,
//             color: Colors.white,size: size*0.06,
//           ),
//           ) ,
//           ]),
//       body: GetBuilder<JobController>(
//         builder: (controller) {
//           double size = MediaQuery.of(context).size.width;
//           if (controller.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (controller.webinar.isEmpty) {
//             return const Center(child: Text("No data found"));
//           }
//           final webinar = controller.webinar.first;
//           return LayoutBuilder(
//             builder: (context, constraints) {
//               bool isWeb = constraints.maxWidth > 900;
//
//               return Row(
//                 children: [
//                   const AdminSideBar(),
//
//                   Expanded(
//                     child: Center(
//                       child: DefaultTabController(
//                         length: 2,
//                         child: Container(
//                           constraints: const BoxConstraints(maxWidth: 1100),
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(20),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.08),
//                                       blurRadius: 20,
//                                       offset: const Offset(0, 10),
//                                     )
//                                   ],
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: Stack(
//                                     children: [
//                                       Image.network(
//                                         loginController.webinarFileImages.isNotEmpty
//                                             ? loginController.webinarFileImages.first.url.toString()
//                                             : '',
//                                         height: isWeb ? 350 : 220,
//                                         width: double.infinity,
//                                         fit: BoxFit.cover,
//                                         loadingBuilder: (context, child, progress) {
//                                           if (progress == null) return child;
//                                           return SizedBox(
//                                             height: isWeb ? 350 : 220,
//                                             child: const Center(child: CircularProgressIndicator()),
//                                           );
//                                         },
//                                         errorBuilder: (_, __, ___) => Container(
//                                           height: isWeb ? 350 : 220,
//                                           color: Colors.grey.shade200,
//                                           alignment: Alignment.center,
//                                           child: const Icon(Icons.broken_image, size: 50),
//                                         ),
//                                       ),
//                                       Container(
//                                         height: isWeb ? 350 : 220,
//                                         decoration: BoxDecoration(
//                                           gradient: LinearGradient(
//                                             colors: [
//                                               Colors.black.withOpacity(0.6),
//                                               Colors.transparent
//                                             ],
//                                             begin: Alignment.bottomCenter,
//                                             end: Alignment.topCenter,
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         bottom: 20,
//                                         left: 20,
//                                         right: 20,
//                                         child: Text(
//                                           webinar.webinarTitle ?? "",
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize:size*0.08,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//
//                               const SizedBox(height: 30),
//                               SizedBox(
//                                 height: size*0.04,
//                                 child: TabBar(
//                                   indicatorColor: AppColors.primary,
//                                   indicatorWeight: 3,
//                                   labelColor: AppColors.black,
//                                   unselectedLabelColor: AppColors.black,
//                                   tabs: [
//                                     const Tab(text: 'Job Description'),
//                                     Tab(text: Api.userInfo.read('userType').toString() == 'Job Seekers' ? 'Clinic Description' : "Applicants List"),
//                                   ],
//                                 ),
//                               ),
//                               TabBarView(
//                               children: [
//                               Container(
//                                 padding: const EdgeInsets.all(24),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.95),
//                                   borderRadius: BorderRadius.circular(20),
//                                   border: Border.all(color: Colors.grey.shade200),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.05),
//                                       blurRadius: 15,
//                                     )
//                                   ],
//                                 ),
//                                 child: isWeb
//                                     ? Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Flexible(child: _leftSection(webinar)),
//                                     const SizedBox(width: 30),
//                                     Flexible(child: _rightSection(webinar)),
//                                   ],
//                                 )
//                                     : Column(
//                                   children: [
//                                     _leftSection(webinar),
//                                     const SizedBox(height: 20),
//                                     _rightSection(webinar),
//                                   ],
//                                 ),
//                               ),
//                                         if(Api.userInfo.read('userType')!='Job Seekers')
//                                         Align(
//                                         alignment: Alignment.topRight,
//                                         child: TextButton(
//                                         onPressed: ()async{
//                                         await   jobController.getAppliedWebinarsAdmin(webinar.webinarId.toString(),context);
//                                         Get.toNamed('/webinarApplicantsList');
//                                         },
//                                         child:Text(
//                                         "View Applicants",softWrap: true,
//                                         style: TextStyle(
//                                         color: AppColors.primary,
//                                         fontWeight: FontWeight.bold,fontSize: size*0.03,decoration: TextDecoration.underline,
//                                         ),
//                                         ),
//                                         ),
//                                         ),
//                                 _buildApplicationsTab(jobController.appliedWebinarList, size,context),
//
//
//
//
//                               ])
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//   Widget _leftSection(var webinar) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _iconText(Icons.business, webinar.orgName ?? "N/A"),
//         const SizedBox(height: 10),
//         _iconText(Icons.location_on, webinar.place ?? "N/A"),
//         const SizedBox(height: 10),
//         _iconText(Icons.calendar_today,
//             formatDate(webinar.createdDate.toString())),
//         const SizedBox(height: 10),
//         _iconText(Icons.access_time,
//             "${webinar.startTime} - ${webinar.endTime}"),
//       ],
//     );
//   }
//   Widget _rightSection(var webinar) {
//     double size = MediaQuery.of(context).size.width;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "About Webinar",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//
//         const SizedBox(height: 10),
//
//         Text(
//           webinar.webinarDescription ?? "",
//           style: const TextStyle(height: 1.6, color: Colors.black87),
//         ),
//
//         const SizedBox(height: 20),
//
//         const Text(
//           "Webinar Link",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//
//         const SizedBox(height: 5),
//
//         InkWell(
//           onTap: () {
//             Get.toNamed('/webViewProfilePage', arguments: {
//               "url": webinar.webinarLink ?? "",
//               "clinicName": webinar.webinarTitle ?? ""
//             });
//           },
//           child: Text(
//             webinar.webinarLink ?? "",
//             style:  TextStyle(
//               color: Colors.blue,fontWeight: FontWeight.bold,fontSize: size*0.008,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 30),
//
//         SizedBox(
//           width: size*0.25,
//           child: ElevatedButton(
//             onPressed: () {
//               jobController.applyWebinarJobSeekers(
//                 webinar.webinarId.toString(),
//                 Api.userInfo.read('userId'),
//                 Api.userInfo.read('userType'),
//                 context,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               backgroundColor: AppColors.primary,
//               elevation: 5,
//             ),
//             child:  Text(
//               "Join Webinar",
//               style: AppTextStyles.caption(context,color: AppColors.white),
//             ),
//           ),
//         )
//       ],
//     );
//   }
//   Widget _iconText(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 18, color: Colors.grey),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: const TextStyle(fontSize: 14),
//           ),
//         ),
//       ],
//     );
//   }
// }
// String formatDate(String? isoDate) {
//   if (isoDate == null || isoDate.isEmpty) return "N/A";
//
//   try {
//     final date = DateTime.parse(isoDate).toLocal();
//     return DateFormat('MMM dd, yyyy').format(date);
//   } catch (e) {
//     return "N/A";
//   }
// }
// Widget _buildApplicationsTab(List applicants, double width,dynamic context) {
//   if (applicants.isEmpty) {
//     return Center(
//       child: Text(
//         'No data found',
//         style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.normal),
//       ),
//     );
//   }
//
//   return SingleChildScrollView(
//     child: Padding(
//       padding: EdgeInsets.symmetric(horizontal: width > 900 ? width * 0.1 : 16, vertical: 20),
//       child: Wrap(
//         spacing: 20,
//         runSpacing: 20,
//         children: applicants.map<Widget>((applier) {
//           return _applicationCard(applier, width,context);
//         }).toList(),
//       ),
//     ),
//   );
// }
//
// Widget _applicationCard(dynamic applier, double width,dynamic context) {
//   double cardWidth = width > 1200 ? 400 : width * 0.45;
//   final loginController = Get.put(LoginController());
//
//   return MouseRegion(
//     cursor: SystemMouseCursors.click,
//     child: GestureDetector(
//       onTap: () async {
//         await loginController.getProfileByUserId(
//             applier.jobSeekerId ?? "", context);
//         Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const JobSeekerProfilePage()));
//       },
//       child: Container(
//         width: cardWidth,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 15,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: AppColors.primary,
//                   child: ClipOval(
//                     child: FadeInImage.assetNetwork(
//                       placeholder: 'assets/images/doctor1.jpg',
//                       image: "${AppConstants.baseUrl}${applier.image}",
//                       fit: BoxFit.cover,
//                       width: 60,
//                       height: 60,
//                       imageErrorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           width: 60,
//                           height: 60,
//                           color: Colors.grey.shade200,
//                           child: const Icon(
//                               Icons.image_outlined, color: Colors.grey),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         applier.name ?? "",
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       Text("Email: ${applier.email ?? ""}",
//                           style: const TextStyle(fontSize: 14)),
//                       Text("JobId: ${applier.webinarId ?? ""}",
//                           style: const TextStyle(fontSize: 14)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.call, color: AppColors.primary),
//                   onPressed: () {
//                     launchCall(applier.mobileNumber ?? "");
//                   },
//                 ),
//                 Text(applier.mobileNumber ?? "",
//                     style: const TextStyle(fontSize: 14)),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(Icons.arrow_forward, color: AppColors.primary),
//                   onPressed: () async {
//                     await loginController.getProfileByUserId(
//                         applier.jobSeekerId ?? "", context);
//                     Navigator.push(context, MaterialPageRoute(
//                         builder: (_) => const JobSeekerProfilePage()));
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/profiles/jobseeker_viewprofile.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/web_modules/dashboard/view_profile_web.dart';

class WebinarViewWebPage extends StatefulWidget {
  const WebinarViewWebPage({super.key});

  @override
  State<WebinarViewWebPage> createState() => _WebinarViewWebPageState();
}

class _WebinarViewWebPageState extends State<WebinarViewWebPage> {
  final jobController = Get.put(JobController());
  final loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    //_refresh();
  }
  Future<void> _refresh() async {
    await jobController.getWebinarById(Api.userInfo.read('webinarId')??"", Api.userInfo.read('activeStatus1')??"", context);
    await jobController.getAppliedWebinarsAdmin(Api.userInfo.read('webinarId')??"",context);
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (controller.webinar.isEmpty) return  Center(child: Text("No data found",style: AppTextStyles.caption(context),));
          final webinar = controller.webinar.first;
          print(loginController.webinarFileImages.first.url.toString());
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
                                            child: const Icon(Icons.broken_image, size: 50),
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
                                              .isNotEmpty)
                                          ? Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Text(
                                                                                    webinar.description.toString(),
                                                                                    style: AppTextStyles.caption(context),
                                                                                  ),
                                          )
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
        _iconText(Icons.business, webinar.orgName ?? "N/A"),
        _iconText(Icons.location_on, webinar.place ?? "N/A"),
        _iconText(Icons.calendar_today, formatDate(webinar.createdDate.toString())),
        _iconText(Icons.access_time, "${webinar.startTime} - ${webinar.endTime}"),
      ],
    );
  }

  Widget _rightSection(var webinar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text("About Webinar", style: AppTextStyles.body(context, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(webinar.webinarDescription ?? "", style:  AppTextStyles.body(context, color: Colors.black87)),
        const SizedBox(height: 20),
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
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
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
