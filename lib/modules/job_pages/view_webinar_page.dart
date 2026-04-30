import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/color_code.dart';
import 'package:flutter_quill/flutter_quill.dart';


class WebinarViewPage extends StatefulWidget {
  const WebinarViewPage({super.key});

  @override
  State<WebinarViewPage> createState() => _WebinarViewPageState();
}

class _WebinarViewPageState extends State<WebinarViewPage> {
  final jobController=Get.put(JobController());
final loginController=Get.put(LoginController());
late String appliedKey;
bool isAlreadyApplied = false;
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
void initState(){
  super.initState();
  final webinar = jobController.webinar.isNotEmpty ? jobController.webinar[0] : null;
  jobController.getWebinarListJobSeekers('','','',context);
  _controller = QuillController.basic(
    config: QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(
        enableExternalRichPaste: true,
      ),

    ),
  );
  _refresh();
  appliedKey = "${webinar?.webinarId.toString() ?? ''}_${Api.userInfo.read('userId')}";
  if( appliedKey== Api.userInfo.read('appliedKey')){
    isAlreadyApplied=true;
  }
  else{
    isAlreadyApplied=false;
  }
  }
  Future<void> _refresh() async {
    await jobController.getWebinarById(Api.userInfo.read('webinarId')??"", Api.userInfo.read('statusWebinar')??"", context);
    await   jobController.getAppliedWebinarsAdmin(Api.userInfo.read('webinarId')??"",context);
    loadJobDescription(
        jobController.webDescriptionData);

  }
  @override
  Widget build(BuildContext context) {
  double size=MediaQuery.of(context).size.width;
  return Scaffold(
      appBar: AppBar(
          // title: Text('Webinars',style: AppTextStyles.subtitle(context,color: AppColors.primary),
          // ),
        backgroundColor: AppColors.white,iconTheme: const IconThemeData(color: AppColors.black),
        actions:[PopupMenuButton<String>(
          onSelected: (String isActive)async {
            String webinarId1=jobController.webinar.isNotEmpty?jobController.webinar.first.webinarId.toString():"";
            String isActive1=jobController.webinar.isNotEmpty?  jobController.webinar.first.isActive.toString():"";
            await  jobController.updateWebinarStatusAdmin(webinarId1, isActive1, context,);
            await jobController.getWebinarById(webinarId1, isActive1, context);
            Get.toNamed('/viewWebinarPage');
            await   jobController.getAppliedJobsAdmin(webinarId1,context);
           // await  jobController.getJobListAdmin(context);
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: "true",
                child: Text("Open",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),
              ),
              PopupMenuItem(
                value: "false",
                child: Text("Close",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
              ),
            ];
          }, child: Icon(
          Icons.more_vert,
          color: Colors.white,size: size*0.06,
        ),
        ) ,
      ]),
    body: GetBuilder<JobController>(
        builder: (controller) {
          final webinar1 = jobController.webinar.isNotEmpty ? jobController.webinar[0] : null;
          String targetJobId = webinar1?.webinarId.toString() ?? "";
          print('targetid$targetJobId');
          bool isWebinarApplied = jobController.webinarListJobSeekers
              .any((j) => j.webinarId.toString() == targetJobId);
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.webinar.isEmpty) {
            const SizedBox(height: 20);
          return Center(child: Text("No data found",style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.normal),));
          }
           final webinar = controller.webinar.first;
          final created = DateTime.parse(webinar.createdDate.toString());
          final postedAgo = timeAgo(created);
          // final img = loginController.webinarFileImages.isNotEmpty
          //     ? loginController.webinarFileImages.first
          //     : null;
            //final img = loginController.webinarFileImages.first;
            //print('web img url${img.url}');
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (webinar.webinarImage != null &&
                      loginController.webinarFileImages.isNotEmpty &&
                      loginController.webinarFileImages.first.url.toString().isNotEmpty)
                      ? Image.network(
                    loginController.webinarFileImages.first.url.toString(),
                    width: double.infinity,
                    height: size * 0.7,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                         return Container(
                           width: double.infinity,
                           height: size * 0.65,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade400,
                          size: size * 0.14,
                        ),
                      );
                    },
                  ) : Image.asset(
                    'assets/images/Dental_clinic.jpg',
                    width: double.infinity,
                    height: size * 0.65,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),
                if(Api.userInfo.read('userType')!='Job Seekers')
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: ()async{
                      await   jobController.getAppliedWebinarsAdmin(webinar.webinarId.toString(),context);
                      Get.toNamed('/webinarApplicantsList');
                      },
                    child:Text(
                      "View Applicants",softWrap: true,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,fontSize: size*0.03,decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                 Padding(
                   padding: const EdgeInsets.all(10.0),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                   Text(
                    webinar.webinarTitle.toString(),softWrap: true,
                   // webinarData["webinarTitle"],
                    style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold)
                                   ),

                                   const SizedBox(height: 10),

                   Row(
                    children: [
                      Icon(Icons.business, color: Colors.grey,size:size*0.06 ,),
                      const SizedBox(width: 6),
                      Text(webinar.orgName.toString()??"N/A",
                        //webinarData["orgName"],
                          style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.normal)
                      ),
                      const SizedBox(width: 10,),
                      Align(
                        alignment: Alignment.topRight,
                        child: Text("Posted $postedAgo",
                            //webinarData["orgName"],
                            style: AppTextStyles.caption(context,color: AppColors.grey,fontWeight: FontWeight.normal)),
                      ),
                    ],
                                   ),

                                   const SizedBox(height: 20),

                                   Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,color: AppColors.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _infoItem(Icons.calendar_month, "Date", formatDate(webinar.createdDate.toString()??""),context),
                          _infoItem(Icons.access_time, "Time",
                              "${webinar.startTime.toString()??"N/A"} - ${webinar.endTime.toString()??"N/A"}",context
                          ),
                          _infoItem(Icons.location_on, "Location",
                              webinar.place.toString()??"N/A",context
                          ),
                        ],
                      ),
                    ),
                                   ),

                                   const SizedBox(height: 20),

                   Text(
                    "Webinar Description",
                      style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold)
                                   ),
                                   const SizedBox(height: 10),
                   Text(webinar.webinarDescription.toString()??"N/A",
                    //webinarData["webinarDescription"],
                       style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.normal)
                                   ),
                                   const SizedBox(height: 10),
                                   Text("Webinar Link",
                      //webinarData["webinarDescription"],
                      style: AppTextStyles.body(context,color: AppColors.black,fontWeight: FontWeight.bold)
                                   ),
                                   const SizedBox(height: 1),

                                   TextButton(
                   onPressed:(){
                     print('link${webinar.webinarLink.toString()??""}');
                    Get.toNamed('/webViewProfilePage',arguments: {"url":webinar.webinarLink.toString()??"","clinicName":webinar.webinarTitle.toString()??""});
                    },
                      child:Text(webinar.webinarLink.toString()??"N/A",
                      //webinarData["webinarDescription"],
                      style: TextStyle(fontSize:size*0.03,color: Colors.blueAccent,decoration:TextDecoration.underline, fontWeight: FontWeight.normal)
                                   ),),
                                   const SizedBox(height: 15),
                   if ((Api.userInfo.read('userType') ?? "") == 'Job Seekers')
                                   Center(
                    child: ElevatedButton.icon(
                      onPressed: ()async {
                        print(webinar.webinarDescription.toString()??"");
                      await  jobController.applyWebinarJobSeekers(
                          webinar.webinarId.toString() ?? '',
                          Api.userInfo.read('userId') ?? '',
                          Api.userInfo.read('userType') ?? '',
                          context,
                        );
                        },
                      icon:  Icon(Icons.link,color:isWebinarApplied==true?AppColors.primary: AppColors.white,),
                      label:  Text( isWebinarApplied==true?"Applied":"Join Webinar",style: AppTextStyles.body(context,color: isWebinarApplied==true?AppColors.primary:AppColors.white,fontWeight: FontWeight.bold),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isWebinarApplied==true?AppColors.white:AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                    ),
                                   ),

                                   const SizedBox(height: 20),
                     ],),
                 )
              ],
            ),
          );
        }
      ),
    bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
  );
  }

  Widget _infoItem(IconData icon, String label, String value,context) {
    double size=MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size:size*0.06 ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                  style: AppTextStyles.body(context,color: AppColors.white,fontWeight: FontWeight.bold)),
                Text(value,softWrap: true,
                    style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.normal)),

              ],
            ),
          )
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
  } catch (e) {
    return "N/A";
  }
}
