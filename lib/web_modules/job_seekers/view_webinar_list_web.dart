import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';


class WebinarListWebPage extends StatefulWidget {
  const WebinarListWebPage({super.key});

  @override
  State<WebinarListWebPage> createState() => _WebinarListWebPageState();
}

class _WebinarListWebPageState extends State<WebinarListWebPage> {
  final jobController = Get.put(JobController());
  final loginController=Get.put(LoginController());
  @override
  void initState() {
    super.initState();
     jobController.getWebinarListJobSeekers('','','',context);
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CommonWebAppBar(
        height: size * 0.08,
        title: "LYD",
        onLogout: () {
        },
        onNotification: () {
        },
      ),
      body: GetBuilder<JobController>(
          builder: (controller) {
            return Row(
              children: [
                const AdminSideBar(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
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
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Text('Webinar List',style: AppTextStyles.subtitle(context),),
                                  const SizedBox(height: 10,),
                                  if (jobController.webinarListJobSeekers.isEmpty)
                                    Center(child: Text('No data found', style: AppTextStyles.caption(context, color: AppColors.black,fontWeight: FontWeight.normal),)),

                                  if( jobController.webinarListJobSeekers.isNotEmpty)
                                    GetBuilder<JobController>(
                                        builder: (controller) {
                                          return AnimationLimiter(
                                            child:GridView.builder(
                                              itemCount: jobController.webinarListJobSeekers.length,
                                              padding: const EdgeInsets.all(1),
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: size > 1200 ? 3 : 2,
                                                  crossAxisSpacing: 20,
                                                  mainAxisSpacing: 20,
                                                  childAspectRatio: 1,
                                                ),
                                              itemBuilder: (context, index) {
                                                final appliersList = jobController.webinarListJobSeekers[index];
                                                   print('wefsdf lst${jobController.webinarListJobSeekers}');
                                                return GestureDetector(
                                                  onTap: ()async{
                                                    await jobController.getWebinarById(appliersList.webinarId.toString(), appliersList.isActive.toString(), context);
                                                    await jobController.getAppliedWebinarsAdmin(appliersList.webinarId.toString(),context);
                                                    print('dsfwebid${appliersList.isActive.toString()}');
                                                    Api.userInfo.write('webinarId', appliersList.webinarId.toString());
                                                    Api.userInfo.write('statusWebinar', appliersList.isActive.toString());
                                                    Get.toNamed('/viewWebinarDetailWebPage');
                                                    },
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(color: Colors.grey.shade200),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.05),
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      padding: const EdgeInsets.all(16),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [

                                                            Image.network( "${appliersList.webinarImage}",width: double.infinity,
                                                            height: size*0.13,  fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Container(
                                                                  width: double.infinity,
                                                                  height: size*0.13,
                                                                  color: Colors.grey.shade200,
                                                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                                                );
                                                              },),
                                                          SizedBox(height: size*0.005),

                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Center(
                                                                child: Text(
                                                                 "${appliersList.orgName ?? ""}",
                                                                  style:AppTextStyles.caption(context,fontWeight: FontWeight.bold)
                                                                ),
                                                              ),
                                                              SizedBox(height: size*0.001),

                                                              Text(
                                                                "Webinar Title: ${appliersList.webinarTitle ?? ""}",
                                                                  style:AppTextStyles.caption(context,fontWeight: FontWeight.w400)

                                                              ),

                                                              const SizedBox(height: 2),

                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              ),
                                        );
                                      }
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }
}
