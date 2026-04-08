import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/common_widgets/watsapp_utils.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/modules/profiles/view_profileImages.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../api/api.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


class Media {
  final String? url;
  final bool isVideo;

  Media({required this.url, this.isVideo = false});
}
class ClinicProfileWeb extends StatefulWidget {
  const ClinicProfileWeb({super.key});
  @override
  State<ClinicProfileWeb> createState() => _ClinicProfileWebState();
}
class _ClinicProfileWebState extends State<ClinicProfileWeb> with SingleTickerProviderStateMixin{
  final loginController=Get.put(LoginController());
  String imgUrl = "";
  final userType = Api.userInfo.read('userType')?.toString() ?? "";
  final serviceController=Get.put(ServiceController());
  @override
  void initState() {
  //  _tabController1 = TabController(length:userType=='superAdmin'? 2:1, vsync: this,);
    //Api.userInfo.read('selectUserId')=="admin"|| Api.userInfo.read('selectUserId')=="superAdmin"? loginController.getProfileByUserId(Api.userInfo.read('selectUserId'), context):loginController.getProfileByUserId(Api.userInfo.read('userId'), context);
    //loginController.getProfileByUserId(Api.userInfo.read('selectUserId')??"", context);
    //serviceController.getServiceListAdmin(Api.userInfo.read('selectUId')??"", context);
     // loginController.getProfileByUserId(Api.userInfo.read('selectUId')??"", context);
      super.initState();
  }
  bool getPlanActive() {
    final userData = loginController.userData;
    if (userData.isEmpty) return false;
    final raw = userData.first.details["plan"]?["basePlan"]?["isActive"]??"";
    return raw == true || raw == "true";
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final planActive = getPlanActive();
    String userType=Api.userInfo.read('userType')??"";
    print('fsgdfsf$userType');
    String userId=Api.userInfo.read('userId')??"";
    String editUserId=loginController.userData.isNotEmpty?loginController.userData.first.userId.toString():"";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    Future<void> _refresh() async {
      //_tabController1 = TabController(length:userType=='superAdmin'? 2:1, vsync: this,);
     // serviceController.getServiceListAdmin(loginController.userData.isNotEmpty?loginController.userData.first.userId.toString():"", context);
      await serviceController.getServiceListAdmin(Api.userInfo.read('selectUId')??"", context);
     await loginController.getProfileByUserId(Api.userInfo.read('selectUId')??"", context);
    }
    PreferredSizeWidget buildAppBar() {
      if (Api.userInfo.read('token') != null) {
        return CommonWebAppBar(
          height: size * 0.08,
          title: "LYD",
          onLogout: () {},
          onNotification: () {},
        );
      } else {
        return const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CommonHeader(),
        );
      }
    }
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: buildAppBar(),
      body:  GetBuilder<LoginController>(
          init: LoginController(),
          builder: (controller) {
            return  RefreshIndicator(
            onRefresh: _refresh,
            child:  Row(
                children: [
                  if( Api.userInfo.read('token')!=null)
                    const AdminSideBar(),
                  Expanded(
                    child:Center(
                      child: DefaultTabController(
                        length: isAdminUser?4:3,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: SizedBox.expand(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: size*0.14,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.grey,width: 0.3),
                                    // boxShadow: const [
                                    //   BoxShadow(
                                    //     color: Colors.black12,
                                    //     blurRadius: 8,
                                    //     offset: Offset(0, 4),
                                    //   )
                                    // ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          loginController.editImages.isNotEmpty
                                              ? loginController.editImages.first.url ?? ""
                                              : "",
                                          height: size*0.16,
                                          width: size*0.11,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: size*0.2,
                                            width: size*0.11,
                                            color: Colors.grey.shade200,
                                            child:  Icon(Icons.image, size: size*0.012),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 24),

                                      /// RIGHT - DETAILS
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    loginController.userData.first.details["name"] ?? "",
                                                    style: AppTextStyles.subtitle(context),
                                                  ),
                                                ),
                                                      if(userType=='admin'||userType=='superAdmin'||userId==editUserId)
                                                        GestureDetector(
                                                          onTap: (){
                                                            loginController.getProfileByUserId(loginController.userData.first.userId??"", context);
                                                            Get.toNamed('/registerPageWeb');
                                                            //Get.toNamed('/clinicEditProfile',arguments: {"userId":loginController.userData.first.userId??""});
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.edit,color: AppColors.grey,size: size*0.01,),
                                                              SizedBox(height: size * 0.03),
                                                              Text('Edit',style: AppTextStyles.caption(context,color: AppColors.black),)
                                                            ],
                                                          ),
                                                        ),
                                              ],
                                            ),

                                            const SizedBox(height: 8),

                                            if(isAdminUser)
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        loginController.userData.first.userType ?? "",
                                                        style:  AppTextStyles.caption(context,color: Colors.grey),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                      if(Api.userInfo.read('userType')=='superAdmin')
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: loginController.userData.first.isActive
                                                            ? Colors.green
                                                            : Colors.red,
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(
                                                        loginController.userData.first.isActive
                                                            ? "Active"
                                                            : "Inactive",
                                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                                 SizedBox(width: size*0.01,),
                                                Text(
                                                  "${loginController.userData.first.address['city'] ?? ''}, "
                                                      "${loginController.userData.first.address['district'] ?? ''}",
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 16),

                                            Row(
                                              children: [
                                                _actionButton(Icons.call, "Call", () async{
                                                  if ((planActive == true &&
                                                      loginController.userData
                                                          .first
                                                          .details["plan"]?["basePlan"]?["details"]?["mobileNumber"] ==
                                                          true) ||
                                                      isAdminUser) {
                                                   await launchCall(loginController
                                                        .userData.first
                                                        .mobileNumber
                                                        .toString() ?? "");
                                                  }
                                                },context
                                              ),
                                                 SizedBox(width: size*0.01),
                                                _actionButton(Icons.language, "Website",
                                                        () {
                                                          if((planActive==true&&loginController.userData.first.details["plan"]?["basePlan"]?["details"]?["location"]==true)||
                                                              isAdminUser) {
                                                            if (PlatformHelper.platform == 'Android' ||
                                                                PlatformHelper.platform == 'iOS') {
                                                              Get.toNamed('/webViewProfilePage', arguments: {
                                                                "url": loginController.userData.first
                                                                    .details["website"] ?? "".toString() ?? "",
                                                                "clinicName": loginController.userData.first
                                                                    .details["name"] ?? "".toString()
                                                              });
                                                              if (loginController.userData.first
                                                                  .details["website"] ?? ""
                                                                  .toString()
                                                                  .isEmpty || loginController.userData.first
                                                                  .details["website"] ??
                                                                  "".toString() == null) {
                                                                showCustomToast(context, "Website error",
                                                                    backgroundColor: AppColors.secondary);
                                                              }
                                                            }
                                                          }
                                                },context),
                                                SizedBox(width: size*0.01),
                                                _actionButton(Icons.chat, "WhatsApp", ()async {
                                                  final userData = loginController.userData.isNotEmpty
                                                      ? loginController.userData.first
                                                      : null;

                                                  if (userData == null) return;
                                                  final bool isMobileAllowed = userData.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true;
                                                  final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
                                                  final bool isMobilePlatform = PlatformHelper.platform == 'Android' || PlatformHelper.platform == 'iOS';

                                                  if (!isMobilePlatform) return;
                                                  if (!planActive) return;
                                                  if (!isMobileAllowed && !isAdminUser) return;
                                                 await WhatsAppUtils.openWhatsApp(
                                                    phoneNumber: userData.mobileNumber?.toString() ?? '',
                                                    message: "Hi Message From ${userData.details?["name"] ?? ''}",
                                                  );
                                                },context),
                                              ],
                                            ),
                                            SizedBox(height: size*0.01,),
                                            _actionButton(Icons.contact_page_outlined, "Contact", () async{
                                          Get.toNamed('/createContactPageWeb',arguments:{
                                          "senderUserId":Api.userInfo.read('userId'),
                                          "receiverUserId":loginController.userData.first.userId.toString() ?? "",
                                          "clinicName": loginController.userData.first.details["name"].toString() ?? "",
                                          "mobileNumber": loginController.userData.first.mobileNumber.toString() ?? "",
                                          "email": loginController.userData.first.email.toString() ?? "","doctorName":loginController.userData.first.name.toString() ?? "",
                                          "address": {
                                          "city": loginController.userData.first.address?['city'] ?? "",
                                          "district": loginController.userData.first.address?['district'] ?? "",
                                          "state": loginController.userData.first.address?['state'] ?? "",
                                          }
                                          });

                                            },context
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),
                                SizedBox(
                                  height: size*0.027,
                                  child: TabBar(
                                   // isScrollable: true,
                                    indicator: BoxDecoration(
                                      // gradient: const LinearGradient(
                                      //   colors: [AppColors.primary, AppColors.secondary],
                                      //   begin: Alignment.topLeft,
                                      //   end: Alignment.bottomRight,
                                      // ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    labelColor: AppColors.black,
                                    unselectedLabelColor: Colors.black87,
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                                    labelStyle:  AppTextStyles.caption(fontWeight: FontWeight.bold,context),
                                    tabs:   [
                                      const Tab(child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text('Description',),
                                      )),
                                      const Tab(child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text('Services'),
                                      )),
                                      const Tab(child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text('Images'),
                                      )),
                                      if(isAdminUser)
                                      const Tab(child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text('Certificates'),
                                      )),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  //fit: FlexFit.loose,
                                  //height: size*0.7,
                                  child: TabBarView(
                                      children: [
                                  Container(
                                    height: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: _cardDecoration(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                       if(loginController.userData.first.details["description"].isNotEmpty)
                                         Text("Description",
                                            style: AppTextStyles.body(fontWeight: FontWeight.bold,context)),
                                        const SizedBox(height: 10),
                                        Text(
                                          //"Cherub Fertility and women's centre is a Gynecology/Obstetrics Clinic in Rajakilpakkam, Chennai. The clinic is visited by gynecologist like Dr. Florence Vasantha Praba. The timings of Cherub Fertility and women's centre are: Mon-Sun: 00:00-23:59. Some of the services provided by the Clinic are: Abortion / Medical Termination of Pregnancy (MTP),Gynaecological Endoscopy,Gynae Problems,Gynaec Laparoscopy and Female Infertility Treatment etc. Click on map to find directions to reach Cherub Fertility and women's centre. ",
                                          loginController.userData.first.details["description"] ?? "No Data found",
                                          style:AppTextStyles.caption(fontWeight: FontWeight.normal,context),
                                        ),
                                      ],
                                    ),
                                  ),
                                        SingleChildScrollView(
                                          child:    Container(
                                            height: double.infinity,
                                            padding: const EdgeInsets.all(20),
                                            decoration: _cardDecoration(),
                                            child: Column(children: [
                                             // Text(
                                             //     "Our Services",
                                             //     style:AppTextStyles.body(context,fontWeight: FontWeight.bold)
                                             // ),
                                             SizedBox(height: size*0.02,),
                                             if(serviceController.serviceList.isEmpty)
                                               Center(child: Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),)),),
                                             if(serviceController.isLoading)
                                               const Center(child: CircularProgressIndicator(color: AppColors.primary,)),
                                            //  if(serviceController.serviceList.isNotEmpty&&planActive==true&&loginController.userData.first.details["plan"]?["basePlan"]?["details"]["services"]==true|| isAdminUser||userId==editUserId)
                                              if ((serviceController.serviceList.isNotEmpty && planActive == true && loginController.userData.first.details["plan"]?["basePlan"]?["details"]["services"] == true) || isAdminUser || userId == editUserId)
                                                GridView.builder(
                                                shrinkWrap: false,
                                                  physics: const ClampingScrollPhysics(),
                                                  itemCount: serviceController.serviceList.length,
                                                gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 16,
                                                  mainAxisSpacing: 16,
                                                  childAspectRatio:4
                                                ),
                                                itemBuilder: (_, index) {
                                                  final service = serviceController.serviceList[index];

                                                  return GestureDetector(
                                                  onTap: ()async{
                                                    await serviceController.getServiceDetailAdmin(service.serviceId.toString()??"", context);
                                                    Get.toNamed('/viewServicePage',arguments: {"serviceId":service.serviceId.toString()??""});
                                                    },
                                                  child: Container(
                                                    height: 150,
                                                    padding: const EdgeInsets.all(10),
                                                   color: AppColors.white,
                                                   // decoration: _cardDecoration(),
                                                    child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      service.image?.isNotEmpty == true
                                                          ? service.image!.first
                                                          : "",
                                                      width: size*0.13,
                                                      height:  size*0.13,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) =>
                                                          Image.asset('assets/images/hospital2.png',
                                                        width: size*0.13,
                                                        height:  size*0.13,fit: BoxFit.cover,
                                                        //color: Colors.grey.shade200,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: size*0.01),


                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          service.serviceTitle ?? "",
                                                          style:  AppTextStyles.caption(fontWeight: FontWeight.bold,context),
                                                        ),
                                                         SizedBox(height: size*0.01),
                                                        Text(
                                                          "₹ ${service.serviceCost}",
                                                          style:  AppTextStyles.caption(fontWeight: FontWeight.normal,context),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                                                                          ),
                                                                                        ),
                                                                                );
                                                                              },
                                                                            ),
                                                                   ],),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Container(
                                            color: AppColors.white,
                                            height: size*0.12,
                                            child: MediaCarousel(
                                              images: loginController.editImages.isNotEmpty
                                                  ? loginController.editImages
                                                  .where((img) =>
                                              img.url != null &&
                                                  img.url!.startsWith('http') &&
                                                  !img.url!.contains('undefined'))
                                                  .toList() : [],
                                            ),
                                          ),
                                        ),
                                        if(isAdminUser)
                                          SingleChildScrollView(
                                            child: Column(
                                                children: [
                                                  SizedBox(height: size*0.02,),
                                                  if(loginController.editCertificates.length==0)
                                                    Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                                                  if(loginController.isLoading)
                                                    const CircularProgressIndicator(color: AppColors.primary,),
                                                  if(loginController.editCertificates.isNotEmpty)
                                                    AnimationLimiter(
                                                      child: ListView.builder(
                                                          itemCount: loginController.editCertificates.length,
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          itemBuilder: (BuildContext context, int index) {
                                                            return AnimationConfiguration.staggeredList(
                                                              position: index,
                                                              duration: const Duration(milliseconds: 1300),
                                                              child: SlideAnimation(
                                                                verticalOffset: 120.0,
                                                                curve: Curves.easeOutBack,
                                                                child: FadeInAnimation(
                                                                  child:Padding(
                                                                    padding: const EdgeInsets.all(10.0),
                                                                    child:
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                        Get.toNamed('/viewImagePage',arguments: {'url':loginController.editCertificates[index].url??"",});
                                                                        print('fgf${loginController.editCertificates[index]}');
                                                                      },
                                                                      child: Card(
                                                                        elevation: 2,
                                                                        // height: size * 0.65,
                                                                        // width: double.infinity,
                                                                        // decoration: BoxDecoration(
                                                                        //   borderRadius: BorderRadius.circular(30),),
                                                                        child: Column(
                                                                          children: [
                                                                            Text(
                                                                                "${loginController.userData.first.userType} Certificate",
                                                                                //labProfile['address'].toString(),
                                                                                // "Catchy Dental Clinic",
                                                                                textAlign: TextAlign.center,
                                                                                style: AppTextStyles.caption(
                                                                                    context, color: AppColors.black)
                                                                            ),
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(
                                                                                  10),
                                                                              child:Image.network(
                                                                                  loginController.editCertificates[index].url??"",
                                                                                  fit: BoxFit.cover,
                                                                                  height: size * 0.6,
                                                                                  width: double.infinity,
                                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                                      Container(
                                                                                        decoration: BoxDecoration(border: Border.all(color: AppColors.grey,width: 0.6)),
                                                                                        height: size * 0.55,
                                                                                        width: double.infinity,
                                                                                        child: Center(child: Icon(Icons.file_download_off,color: AppColors.grey,size: size*0.09,),),
                                                                                      )
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),),
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                    ),
                                                ]
                                            ),
                                          )

                                  ]),
                                )
                              ],
                                                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
                         )
          );
        }
      ),
    );
  }
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        )
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap,BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return SizedBox(
      width: size*0.06,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding:  EdgeInsets.symmetric(horizontal: size*0.004, vertical: size*0.005,),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: size*0.01,color: Colors.grey,),
               SizedBox(width: size*0.001),
              Text(label,style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );
  }
}
