import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/date_filter_drawer.dart';
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
  List<String> title=["Dental Shop","Dental Lab","Dental Mechanic","Dental Consultant",];
  final planController =Get.put(PlanController());
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
    await contactController.postFilterResults(Api.userInfo.read('userId')??"", '', '', '', '', '', '', '' ,'' ,context);
    await  contactController.getReceiverContactFormLists(Api.userInfo.read('userId')??"",'','','', context);
    await planController.checkPlansStatus(Api.userInfo.read('userId')??"",context);
  }
  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.08,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body:  GetBuilder<ContactController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: _refresh,
            child: Row(
              children: [
                const AdminSideBar(),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding:  const EdgeInsets.all(30.0),
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
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      'What are you looking for?',
                                      style: AppTextStyles.subtitle(context)
                                  ),
                                  const SizedBox(height: 20),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: title.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 6,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                      childAspectRatio: 1.2,
                                    ),
                                    itemBuilder: (context, index) {
                                      return _dashboardTile(
                                        title: title[index],
                                        image: imgUserType(title[index]),
                                        onTap: () async {
                                          if (title[index] == "Job Posts/Webinars") {
                                            Get.toNamed('/viewJobWebinarWebPage');
                                          }  {
                                            Api.userInfo.write('sUserType1', title[index]);
                                            await loginController.getProfileDetails(
                                              title[index], '', '', '', 'true', '', '', '', '',
                                              context,
                                            );
                                            Get.toNamed('/userTypeListWeb');
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(height: size*.01,),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      height: size*0.02,
                                      width: size*0.25,
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
                                            child: CustomTextField(
                                              hint: "Search contacts...",
                                              controller:searchController,
                                              onTap: ()async{
                                                await contactController.getReceiverContactFormLists(
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

                                  if (!controller.isLoading && controller.receiverContactLists.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: Text('No data found', style: AppTextStyles.caption(context, fontWeight: FontWeight.normal)),
                                      ),
                                    ),

                                  if (controller.receiverContactLists.isNotEmpty)


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
                                                Expanded(child: Text("Org Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                                Expanded(child: Text("UserType", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),

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
                                              itemBuilder: (context, index) {
                                                final contact = controller.receiverContactLists[index];
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
                                                            Expanded(child: Text(contact.orgName ?? "",style: AppTextStyles.caption(context),)),
                                                            Expanded(child: Text(contact.userType ?? "",style: AppTextStyles.caption(context),)),
                                                            Expanded(child: Text(contact.Name ?? "",style: AppTextStyles.caption(context))),
                                                            Expanded(child: Text(contact.mobileNumber ?? "",style: AppTextStyles.caption(context))),
                                                            Expanded(child: Text(formattedDate,style: AppTextStyles.caption(context))),
                                                            Expanded(
                                                              child:ElevatedButton.icon(
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
                ),

              ],
            ),
          );
        }
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
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(image, fit: BoxFit.cover,width: double.infinity,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}