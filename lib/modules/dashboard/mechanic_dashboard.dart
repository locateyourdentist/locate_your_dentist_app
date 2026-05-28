import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/date_filter_drawer.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import '../../common_widgets/color_code.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

  class MechanicDashboard extends StatefulWidget {
  const MechanicDashboard({super.key});
  @override
  State<MechanicDashboard> createState() => _MechanicDashboardState();
  }
  class _MechanicDashboardState extends State<MechanicDashboard> {
  final notificationController=Get.put(NotificationController());
  TextEditingController searchController=TextEditingController();
  TextEditingController searchController1=TextEditingController();
  final planController =Get.put(PlanController());
  final loginController=Get.put(LoginController());
  final contactController=Get.put(ContactController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    // Api.userInfo.erase();
    _refresh();
  }
  Future<void> _refresh() async {
   await contactController.postFilterResults(Api.userInfo.read('userId')??"", '', '', '', '', '', '', '' ,'' ,context);
   await notificationController.getNotificationListAdmin(context);
   await  contactController.getReceiverContactFormLists(Api.userInfo.read('userId')??"",'','','', context);
   await planController.checkPlansStatus(Api.userInfo.read('userId')??"",context);
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: true,
        leading: Padding(
          padding:  const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: size * 0.13,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: ProfileImageWidget(size: size),
            ),
          ),
        ),
        centerTitle: false,flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary,AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
        title: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: AppTextStyles.body(context,
                color: AppColors.white,fontWeight: FontWeight.bold,),
            ),
            Text(Api.userInfo.read('name')??"",style: TextStyle(fontSize: size*0.03,fontWeight: FontWeight.bold,color: Colors.white),),

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
                      onPressed: () async{
                      await  notificationController.getNotificationListAdmin(context);
                        Get.toNamed('/notificationPage');
                      },
                    ),
                    if (int.tryParse(notificationController.unreadCount ?? "0")! > 0)
                      Positioned(
                          top: 0,
                          right: 15,
                          child: CircleAvatar(
                            radius: size*0.024,backgroundColor: Colors.redAccent,child: Text(
                            notificationController.unreadCount.toString()??"",style: TextStyle(color: AppColors.white,fontWeight: FontWeight.w500,fontSize: size*0.025),
                          ),
                          ))
                  ],
                );
              }
          )
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
                height: size*0.23,
                //margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              //padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary,AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50),bottomRight: Radius.circular(50)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                height: size*0.012,
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                       // height: size*0.12,
                        child:CommonSearchTextField(
                          controller: searchController,
                          hintText: "Search dental clinic",
                          onSubmitted: (value) {
                            print("Search text: $value");
                            loginController.getProfileDetails('' '', '','',"true", searchController.text.toString(),'','','', value,context);
                            Get.toNamed('/filterResultPage');
                          },
                        )
                    ),
                  ],
                ),
              ),
            ),
                ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: size*0.12,
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
                              contactController.getReceiverContactFormLists(Api.userInfo.read('userId')??"",'','',searchController1.text, context);
                              },
                          ),
                        ),

                        const SizedBox(width: 8),
                        IconButton(
                          icon:  Icon(Icons.filter_alt,color: AppColors.grey,size: size*0.06,),
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
                  child: Column(children: [
                    Text('Contacts Lists',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                  SizedBox(height: size*0.02,),
                              if(contactController.senderContactLists.isEmpty)
                  Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                              if(contactController.isLoading)
                  const CircularProgressIndicator(color: AppColors.primary,),
                      if(contactController.senderContactLists.isNotEmpty)
                      // String fromDate = DateFormat('yyyy-MM-dd').format(fromDatePicker);
                      // String toDate   = DateFormat('yyyy-MM-dd').format(toDatePicker);
                      // AnimationLimiter(
                      //   child: ListView.builder(
                      //   itemCount: contactController.senderContactLists.length,
                      //   shrinkWrap: true,
                      //   physics: const NeverScrollableScrollPhysics(),
                      //   itemBuilder: ( context, index){
                      //     final contact= contactController.senderContactLists[index];
                      //     // String createdAt = contactController.senderContactLists[index].createdAt.toString();
                      //     // final dynamic createdAtRaw = contact.createdAt;
                      //     // String formattedDate = '';
                      //     // if (createdAtRaw != null) {
                      //     //   try {
                      //     //     DateTime dateTime;
                      //     //     if (createdAtRaw is String) {
                      //     //       dateTime = DateTime.parse(createdAtRaw);
                      //     //     } else if (createdAtRaw is int) {
                      //     //       dateTime = DateTime.fromMillisecondsSinceEpoch(createdAtRaw);
                      //     //     } else {
                      //     //       dateTime = createdAtRaw;
                      //     //     }
                      //     //     formattedDate = DateFormat('MMM dd, yyyy').format(dateTime.toLocal());
                      //     //   } catch (e) {
                      //     //     print('Error parsing date: $e');
                      //     //     formattedDate = 'Invalid date';
                      //     //   }
                      //     //     loginController.getProfileByUserId(contact.userId??"", context);
                      //     //   String  userType='';
                      //     //   if(loginController.userData.isNotEmpty) {
                      //     //     userType = loginController.userData
                      //     //         .first.userType.toString();
                      //     //   }
                      //     //   final page = profilePage(userType ?? '');
                      //     //   if (page != null && page.isNotEmpty) {
                      //     //     //Get.toNamed('/$page');
                      //     //     Get.offAllNamed('/${profilePage(userType ?? '')}');
                      //     //   }
                      //     // }
                      //     final createdAtRaw = contact.createdAt;
                      //     String formattedDate = '';
                      //     if (createdAtRaw != null) {
                      //       try {
                      //         DateTime dateTime;
                      //         if (createdAtRaw is String) {
                      //           dateTime = DateTime.parse(createdAtRaw.toString());
                      //         } else if (createdAtRaw is int) {
                      //           dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(createdAtRaw.toString()));
                      //         } else {
                      //           dateTime = createdAtRaw;
                      //         }
                      //         formattedDate = DateFormat('MMM dd, yyyy').format(dateTime.toLocal());
                      //       } catch (e) {
                      //         formattedDate = 'Invalid date';
                      //       }
                      //     }
                      //     void navigateToProfile(String userId) async {
                      //       await loginController.getProfileByUserId(userId, context);
                      //
                      //       String userType = '';
                      //       if (loginController.userData.isNotEmpty) {
                      //         userType = loginController.userData.first.userType.toString();
                      //       }
                      //
                      //       final page = profilePage(userType);
                      //       if (page.isNotEmpty) {
                      //         // Navigate safely after current frame
                      //         WidgetsBinding.instance.addPostFrameCallback((_) {
                      //           if (mounted) Get.offAllNamed('/$page');
                      //         });
                      //       }
                      //     }
                      //     print(formattedDate);
                      //     return  AnimationConfiguration.staggeredList(
                      //       position: index,
                      //       duration: const Duration(milliseconds: 1300),
                      //       child: SlideAnimation(
                      //         verticalOffset: 120.0,
                      //         curve: Curves.easeOutBack,
                      //         child: FadeInAnimation(
                      //           child: Padding(
                      //             padding: const EdgeInsets.all(10.0),
                      //             child: Card(
                      //               elevation: 2,color: AppColors.white,
                      //               margin: const EdgeInsets.only(bottom: 12),
                      //               child: Padding(
                      //                 padding: const EdgeInsets.all(12),
                      //                 child: Row(
                      //                   mainAxisAlignment: MainAxisAlignment.start,
                      //                   children: [
                      //                     const SizedBox(
                      //                       height: 200,
                      //                       child: VerticalDivider(
                      //                         width: 2,
                      //                         thickness: 2,
                      //                         color: AppColors.primary
                      //                       ),
                      //                     ),
                      //                     const SizedBox(width: 10,),
                      //                     Column(
                      //                       crossAxisAlignment: CrossAxisAlignment.start,
                      //                       children: [
                      //                         Row(
                      //                           children: [
                      //                             Text(
                      //                                 contact.orgName ?? '',
                      //                                 style: AppTextStyles.body(context,fontWeight: FontWeight.bold,)
                      //                             ),
                      //                            // Spacer(),
                      //                             Align(
                      //                                 alignment: Alignment.centerRight,
                      //                                 child: IconButton(onPressed: ()async{
                      //                                   await  loginController.getProfileByUserId(contact.userId??"", context);
                      //                                   navigateToProfile(contact.userId??"");
                      //                                 },
                      //                                   icon: Icon(Icons.arrow_forward,color: AppColors.grey,size: size*0.06,),
                      //                                 )
                      //                             ),
                      //                           ],
                      //                         ),
                      //                         SizedBox(height: size*0.01),
                      //
                      //                         Text("Name: ${contact.Name ?? ''}",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,)
                      //                         ),
                      //                         SizedBox(height: size*0.02),
                      //                         Text("Mobile: ${contact.mobileNumber ?? ''}",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,)),
                      //                         SizedBox(height: size*0.02),
                      //
                      //                         // Text("Email: ${contact.email ?? ''}",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,)),
                      //                         //
                      //                         // SizedBox(height: size*0.02),
                      //
                      //                         Text(
                      //                             "Material Description:${contact.materialDescription ?? '' }",
                      //                             maxLines: 2,
                      //                             overflow: TextOverflow.ellipsis,style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,)
                      //                         ),
                      //                         SizedBox(height: size*0.02),
                      //                         Text(
                      //                             "Address: ${contact.address ?? ''}, ",
                      //                             style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: AppColors.grey)
                      //                         ),
                      //                         SizedBox(height: size*0.02),
                      //                         Text(
                      //                             'contacted on $formattedDate',
                      //                             maxLines: 2,
                      //                             overflow: TextOverflow.ellipsis,
                      //                             style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: AppColors.black)
                      //
                      //                         ),
                      //
                      //                       ],
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   }),
                      // )
                        AnimationLimiter(
                          child: ListView.builder(
                              itemCount: contactController.senderContactLists.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: ( context, index){
                                final contact= contactController.senderContactLists[index];
                                String createdAt = contact.createdAt.toString();
                                // Parse the ISO string to DateTime
                                DateTime dateTime = DateTime.parse(createdAt);
                                // Format DateTime to "Dec 15, 2025"
                                String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
                                print(formattedDate); // Output: Dec 15, 2025
                                return
                                  AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 1300),
                                    child: SlideAnimation(
                                      verticalOffset: 120.0,
                                      curve: Curves.easeOutBack,
                                      child: FadeInAnimation(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
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
                                                  height: size*0.1,
                                                  child: Row(
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
                                                            color: Colors.grey.shade600),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 1),
                                                    SizedBox(
                                                      height: size*0.07,
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                          icon: Icon(Icons.email,
                                                              size: size * 0.05, color: AppColors.primary),
                                                          onPressed: () async{
                                                           await sendEmail(
                                                                contact.email.toString());
                                                          }
                                                      ),
                                                      Text(
                                                        "email: ${contact.email ?? ''}",
                                                        style: AppTextStyles.caption(context,
                                                            color: Colors.grey.shade600),
                                                      ),

                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                if (contact.materialDescription != null)
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
                                                                final userType = loginController.userData.first.userType.toString()??"";
                                                                print('usertypez$userType');
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

                                          // Card(
                                          //   elevation: 2,color: AppColors.white,
                                          //   margin: const EdgeInsets.only(bottom: 12),
                                          //   child: Padding(
                                          //     padding: const EdgeInsets.all(12),
                                          //     child: Column(
                                          //       crossAxisAlignment: CrossAxisAlignment.start,
                                          //       children: [
                                          //
                                          //         Row(
                                          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          //           children: [
                                          //             Text(
                                          //               contact.orgName ?? '',
                                          //               style: AppTextStyles.body(context,fontWeight: FontWeight.bold,)
                                          //             ),
                                          //            // _statusChip(contact.status),
                                          //           ],
                                          //         ),
                                          //
                                          //          SizedBox(height: size*0.02),
                                          //
                                          //         Text("Doctor: ${contact.Name ?? ''}",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,)
                                          //         ),
                                          //         SizedBox(height: size*0.02),
                                          //         Text("Mobile: ${contact.mobileNumber ?? ''}",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,)),
                                          //         SizedBox(height: size*0.02),
                                          //
                                          //         Text("Email: ${contact.email ?? ''}",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,)),
                                          //
                                          //         SizedBox(height: size*0.02),
                                          //
                                          //         Text(
                                          //           contact.materialDescription ?? '',
                                          //           maxLines: 2,
                                          //           overflow: TextOverflow.ellipsis,style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,)
                                          //         ),
                                          //
                                          //         SizedBox(height: size*0.02),
                                          //
                                          //         /// Address
                                          //         Text(
                                          //           "Address: ${contact.address ?? ''}",
                                          //             style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: AppColors.grey)
                                          //         ),
                                          //         SizedBox(height: size*0.02),
                                          //         Text(
                                          //           'contacted on $formattedDate',
                                          //           maxLines: 2,
                                          //           overflow: TextOverflow.ellipsis,
                                          //             style: AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: AppColors.black)
                                          //
                                          //         ),
                                          //         const SizedBox(height: 8),
                                          //
                                          //         // View Details Button
                                          //         Align(
                                          //           alignment: Alignment.centerRight,
                                          //           child: IconButton(onPressed: (){
                                          //             loginController.getProfileByUserId("${contact.userId??""}", context);
                                          //             final userType=loginController.userData.first.userType.toString()??"";
                                          //             Get.toNamed('/${profilePage(userType ?? '')}');
                                          //             },
                                          //           icon: Icon(Icons.arrow_forward,color: AppColors.grey,size: size*0.06,),
                                          //           )
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                        ),
                                      ),
                                    ),
                                  );
                              }),
                        )
                              ],
                            ),
                )]),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }

}
