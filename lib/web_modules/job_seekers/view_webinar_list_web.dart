import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';


class WebinarListWebPage extends StatefulWidget {
  const WebinarListWebPage({super.key});

  @override
  State<WebinarListWebPage> createState() => _WebinarListWebPageState();
}

class _WebinarListWebPageState extends State<WebinarListWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKeyWebinarList = GlobalKey<ScaffoldState>();
  final jobController = Get.put(JobController());
  final loginController=Get.put(LoginController());
  @override
  void initState() {
    super.initState();
     jobController.getWebinarListJobSeekers('','',context);
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
print('dflog$isLoggedIn');
    return Scaffold(
      key: _scaffoldKeyWebinarList,
      backgroundColor: AppColors.scaffoldBg,
      drawer:( !isDesktop&&isLoggedIn) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: buildAppBar(context),
      body: GetBuilder<JobController>(
          builder: (controller) {
            return Row(
              children: [
                //if (isDesktop &&isLoggedIn) const AdminSideBar(),
                if (isDesktop &&isLoggedIn) const AdminSideBar(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 10 : 20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                            ],
                          ),
                          child: Stack(
                            children: [
                              if (!isDesktop)
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: IconButton(
                                    icon: const Icon(Icons.menu),
                                    onPressed: () => _scaffoldKeyWebinarList.currentState?.openDrawer(),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.all(isMobile ? 15 : 20.0),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Text('Webinar List',style: AppTextStyles.subtitle(context),),
                                    const SizedBox(height: 20,),
                                    if (jobController.isLoading)
                                      _buildWebinarShimmer(width)
                                    else if (jobController.webinarListJobSeekers.isEmpty)
                                      _buildEmptyWebinarState(context)
                                    else
                                      AnimationLimiter(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final w = constraints.maxWidth;
                                            int crossAxisCount = w > 1200 ? 3 : (w > 800 ? 2 : 1);
                                            double childAspectRatio = w < 600 ? 1.3 : 1.4;

                                            return GridView.builder(
                                              itemCount: jobController.webinarListJobSeekers.length,
                                              padding: const EdgeInsets.all(1),
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                crossAxisSpacing: 20,
                                                mainAxisSpacing: 20,
                                                childAspectRatio: childAspectRatio,
                                              ),
                                              itemBuilder: (context, index) {
                                                final appliersList = jobController.webinarListJobSeekers[index];
                                                return AnimationConfiguration.staggeredList(
                                                  position: index,
                                                  duration: const Duration(milliseconds: 500),
                                                  child: FadeInAnimation(
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        Api.userInfo.write('webinarId', appliersList.webinarId.toString());
                                                        Api.userInfo.write('activeStatus1', appliersList.isActive.toString());
                                                        Get.toNamed('/viewWebinarDetailWebPage');
                                                      },
                                                      child: MouseRegion(
                                                        cursor: SystemMouseCursors.click,
                                                        child: Container(
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
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(8),
                                                                child: Image.network(
                                                                  "${appliersList.webinarImage}",
                                                                  width: double.infinity,
                                                                  height: isMobile ? 180 : 250,
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    return Container(
                                                                      width: double.infinity,
                                                                      height: isMobile ? 180 : 150,
                                                                      color: Colors.grey.shade200,
                                                                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              const SizedBox(height: 12),
                                                              Center(
                                                                child: Text(
                                                                  appliersList.orgName ?? "",
                                                                  style: AppTextStyles.caption(context, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                "Webinar Title: ${appliersList.webinarTitle ?? ""}",
                                                                style: AppTextStyles.caption(context, fontWeight: FontWeight.w400),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildWebinarShimmer(double size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWebinarState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.video_camera_back_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 15),
            Text('No webinars currently available', 
              style: AppTextStyles.subtitle(context, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
