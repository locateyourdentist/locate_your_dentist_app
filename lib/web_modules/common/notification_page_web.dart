import 'dart:io';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/color_code.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

class ViewNotificationWeb extends StatefulWidget {
  const ViewNotificationWeb({super.key});

  @override
  State<ViewNotificationWeb> createState() => _ViewNotificationWebState();
}

class _ViewNotificationWebState extends State<ViewNotificationWeb> {
  final notificationController = Get.put(NotificationController());
  String selectedTab = "All";
  final ImagePicker _picker = ImagePicker();

  IconData changeIcon(String title) {
    final t = title.trim().toLowerCase();
    if (t.contains("new")) return Icons.person;
    switch (t) {
      case "view":
        return Icons.visibility;
      case "plan":
        return Icons.next_plan_outlined;
      case "renewal":
        return Icons.autorenew;
      default:
        return Icons.message;
    }
  }
  Future<void> pickSingleImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      final selectedImageFile = File(pickedImage.path);
      notificationController.notificationImage.clear();
      notificationController.notificationFileImages.clear();
      notificationController.notificationImage.add(selectedImageFile);
      notificationController.update();
    }
  }
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
    await notificationController.updateNotificationListAdmin(context);
    await  notificationController.getNotificationListAdmin(context);
  }
  Widget _loadingCard(double size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: size * 0.01, backgroundColor: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: double.infinity, color: Colors.grey),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 150, color: Colors.grey),
                ],
              ),
            ),
            SizedBox(width: size * 0.02),
            Container(height: 16, width: 50, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LYD",
        onLogout: () {
        },
        onNotification: () {
        },
      ),
      body: GetBuilder<NotificationController>(
        builder: (controller) {
          final titles = [
            "All",
            ...{
              for (var n in controller.notificationList)
                n.title.toString().trim().toLowerCase()
            }
          ];
          final filteredList = selectedTab == "All"
              ? controller.notificationList
              : controller.notificationList
              .where((n) =>
          n.title.toString().trim().toLowerCase() ==
              selectedTab.toLowerCase())
              .toList();
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Row(
              children: [
                const AdminSideBar(),

                  Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [

                        AnimationLimiter(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: titles.map((t) {
                                final isSelected = selectedTab == t;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTab = t;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.greyLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      t.toUpperCase(),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        //const SizedBox(height: 10),

                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 800),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                    ],
                                  ),
                                  child: AnimationLimiter(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15.0,right: 15),
                                      child: ListView.builder(
                                        itemCount: filteredList.length,
                                        itemBuilder: (context, index) {
                                          final item = filteredList[index];
                                          final created = DateTime.parse(item.createdDate.toString());
                                          final postedAgo = timeAgo(created);
                                          return  AnimationConfiguration.staggeredList(
                                            position: index,
                                            duration: const Duration(milliseconds: 1300),
                                            child: SlideAnimation(
                                              verticalOffset: 120.0,
                                              curve: Curves.easeOutBack,
                                              child: FadeInAnimation(
                                                child: GestureDetector(
                                                  onTap: (){
                                                    Get.toNamed(
                                                      '/viewImagePage',
                                                      arguments: {
                                                        'url':item.notificationImage!.first,
                                                        //'index': currentIndex,
                                                      },
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(15.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              CircleAvatar(
                                                                radius: size * 0.008,
                                                                backgroundColor: AppColors.primary,
                                                                child: Icon(
                                                                  changeIcon(item.title.toString()),
                                                                  size: size * 0.012,
                                                                  color: AppColors.white,
                                                                ),
                                                              ),
                                                              // SizedBox(width: size*0.01,),
                                                              Expanded(
                                                                child: Center(
                                                                  child: Text(
                                                                    item.message.toString(),softWrap: true,
                                                                    style: AppTextStyles.caption(
                                                                      context,
                                                                      color: AppColors.black,
                                                                      fontWeight: FontWeight.normal,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: size*0.001,),
                                                              Text(
                                                                postedAgo,
                                                                style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: AppColors.grey)
                                                              ),
                                                            ] ),

                                                        if (item.notificationImage != null &&
                                                            item.notificationImage!.isNotEmpty &&
                                                            item.notificationImage![0].isNotEmpty) ...[
                                                          SizedBox(
                                                            height: size * 0.12,
                                                            width: double.infinity,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(10),
                                                              child: Image.network(
                                                                item.notificationImage![0],
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                        SizedBox(height: size*0.02,),


                                                        const Divider(color: AppColors.grey,thickness: 0.3,)
                                                      ],

                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
