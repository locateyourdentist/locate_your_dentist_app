import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/modules/dashboard/date_filter_drawer.dart';


  class ViewContactList extends StatefulWidget {
  const ViewContactList({super.key});
  @override
  State<ViewContactList> createState() => _ViewContactListState();
}
class _ViewContactListState extends State<ViewContactList> {
  final contactController=Get.put(ContactController());
  final loginController=Get.put(LoginController());
  TextEditingController searchController=TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeyContacts = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    print(Api.userInfo.read('userId')??"");
    contactController.getSenderContactFormLists(Api.userInfo.read('userId')??"", '','','',context);
  }
  Future<void> _refresh() async {
    contactController.getSenderContactFormLists(Api.userInfo.read('userId')??"", '','','',context);
  }

  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKeyContacts,
      backgroundColor: AppColors.scaffoldBg,
       // static const Color scaffoldBg = Color(0xFFF1F7F8);
      appBar: AppBar(centerTitle: true,backgroundColor: AppColors.white,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: Text('Contact Form Lists',style: AppTextStyles.subtitle(context,color: AppColors.black),),
      ),
     //endDrawer:   DateFilterPopup(selectedContactType: 'sender'),
      body: GetBuilder<ContactController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: RefreshIndicator(
              onRefresh: _refresh,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                     // const SizedBox(height: 10,),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                decoration:
                                InputDecoration(
                                  hintText: "Search contacts...",
                                  hintStyle: AppTextStyles.caption(context),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (value)async {
                                  // final String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
                                  // final String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);
                                  // contactController.getReceiverContactFormLists(Api.userInfo.read('userId')??"",formattedFromDate, formattedToDate,'', context);

                                await  contactController.getSenderContactFormLists(
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
                              icon: const Icon(Icons.tune_rounded,
                                  color: AppColors.primary),
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>  DateFilterPopup(
                                //       selectedContactType: 'sender',
                                //     ),
                                //   ),
                               // );
                                showDateFilterPopup(context);

                               // Get.toNamed('/contactFilterPage',arguments: {'selectedContactType':'sender'});
                             //  _scaffoldKeyContacts.currentState!.openEndDrawer();

                              },
                            ),
                          ],
                        ),
                      ),

                      if(contactController.senderContactLists.isEmpty)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10,),
                            Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                          ],
                        ),
                      if(contactController.isLoading)
                        const CircularProgressIndicator(color: AppColors.primary,),
                      const SizedBox(height: 10,),

                        if(contactController.senderContactLists.isNotEmpty)
                         AnimationLimiter(
                           child: ListView.builder(
                            itemCount: contactController.senderContactLists.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: ( context, index){
                              final contact= contactController.senderContactLists[index];
                              String createdAt = contact.createdAt.toString();
                              DateTime dateTime = DateTime.parse(createdAt);
                              String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
                              print(formattedDate);
                              return
                                AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 1300),
                                  child: SlideAnimation(
                                    verticalOffset: 120.0,
                                    curve: Curves.easeOutBack,
                                    child: FadeInAnimation(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 18,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  contact.orgName ?? '',
                                                  style: AppTextStyles.subtitle(context,color: AppColors.primary),
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
                                          const SizedBox(height: 12),
                                          Text(
                                            contact.Name ?? '',
                                            style: AppTextStyles.body(
                                              context,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                         // const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              IconButton(
                                                  icon: Icon(Icons.call,
                                                      size: size * 0.05, color: AppColors.primary),
                                                  onPressed: () {
                                                    launchCall(
                                                        contact.mobileNumber.toString());
                                                  }
                                              ),
                                              Text(
                                                contact.mobileNumber ?? '',
                                                style: AppTextStyles.caption(context,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 6),
                                          Text(
                                            "email: ${contact.email ?? ''}",
                                            style: AppTextStyles.caption(context,
                                                color: AppColors.black,
                                          )),
                                          const SizedBox(height: 5),
                                          if (contact.materialDescription != null)
                                            Text(
                                              "description: ${contact.materialDescription!}",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.caption(
                                                context,
                                                color: Colors.black,
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
                                                        scrollDirection: Axis.horizontal,
                                                        itemCount: contactController.editImages.length,
                                                        itemBuilder: (_, index) {
                                                          if (index < controller.editImages.length) {
                                                            final img = controller.editImages[index];
                                                            print('conta img${img}');
                                                            return GestureDetector(
                                                              onTap: (){
                                                                Get.toNamed('/viewImagePage', arguments: {
                                                                'url':  img.url!,

                                                                });

                                                                },
                                                              child: Container(
                                                                margin: const EdgeInsets.all(8),
                                                                width: size * 0.25,
                                                                height: size * 0.25,
                                                                child: Stack(
                                                                  children: [
                                                                    ClipRRect(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      child: img.file != null
                                                                          ? Image.file(
                                                                        img.file!,
                                                                        fit: BoxFit.cover,
                                                                        width: size * 0.25,
                                                                        height: size * 0.25,
                                                                      )
                                                                          : Image.network(
                                                                        img.url!,
                                                                        fit: BoxFit.cover,
                                                                        width: size * 0.25,
                                                                        height: size * 0.25,
                                                                        errorBuilder: (context, error, stackTrace) {
                                                                          return Container(
                                                                            width: size * 0.25,
                                                                            height: size * 0.25,
                                                                            decoration: BoxDecoration(
                                                                              color: const Color(0xFFF1F3F6),
                                                                              borderRadius: BorderRadius.circular(16),
                                                                            ),
                                                                            child: Icon(
                                                                              Icons.hide_image_outlined,
                                                                              color: Colors.grey.shade400,
                                                                              size: size * 0.08,
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
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(Icons.arrow_forward_ios_rounded,
                                                          size: 18,
                                                          color: AppColors.primary),
                                                      onPressed: () {
                                                        loginController.getProfileByUserId(
                                                            "${contact.userId ?? ""}",
                                                            context);
                                                        final userType =
                                                        loginController.userData.first.userType.toString();
                                                        Get.toNamed('/${profilePage(userType)}');
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                               }),
                         )
                    ],
                  ),
                ),
              ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
  Widget _statusChip(String? status) {
    Color color = Colors.orange;

    if (status == "Viewed") color = Colors.blue;
    if (status == "Responded") color = Colors.green;

    return Chip(
      label: Text(status ?? "Pending"),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }
}
