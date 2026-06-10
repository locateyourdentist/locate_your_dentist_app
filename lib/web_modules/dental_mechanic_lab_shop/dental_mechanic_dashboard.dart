// import 'package:flutter/material.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/common_widgets/color_code.dart';
// import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
// import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
// import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
// import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
// import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
// import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
// import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
// import 'package:get/get.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:locate_your_dentist/web_modules/dental_clinic/viewContact_detail_web.dart';
// import 'package:intl/intl.dart';
//
//
// class DentalMechanicWebDashboard extends StatefulWidget {
//   const DentalMechanicWebDashboard({super.key});
//
//   @override
//   State<DentalMechanicWebDashboard> createState() => _DentalMechanicWebDashboardState();
// }
//
// class _DentalMechanicWebDashboardState extends State<DentalMechanicWebDashboard> {
//   final contactController = Get.put(ContactController());
//   final loginController = Get.put(LoginController());
//   final TextEditingController searchController = TextEditingController();
//   List<String> title=["Dental Shop","Dental Lab","Dental Mechanic","Dental Consultant",];
//   final planController =Get.put(PlanController());
//   @override
//   void initState() {
//     super.initState();
//     _refresh();
//   }
//   Future<void> _refresh() async {
//     await contactController.postFilterResults(Api.userInfo.read('userId')??"", '', '', '', '', '', '', '' ,'' ,context);
//     await  contactController.getReceiverContactFormLists(Api.userInfo.read('userId')??"",'','','', context);
//     await planController.checkPlansStatus(Api.userInfo.read('userId')??"",context);
//   }
//   @override
//   Widget build(BuildContext context) {
//     final double size = MediaQuery.of(context).size.width;
//     final bool isDesktop = size >= 1100;
//     final bool isMobile = size < 700;
//     final bool isLoggedIn = Api.userInfo.read('token') != null;
//
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
//       appBar: CommonWebAppBar(
//         height: size * 0.03,
//         title: "LOCATE YOUR DENTIST",
//         onLogout: () {},
//         onNotification: () {},
//       ),
//       body:  GetBuilder<ContactController>(
//           builder: (controller) {
//             return RefreshIndicator(
//               onRefresh: _refresh,
//             child: Row(
//               children: [
//                 if (isLoggedIn && isDesktop) const AdminSideBar(),
//                 Expanded(
//                   child: Center(
//                     child: Padding(
//                       padding:  const EdgeInsets.all(30.0),
//                       child: ConstrainedBox(
//                         constraints: const BoxConstraints(maxWidth: 1400),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: AppColors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: const [
//                               BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
//                             ],
//                           ),
//                           child: SingleChildScrollView(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             child: Padding(
//                               padding: const EdgeInsets.all(30.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   if (isLoggedIn && !isDesktop)
//                                     Positioned(top: 10, left: 10, child: Builder(
//                                         builder: (innerContext) {
//                                           return IconButton(icon: const Icon(Icons.menu,color: AppColors.black,), onPressed: () => Scaffold.of(innerContext).openDrawer());
//                                         }
//                                     )),
//                                   Padding(
//                                     padding: const EdgeInsets.all(20.0),
//                                     child: Center(
//                                       child: Text(
//                                           'What are you looking for?',
//                                           style: AppTextStyles.subtitle(context)
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 20),
//                                   GridView.builder(
//                                     shrinkWrap: true,
//                                     physics: const NeverScrollableScrollPhysics(),
//                                     itemCount: title.length,
//                                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 6,
//                                       crossAxisSpacing: 20,
//                                       mainAxisSpacing: 20,
//                                       childAspectRatio: 1.2,
//                                     ),
//                                     itemBuilder: (context, index) {
//                                       return _dashboardTile(
//                                         title: title[index],
//                                         image: imgUserType(title[index]),
//                                         onTap: () async {
//                                           if (title[index] == "Job Posts/Webinars") {
//                                             Get.toNamed('/viewJobWebinarWebPage');
//                                           }  {
//                                             Api.userInfo.write('sUserType1', title[index]);
//                                             await loginController.getProfileDetails(
//                                               title[index], '', '', '', 'true', '', '', '', '',
//                                               context,
//                                             );
//                                             Get.toNamed('/userTypeListWeb');
//                                           }
//                                         },
//                                       );
//                                     },
//                                   ),
//                                   SizedBox(height: size*.01,),
//                                   Align(
//                                     alignment: Alignment.topRight,
//                                     child:   Padding(
//                                       padding: const EdgeInsets.all(30.0),
//                                       child: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Container(
//                                             width: size * 0.35,
//                                             padding: const EdgeInsets.symmetric(horizontal: 15),
//                                             decoration: BoxDecoration(
//                                               color: Colors.grey.shade100,
//                                               borderRadius: BorderRadius.circular(10),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.grey.withOpacity(0.15),
//                                                   blurRadius: 6,
//                                                 )
//                                               ],
//                                             ),
//                                             child: TextField(
//                                               controller: searchController,
//                                               onChanged: (value)async {
//                                                 await contactController.getReceiverContactFormLists(
//                                                   Api.userInfo.read('userId') ?? "",
//                                                   '',
//                                                   '',
//                                                   searchController.text,
//                                                   context,
//                                                 );
//                                               },
//                                               decoration: InputDecoration(
//                                                 icon: Icon(
//                                                   Icons.search,
//                                                   color: AppColors.grey,
//                                                   size: size * 0.008,
//                                                 ),
//                                                 hintText: "Search contacts by name, userId, mobile number...",
//                                                 hintStyle:
//                                                 AppTextStyles.caption(context, color: AppColors.grey),
//                                                 border: InputBorder.none,
//                                               ),
//                                             ),
//                                           ),
//
//                                           const SizedBox(width: 10),
//
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//
//                                   SizedBox(height: size*0.01),
//
//                                   if (controller.isLoading)
//                                     const Padding(
//                                       padding: EdgeInsets.symmetric(vertical: 20),
//                                       child: CircularProgressIndicator(color: AppColors.primary),
//                                     ),
//
//                                   if (!controller.isLoading && controller.receiverContactLists.isEmpty)
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(vertical: 20),
//                                       child: Center(
//                                         child: Text('No data found', style: AppTextStyles.caption(context, fontWeight: FontWeight.normal)),
//                                       ),
//                                     ),
//
//                                   if (controller.receiverContactLists.isNotEmpty)
//
//
//                                     Padding(
//                                       padding: const EdgeInsets.all(15.0),
//                                       child: Column(
//                                         children: [
//
//                                           Text(
//                                             "Contacts",
//                                             style: AppTextStyles.body(context,fontWeight: FontWeight.bold, color: Colors.black),
//                                           ),
//
//                                           const SizedBox(height: 15),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                                             decoration: BoxDecoration(
//                                               color: AppColors.primary,
//                                               borderRadius: BorderRadius.circular(2),
//                                             ),
//                                             child: const Row(
//                                               children: [
//                                                 Expanded(child: Center(child: Text("Org Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
//                                                 Expanded(child: Center(child: Text("UserType", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
//
//                                                 Expanded(child: Center(child: Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
//                                                 Expanded(child: Center(child: Text("Mobile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
//                                                 Expanded(child: Center(child: Text("Date", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
//                                                 Expanded(child: Center(child: Text("Action", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
//                                               ],
//                                             ),
//                                           ),
//
//                                           const SizedBox(height: 8),
//
//                                           AnimationLimiter(
//                                             child: ListView.builder(
//                                               itemCount: controller.receiverContactLists.length,
//                                               shrinkWrap: true,
//                                               itemBuilder: (context, index) {
//                                                 final contact = controller.receiverContactLists[index];
//                                                 final isEven = index % 2 == 0;
//                                                 final rowColor = isEven ? Colors.grey.shade100 : Colors.white;
//
//                                                 DateTime dateTime;
//                                                 try {
//                                                   dateTime = DateTime.parse(contact.createdAt.toString() ?? '');
//                                                 } catch (_) {
//                                                   dateTime = DateTime.now();
//                                                 }
//                                                 final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
//
//                                                 return AnimationConfiguration.staggeredList(
//                                                   position: index,
//                                                   duration: const Duration(milliseconds: 1300),
//                                                   child: SlideAnimation(
//                                                     verticalOffset: 120.0,
//                                                     curve: Curves.easeOutBack,
//                                                     child: FadeInAnimation(
//                                                       child: Container(
//                                                         color: rowColor,
//                                                         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                                                         child: Row(
//                                                           children: [
//                                                             Expanded(child: Center(child: Text(contact.orgName ?? "",style: AppTextStyles.caption(context),))),
//                                                             Expanded(child: Center(child: Text(contact.userType ?? "",style: AppTextStyles.caption(context),))),
//                                                             Expanded(child: Center(child: Text(contact.Name ?? "",style: AppTextStyles.caption(context)))),
//                                                             Expanded(child: Center(child: Text(contact.mobileNumber ?? "",style: AppTextStyles.caption(context)))),
//                                                             Expanded(child: Center(child: Text(formattedDate,style: AppTextStyles.caption(context)))),
//                                                             Expanded(
//                                                               child:ElevatedButton.icon(
//                                                                 icon: Icon(
//                                                                   Icons.remove_red_eye,
//                                                                   size: size * 0.014,
//                                                                   color: AppColors.primary,
//                                                                 ),
//                                                                 label: Text(
//                                                                   "View",
//                                                                   style: AppTextStyles.caption(context),
//                                                                 ),
//                                                                 onPressed: () {
//                                                                   Api.userInfo.write('contactId1', contact.id);
//                                                                   showContactDetailsDialog(context);
//                                                                 },
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//               ],
//             ),
//           );
//         }
//       ),
//     );
//   }
// }
// Widget _dashboardTile({
//   required String title,
//   required String image,
//   required VoidCallback onTap,
// }) {
//   return InkWell(
//     onTap: onTap,
//     borderRadius: BorderRadius.circular(16),
//     child: Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//               child: Image.asset(image, fit: BoxFit.cover,width: double.infinity,),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/viewContact_detail_web.dart';
import 'package:intl/intl.dart';

class DentalMechanicWebDashboard extends StatefulWidget {
  const DentalMechanicWebDashboard({super.key});

  @override
  State<DentalMechanicWebDashboard> createState() => _DentalMechanicWebDashboardState();
}

class _DentalMechanicWebDashboardState extends State<DentalMechanicWebDashboard> {
  final contactController = Get.put(ContactController());
  final loginController = Get.put(LoginController());
  final TextEditingController searchController = TextEditingController();
  final List<String> title = ["Dental Clinic","Dental Shop", "Dental Lab", "Dental Mechanic", "Dental Consultant"];
  final planController = Get.put(PlanController());

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await contactController.postFilterResults(Api.userInfo.read('userId') ?? "", '', '', '', '', '', '', '', '', context);
    await contactController.getReceiverContactFormLists(Api.userInfo.read('userId') ?? "", '', '', searchController.text, context);
    await planController.checkPlansStatus(Api.userInfo.read('userId') ?? "", context);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobileLayout = width < 760;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    int crossAxisCount = 4;
    double childAspectRatio = 1.1;
    if (width < 500) {
      crossAxisCount = 1;
      childAspectRatio = 2.2;
    } else if (width < 760) {
      crossAxisCount = 2;
      childAspectRatio = 1.2;
    } else if (width < 1200) {
      crossAxisCount = 3;
      childAspectRatio = 1.1;
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: width * 0.03 > 60 ? width * 0.03 : 60,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<ContactController>(
        builder: (controller) {
          return Row(
              children: [
              if (isLoggedIn && isDesktop) const AdminSideBar(),
          Expanded(
          child: Center(
          child: Padding(
          padding: EdgeInsets.all(isMobileLayout ? 12.0 : 30.0),
          child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Container(
          decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
          ),
          child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
          padding: EdgeInsets.all(isMobileLayout ? 16.0 : 30.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          if (isLoggedIn && !isDesktop)
          Builder(
          builder: (innerContext) {
          return IconButton(
          icon: const Icon(Icons.menu, color: AppColors.black),
          onPressed: () => Scaffold.of(innerContext).openDrawer(),
          );
          },
          ),
          Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
          child: Text(
          'What are you looking for?',
          style: AppTextStyles.subtitle(context),
          textAlign: TextAlign.center,
          ),
          ),
          ),

          // Category Dynamic Grid
          GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: title.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
          return _dashboardTile(
          title: title[index],
          image: imgUserType(title[index]),
          onTap: () async {
          Api.userInfo.write('sUserType1', title[index]);
          await loginController.getProfileDetails(
          title[index], '', '', '', 'true', '', '', '', '', context,
          );
          Get.toNamed('/userTypeListWeb');
          },
          );
          },
          ),
          const SizedBox(height: 30),

          // Search Control Bar Layout
          Align(
          alignment: isMobileLayout ? Alignment.center : Alignment.topRight,
          child: Container(
          width: isMobileLayout ? double.infinity : 400,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
          controller: searchController,
          onChanged: (value) async {
          await contactController.getReceiverContactFormLists(
          Api.userInfo.read('userId') ?? "", '', '', value.trim(), context,
          );
          },
          decoration: InputDecoration(
          icon: const Icon(Icons.search, color: AppColors.grey, size: 20),
          hintText: "Search contacts...",
          hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
          border: InputBorder.none,
          ),
          ),
          ),
          ),
          const SizedBox(height: 24),

          // Async Dynamic Content State Handler
          if (controller.isLoading)
          const Center(
          child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: AppColors.primary),
          ),
          ),

          if (!controller.isLoading && controller.receiverContactLists.isEmpty)
          Center(
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text('No data found', style: AppTextStyles.caption(context, fontWeight: FontWeight.normal)),
          ),
          ),

          if (!controller.isLoading && controller.receiverContactLists.isNotEmpty)
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
          "Contacts",
          style: AppTextStyles.body(context, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          ),
          const SizedBox(height: 12),

          // Desktop Table Column Header Metadata Line
          if (!isMobileLayout)
          Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
          children: [
          Expanded(child: Text("Org Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text("User Type", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text("Mobile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text("Date", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text("Action", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          ),
          ),
          const SizedBox(height: 8),

          AnimationLimiter(
          child: ListView.builder(
          itemCount: controller.receiverContactLists.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
          final contact = controller.receiverContactLists[index];
          final isEven = index % 2 == 0;
          final rowColor = isEven ? Colors.grey.shade100 : Colors.white;

          DateTime dateTime;
          try {
          dateTime = DateTime.parse(contact.createdAt.toString());
          } catch (_) {
          dateTime = DateTime.now();
          }
          final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);

          void onViewContact() {
          Api.userInfo.write('contactId1', contact.id);
          showContactDetailsDialog(context);
          }

          return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
          verticalOffset: 30.0,
          child: FadeInAnimation(
          child: isMobileLayout
          ? _buildMobileContactCard(contact, formattedDate, rowColor, onViewContact)
              : _buildDesktopContactRow(contact, formattedDate, rowColor, onViewContact),
          ),
          ),
          );
          },
          ),
          ),
          ],
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
          )],
          );
        },
      ),
    );
  }

  // Desktop layout helper
  Widget _buildDesktopContactRow(dynamic contact, String date, Color bgColor, VoidCallback onPressed) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Text(contact.orgName ?? "", style: AppTextStyles.caption(context))),
          Expanded(child: Text(contact.userType ?? "", style: AppTextStyles.caption(context))),
          Expanded(child: Text(contact.Name ?? "", style: AppTextStyles.caption(context))),
          Expanded(child: Text(contact.mobileNumber ?? "", style: AppTextStyles.caption(context))),
          Expanded(child: Text(date, style: AppTextStyles.caption(context))),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(elevation: 1, backgroundColor: Colors.white),
                icon: const Icon(Icons.remove_red_eye, size: 16, color: AppColors.primary),
                label: Text("View", style: AppTextStyles.caption(context, color: AppColors.primary)),
                onPressed: onPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile card layout helper
  Widget _buildMobileContactCard(dynamic contact, String date, Color bgColor, VoidCallback onPressed) {
    return Card(
      color: bgColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            _rowItem("Org Name:", contact.orgName ?? "N/A"),
            _rowItem("User Type:", contact.userType ?? "N/A"),
            _rowItem("Name:", contact.Name ?? "N/A", isBold: true),
            _rowItem("Mobile:", contact.mobileNumber ?? "N/A"),
            _rowItem("Date:", date),
            const Divider(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 10)),
                icon: const Icon(Icons.remove_red_eye, size: 16, color: Colors.white),
                label: const Text("View Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: onPressed,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _rowItem(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(val, style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
Widget _dashboardTile({
  required String title,
  required String image,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback container if the asset image path does not exist
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}