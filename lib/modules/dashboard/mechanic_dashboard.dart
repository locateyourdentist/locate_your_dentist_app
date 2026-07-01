import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_sidebar_mobile.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import '../../common_widgets/color_code.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MechanicDashboard extends StatefulWidget {
  const MechanicDashboard({super.key});
  @override
  State<MechanicDashboard> createState() => _MechanicDashboardState();
}

class _MechanicDashboardState extends State<MechanicDashboard> {
  final notificationController = Get.put(NotificationController());
  TextEditingController searchController = TextEditingController();
  TextEditingController searchController1 = TextEditingController();
  final planController = Get.put(PlanController());
  final loginController = Get.put(LoginController());
  final contactController = Get.put(ContactController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> title = [
    "Dental Shop",
    "Dental Lab",
    "Dental Mechanic",
    "Dental Consultant",
    "Job Posts/Webinars",
  ];
  @override
  void initState() {
    super.initState();
    // Api.userInfo.erase();
    _refresh();
  }

  Future<void> _refresh() async {
    await contactController.postFilterResults(
      Api.userInfo.read('userId') ?? "",
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      context,
    );
    await notificationController.getNotificationListAdmin(context);
    await contactController.getReceiverContactFormLists(
      Api.userInfo.read('userId') ?? "",
      '',
      '',
      '',
      context,
    );
    await planController.checkPlansStatus(
      Api.userInfo.read('userId') ?? "",
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    final bool isDesktop = size >= 1100;
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      key: _scaffoldKey,
      drawer: !isDesktop
          ? Drawer(width: 250, child: SettingsSidebarDrawer())
          : null,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: size * 0.13,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ProfileImageWidget(size: size),
            ),
          ),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: AppTextStyles.body(
                context,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Api.userInfo.read('name') ?? "",
              style: TextStyle(
                fontSize: size * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          GetBuilder<NotificationController>(
            builder: (controller) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      color: AppColors.white,
                      size: size * 0.08,
                    ),
                    onPressed: () async {
                      await notificationController.getNotificationListAdmin(
                        context,
                      );
                      Get.toNamed('/notificationPage');
                    },
                  ),
                  if (int.tryParse(notificationController.unreadCount ?? "0")! >
                      0)
                    Positioned(
                      top: 0,
                      right: 15,
                      child: CircleAvatar(
                        radius: size * 0.024,
                        backgroundColor: Colors.redAccent,
                        child: Text(
                          notificationController.unreadCount.toString() ?? "",
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: size * 0.025,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      //endDrawer:  DateFilterPopup(selectedContactType: 'sender'),
      body: GetBuilder<ContactController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [
                Container(
                  height: size * 0.23,
                  //margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  //padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.15),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.15),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      height: size * 0.012,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            // height: size*0.12,
                            child: CommonSearchTextField(
                              controller: searchController,
                              hintText: "Search dental clinic",
                              onSubmitted: (value) {
                                print("Search text: $value");
                                loginController.getProfileDetails(
                                  '',
                                  '',
                                  '',
                                  '',
                                  [],
                                  "true",
                                  '',
                                  '',
                                  '',
                                  value,
                                  context,
                                );
                                Get.toNamed('/filterResultPage');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: size * 0.45,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      itemCount: title.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            horizontalOffset: 50,
                            child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: () async {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) async {
                                    if (title[index] == "Job Posts/Webinars") {
                                      Get.toNamed('/viewJobWebinarPage');
                                    } else {
                                      Api.userInfo.write(
                                        'sUserType',
                                        title[index].toString(),
                                      );

                                      print('cvv ${title[index]}');

                                      await loginController.getProfileDetails(
                                        title[index],
                                        '',
                                        '',
                                        '',
                                        [],
                                        'true',
                                        '',
                                        '',
                                        '',
                                        '',
                                        context,
                                      );

                                      if (Get.currentRoute !=
                                          '/userTypeListPage') {
                                        Get.toNamed('/userTypeListPage');
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                        child: Image.asset(
                                          imgUserType(title[index]),
                                          height: size * 0.28,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            // vertical: 5,
                                          ),
                                          child: Text(
                                            title[index].toString(),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.caption(
                                              context,
                                              color: AppColors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: size * 0.12,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),

                          Expanded(
                            child: CommonSearchTextField(
                              controller: searchController1,
                              hintText: "Search by mobile, email, name",
                              onSubmitted: (value) {
                                contactController.getReceiverContactFormLists(
                                  Api.userInfo.read('userId') ?? "",
                                  '',
                                  '',
                                  searchController1.text,
                                  context,
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.filter_alt,
                              color: AppColors.grey,
                              size: size * 0.06,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Contacts Lists',
                        style: AppTextStyles.caption(
                          context,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size * 0.02),
                      if (contactController.senderContactLists.isEmpty)
                        Center(
                          child: Text(
                            'No data found',
                            style: AppTextStyles.caption(
                              context,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      if (contactController.isLoading)
                        const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      if (contactController.senderContactLists.isNotEmpty)
                        AnimationLimiter(
                          child: ListView.builder(
                            itemCount:
                                contactController.senderContactLists.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final contact =
                                  contactController.senderContactLists[index];
                              String createdAt = contact.createdAt.toString();
                              // Parse the ISO string to DateTime
                              DateTime dateTime = DateTime.parse(createdAt);
                              // Format DateTime to "Dec 15, 2025"
                              String formattedDate = DateFormat(
                                'MMM dd, yyyy',
                              ).format(dateTime);
                              print(formattedDate); // Output: Dec 15, 2025
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 1300),
                                child: SlideAnimation(
                                  verticalOffset: 120.0,
                                  curve: Curves.easeOutBack,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: 18,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    contact.orgName ?? '',
                                                    style:
                                                        AppTextStyles.subtitle(
                                                          context,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                  ),
                                                ),
                                                Text(
                                                  formattedDate,
                                                  style: AppTextStyles.caption(
                                                    context,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              contact.Name ?? '',
                                              style: AppTextStyles.body(
                                                context,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            SizedBox(
                                              height: size * 0.1,
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.call,
                                                      size: size * 0.05,
                                                      color: AppColors.primary,
                                                    ),
                                                    onPressed: () {
                                                      launchCall(
                                                        contact.mobileNumber
                                                            .toString(),
                                                      );
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      contact.mobileNumber ??
                                                          '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          AppTextStyles.caption(
                                                            context,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(height: 1),
                                            SizedBox(
                                              height: size * 0.07,
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.email,
                                                      size: size * 0.05,
                                                      color: AppColors.primary,
                                                    ),
                                                    onPressed: () async {
                                                      await sendEmail(
                                                        contact.email
                                                            .toString(),
                                                      );
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "email: ${contact.email ?? ''}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          AppTextStyles.caption(
                                                            context,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            if (contact.materialDescription !=
                                                null)
                                              Text(
                                                "description: ${contact.materialDescription!}",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles.caption(
                                                  context,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),

                                            const SizedBox(height: 10),

                                            GetBuilder<ContactController>(
                                              builder: (controller) {
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: size * 0.25,
                                                        child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              contactController
                                                                  .editImages
                                                                  .length,
                                                          itemBuilder: (_, index) {
                                                            if (index <
                                                                controller
                                                                    .editImages
                                                                    .length) {
                                                              final img = controller
                                                                  .editImages[index];
                                                              print(
                                                                'conta img$img',
                                                              );
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  Get.toNamed(
                                                                    '/viewImagePage',
                                                                    arguments: {
                                                                      'url': img
                                                                          .url!,
                                                                    },
                                                                  );
                                                                },
                                                                child: Container(
                                                                  margin:
                                                                      const EdgeInsets.all(
                                                                        8,
                                                                      ),
                                                                  width:
                                                                      size *
                                                                      0.25,
                                                                  height:
                                                                      size *
                                                                      0.25,
                                                                  child: Stack(
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                        child:
                                                                            img.file !=
                                                                                null
                                                                            ? Image.file(
                                                                                img.file!,
                                                                                fit: BoxFit.cover,
                                                                                width:
                                                                                    size *
                                                                                    0.25,
                                                                                height:
                                                                                    size *
                                                                                    0.25,
                                                                              )
                                                                            : Image.network(
                                                                                img.url!,
                                                                                fit: BoxFit.cover,
                                                                                width:
                                                                                    size *
                                                                                    0.25,
                                                                                height:
                                                                                    size *
                                                                                    0.25,
                                                                                errorBuilder:
                                                                                    (
                                                                                      context,
                                                                                      error,
                                                                                      stackTrace,
                                                                                    ) {
                                                                                      return Container(
                                                                                        width:
                                                                                            size *
                                                                                            0.25,
                                                                                        height:
                                                                                            size *
                                                                                            0.25,
                                                                                        decoration: BoxDecoration(
                                                                                          color: const Color(
                                                                                            0xFFF1F3F6,
                                                                                          ),
                                                                                          borderRadius: BorderRadius.circular(
                                                                                            16,
                                                                                          ),
                                                                                        ),
                                                                                        child: Icon(
                                                                                          Icons.hide_image_outlined,
                                                                                          color: Colors.grey.shade400,
                                                                                          size:
                                                                                              size *
                                                                                              0.08,
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                              ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          size: 18,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                        onPressed: () {
                                                          loginController
                                                              .getProfileByUserId(
                                                                contact.userId ??
                                                                    "",
                                                                context,
                                                              );
                                                          final userType =
                                                              loginController
                                                                  .userData
                                                                  .first
                                                                  .userType
                                                                  .toString() ??
                                                              "";
                                                          print(
                                                            'usertypez$userType',
                                                          );
                                                          Get.toNamed(
                                                            '/${profilePage(userType)}',
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
