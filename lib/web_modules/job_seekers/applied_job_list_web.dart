import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class AppliedJobListsWeb extends StatefulWidget {
  const AppliedJobListsWeb({super.key});
  @override
  State<AppliedJobListsWeb> createState() => _AppliedJobListsWebState();
}

class _AppliedJobListsWebState extends State<AppliedJobListsWeb> {
  final GlobalKey<ScaffoldState> _scaffoldKeyApplied = GlobalKey<ScaffoldState>();
  final jobController = Get.put(JobController());
  String selectedTab = "All";

  @override
  void initState() {
    super.initState();
    jobController.getJobSeekersAppliedLists(Api.userInfo.read('userId') ?? "", context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    String getFirstLetter(String text) {
      if (text.isEmpty) return "";
      return text[0].toUpperCase();
    }

    return Scaffold(
      key: _scaffoldKeyApplied,
      backgroundColor: AppColors.scaffoldBg,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LYD",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<JobController>(builder: (controller) {

        if (controller.isLoading == true) {
          return _buildAppliedJobsShimmer(width, isMobile);
        }

        if (controller.jobSeekersAppliedLists.isEmpty) {
          return _buildEmptyAppliedState(context);
        }

        final titles = [
          "All",
          ...{for (var n in controller.jobSeekersAppliedLists) n.status.toString().trim()}
        ];

        final filteredList = selectedTab == "All"
            ? controller.jobSeekersAppliedLists
            : controller.jobSeekersAppliedLists
                .where((n) => n.status.toString().trim() == selectedTab)
                .toList();

        return Row(
          children: [
            if (isLoggedIn && isDesktop) const AdminSideBar(),
            Expanded(
              child: Stack(
                children: [
                  if (isLoggedIn && !isDesktop)
                    Positioned(top: 10, left: 10, child: IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKeyApplied.currentState?.openDrawer())),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 10.0 : 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    children: [
                                      if (isLoggedIn && !isDesktop) const SizedBox(height: 30),
                                      Text(
                                        "MY JOBS",
                                        style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        children: titles.map((t) {
                                          final isSelected = selectedTab == t;
                
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedTab = t;
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isSelected ? AppColors.primary : AppColors.greyLight,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                t,
                                                style: AppTextStyles.caption(context,
                                                    color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                    itemCount: filteredList.length,
                                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 30),
                                    itemBuilder: (BuildContext context, int index) {
                                      final appliedJobs = filteredList[index];
                                      final logoUrl = (appliedJobs.logoImage != null && appliedJobs.logoImage!.isNotEmpty)
                                          ? appliedJobs.logoImage!.first
                                          : null;
                
                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(milliseconds: 500),
                                        child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Api.userInfo.write('selectJobId', appliedJobs.jobId.toString());
                                                  Api.userInfo.write('activeStatus', appliedJobs.isActive.toString());
                                                  Get.toNamed('/viewJobDetailWebPage');
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: const [
                                                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets.all(15),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                          width: 50,
                                                          height: 50,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: Colors.grey.shade100,
                                                            border: Border.all(color: Colors.grey.shade300),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child: Image.network(
                                                              logoUrl ?? "",
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) => Center(
                                                                child: Text(getFirstLetter(appliedJobs.orgName.toString()),
                                                                    style: TextStyle(
                                                                        fontSize: 20,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: getRandomColor(appliedJobs.orgName.toString()))),
                                                              ),
                                                            ),
                                                          )),
                                                      const SizedBox(width: 15),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(appliedJobs.orgName ?? "N/A",
                                                                      style: AppTextStyles.caption(context, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                  decoration: BoxDecoration(
                                                                      color: getStatusColor(appliedJobs.status ?? ""),
                                                                      borderRadius: BorderRadius.circular(20)),
                                                                  child: Text(appliedJobs.status ?? "Applied",
                                                                      style: const TextStyle(color: Colors.white, fontSize: 10)),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(appliedJobs.jobTitle ?? "N/A", style: AppTextStyles.caption(context), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                                            const SizedBox(height: 5),
                                                            Row(
                                                              children: [
                                                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                                                const SizedBox(width: 4),
                                                                Expanded(
                                                                  child: Text("${appliedJobs.city}, ${appliedJobs.district}",
                                                                      style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                                                ),
                                                              ],
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
                                      );
                                    }),
                              ),
                            ],
                          ),
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppliedJobsShimmer(double size, bool isMobile) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          if (size >= 1100) Container(width: 250, height: double.infinity, color: Colors.white),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Container(
                height: 120,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAppliedState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 15),
          Text('You haven\'t applied to any jobs yet', style: AppTextStyles.subtitle(context, color: Colors.grey)),
        ],
      ),
    );
  }
}
