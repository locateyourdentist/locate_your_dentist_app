import 'dart:io';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:get/get.dart';
import '../../common_widgets/color_code.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ViewNotification extends StatefulWidget {
  const ViewNotification({super.key});

  @override
  State<ViewNotification> createState() => _ViewNotificationState();
}

class _ViewNotificationState extends State<ViewNotification> {
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
    notificationController.updateNotificationListAdmin(context);
  }
  Future<void> _refresh() async {
    notificationController.updateNotificationListAdmin(context);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBg,
        title: Text('Notification', style: AppTextStyles.subtitle(context, color: AppColors.black),
        ),),
      body: GetBuilder<NotificationController>(
        builder: (controller) {
          if (controller.isLoading == true) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.notificationList.isEmpty) {
            return Center(
              child: Text(
                'No data found',
                style: AppTextStyles.caption(context),
              ),
            );
          }
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
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                    child: AnimationLimiter(
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
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                        children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CircleAvatar(
                                            radius: size * 0.05,
                                            backgroundColor: AppColors.primary,
                                            child: Icon(
                                              changeIcon(item.title.toString()),
                                              size: size * 0.04,
                                              color: AppColors.white,
                                            ),
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
                                          SizedBox(width: size*0.01,),
                                          Text(
                                          postedAgo,
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: size * 0.026,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                         ] ),

                                      if (item.notificationImage != null &&
                                          item.notificationImage!.isNotEmpty &&
                                          item.notificationImage![0].isNotEmpty) ...[
                                        SizedBox(
                                          height: size * 0.5,
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
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
