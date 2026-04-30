
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/date_filter_drawer.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/viewContact_detail_web.dart';

class ViewContactListWeb extends StatefulWidget {
  const ViewContactListWeb({super.key});

  @override
  State<ViewContactListWeb> createState() => _ViewContactListWebState();
}

class _ViewContactListWebState extends State<ViewContactListWeb> {
  final contactController = Get.put(ContactController());
  final loginController = Get.put(LoginController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userId = Api.userInfo.read('userId') ?? "";
    contactController.getSenderContactFormLists(userId, '', '', '', context);
  }

  Future<void> _refresh() async {
    final userId = Api.userInfo.read('userId') ?? "";
    await contactController.getSenderContactFormLists(userId, '', '', '', context);
  }
  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<ContactController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const AdminSideBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                height: size*0.022,
                                width: size*0.4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Icon(Icons.search, color: Colors.grey.shade500),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: searchController,
                                        decoration: InputDecoration(
                                          hintText: "Search contacts...",
                                          hintStyle: AppTextStyles.caption(context),
                                          border: InputBorder.none,
                                        ),
                                        onSubmitted: (value) async {
                                          await contactController.getSenderContactFormLists(
                                            Api.userInfo.read('userId') ?? "",
                                            '',
                                            '',
                                            searchController.text,
                                            context,
                                          );
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
                                      onPressed: () {
                                        showDateFilterPopup(context);
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //     //const DateFilterPopup(selectedContactType: 'sender'),
                                        //   ),
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                             SizedBox(height: size*0.01),

                            if (controller.isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),

                            if (!controller.isLoading && controller.senderContactLists.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text('No data found', style: AppTextStyles.caption(context, fontWeight: FontWeight.normal)),
                                ),
                              ),

                            if (controller.senderContactLists.isNotEmpty)


                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [

                                       Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          "Contacts",
                                          style: AppTextStyles.body(context,fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ),

                                      // Header Row
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: const Row(
                                          children: [
                                            Expanded(child: Center(child: Center(child: Text("Org Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                                            Expanded(child: Center(child: Center(child: Text("User Type", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                                            Expanded(child: Center(child: Center(child: Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                                            Expanded(child: Center(child: Center(child: Text("Mobile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                                            Expanded(child: Center(child: Center(child: Text("Date", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                                            Expanded(child: Center(child: Center(child: Text("Action", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      AnimationLimiter(
                                        child: ListView.builder(
                                          itemCount: controller.senderContactLists.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            final contact = controller.senderContactLists[index];
                                            final isEven = index % 2 == 0;
                                            final rowColor = isEven ? Colors.grey.shade100 : Colors.white;

                                            DateTime dateTime;
                                            try {
                                              dateTime = DateTime.parse(contact.createdAt.toString() ?? '');
                                            } catch (_) {
                                              dateTime = DateTime.now();
                                            }
                                            final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);

                                            return AnimationConfiguration.staggeredList(
                                                      position: index,
                                                      duration: const Duration(milliseconds: 1300),
                                                      child: SlideAnimation(
                                                        verticalOffset: 120.0,
                                                        curve: Curves.easeOutBack,
                                                        child: FadeInAnimation(
                                                  child: Container(
                                                    color: rowColor,
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                    child: Row(
                                                      children: [
                                                        Expanded(child: Center(child: Text(contact.orgName ?? "",style: AppTextStyles.caption(context),))),
                                                        Expanded(child: Center(child: Text(contact.userType ?? "",style: AppTextStyles.caption(context),))),
                                                        Expanded(child: Center(child: Text(contact.Name ?? "",style: AppTextStyles.caption(context)))),
                                                        Expanded(child: Center(child: Text(contact.mobileNumber ?? "",style: AppTextStyles.caption(context)))),
                                                        Expanded(child: Center(child: Text(formattedDate,style: AppTextStyles.caption(context)))),
                                                        Expanded(
                                                          child:Center(
                                                            child: ElevatedButton.icon(
                                                              icon: Icon(
                                                                Icons.remove_red_eye,
                                                                size: size * 0.014,
                                                                color: AppColors.primary,
                                                              ),
                                                              label: Text(
                                                                "View",
                                                                style: AppTextStyles.caption(context),
                                                              ),
                                                              onPressed: () {
                                                                Api.userInfo.write('contactId1', contact.id);
                                                                showContactDetailsDialog(context);
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
         ] ),
          );
        },
      ),
    );
  }
}
