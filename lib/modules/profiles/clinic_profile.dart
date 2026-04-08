import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/common_widgets/watsapp_utils.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/modules/profiles/view_profileImages.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import '../../api/api.dart';
import '../../common_widgets/common_bottom_navigation.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
class Media {
  final String? url;
  final bool isVideo;

  Media({required this.url, this.isVideo = false});
}
  class ClinicProfile extends StatefulWidget {
  const ClinicProfile({super.key});
  @override
  State<ClinicProfile> createState() => _ClinicProfileState();
  }
  class _ClinicProfileState extends State<ClinicProfile> with SingleTickerProviderStateMixin{
  final loginController=Get.put(LoginController());
  String imgUrl = "";
  late TabController _tabController1;
  final userType = Api.userInfo.read('userType')?.toString() ?? "";
  final serviceController=Get.put(ServiceController());
  @override
  void initState() {
    _tabController1 = TabController(length:userType=='superAdmin'? 2:1, vsync: this,);
    //Api.userInfo.read('selectUserId')=="admin"|| Api.userInfo.read('selectUserId')=="superAdmin"? loginController.getProfileByUserId(Api.userInfo.read('selectUserId'), context):loginController.getProfileByUserId(Api.userInfo.read('userId'), context);
      //loginController.getProfileByUserId(Api.userInfo.read('selectUserId')??"", context);
    serviceController.getServiceListAdmin(loginController.userData.isNotEmpty?loginController.userData.first.userId.toString():"", context);
    super.initState();
  }
  bool getPlanActive() {
    final userData = loginController.userData;
    if (userData.isEmpty) return false;
    final raw = userData.first.details["plan"]?["basePlan"]?["isActive"]??"";
    return raw == true || raw == "true";
  }
  @override
  void dispose() {
    _tabController1.dispose();
    super.dispose();
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
      _tabController1 = TabController(length:userType=='superAdmin'? 2:1, vsync: this,);
      serviceController.getServiceListAdmin(loginController.userData.isNotEmpty?loginController.userData.first.userId.toString():"", context);
    }
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        // title: Text(loginController.userData.isNotEmpty ? "${loginController.userData.first.userType.split(" ").last} Profile" : "Profile",
        //   style: AppTextStyles.subtitle(context,color: AppColors.black),),automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          actions: [
        if(userType=='admin'||userType=='superAdmin'||userId==editUserId)
        GestureDetector(
        onTap: (){
          loginController.getProfileByUserId(loginController.userData.first.userId??"", context);
          Get.toNamed('/clinicEditProfile');
          //Get.toNamed('/clinicEditProfile',arguments: {"userId":loginController.userData.first.userId??""});
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.edit,color: AppColors.primary,size: size*0.05,),
            SizedBox(height: size * 0.03),
            Text('Edit',style: TextStyle(color: AppColors.primary,fontSize: size*0.04,fontWeight: FontWeight.bold),)
          ],
        ),
      ),]
      ),
      body: Padding(
      padding: const EdgeInsets.all(10.0),
      child: GetBuilder<LoginController>(
          init: LoginController(),
          builder: (controller) {
            print("Final images list: ${loginController.editImages}");
            return  RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Column(
                children: [
                  if(loginController.userData.isEmpty)
                    Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                  if(loginController.isLoading)
                    const CircularProgressIndicator(color: AppColors.primary,),
                  if(loginController.userData.isNotEmpty)
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                    MediaCarousel(
                      images: loginController.editImages.isNotEmpty
                          ? loginController.editImages
                          .where((img) =>
                      img.url != null &&
                          img.url!.startsWith('http') &&
                          !img.url!.contains('undefined'))
                          .toList() : [],
                    ),
                      // ImageCarousel(
                      //   images: ((planActive == true &&
                      //       loginController.userData.first.details?["plan"]?["basePlan"]?["details"]?["images"] == true))||
                      //       isAdminUser||userId==editUserId
                      //       ? loginController.userData.first.images.map((img) =>  img).toList() : [],),
                      SizedBox(height: size*0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                            loginController.userData.first.userType??"",
                            // "Dental Clinic",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(
                              context,fontWeight: FontWeight.normal)
                        ),),
                      const SizedBox(width: 20,),
                      if(userType=='superAdmin'||userType=='admin')
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(color:loginController.userData.first.isActive
                              ? Colors.green
                              : Colors.redAccent,borderRadius: BorderRadius.circular(10) ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              "•${loginController.userData.first.isActive ? 'Active' : 'Inactive'}",
                              style: TextStyle(
                                  color: AppColors.white,fontWeight: FontWeight.bold,fontSize: size*0.025),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                      SizedBox(height: size*0.01,),
              if(isAdminUser)
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                       "Active/Inactive",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(
                          context,fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(width: 6,),
                    GetBuilder<LoginController>(
                        init: LoginController(),
                        builder: (controller) {
                          return Switch(
                        value: loginController.userData.first.isActive,
                            activeColor: loginController.userData.first.isActive ? AppColors.primary : Colors.red,
                            activeTrackColor: AppColors.primary.withOpacity(0.5),
                        inactiveThumbColor: Colors.red,
                          inactiveTrackColor: Colors.grey.shade400,
                          onChanged: (value) {
                        showDeactivateConfirmDialog(
                        context: context,
                        isActivating: value,
                        onConfirm: ()async {
                          loginController.userData.first.isActive==true?    await  loginController.deactivateUserAdmin(loginController.userData.first.userId??"",false,context): await  loginController.deactivateUserAdmin(loginController.userData.first.userId??"",true,context);
                          print("${ loginController.userData.first.isActive??""} ""active status");
                        // await loginController.getProfileByUserId(loginController.userData.first.userId??"", context);
                          loginController.update();
                          },
                        );
                        },
                        );
                      }
                    ),
                  ],
                ),
              ),
                      SizedBox(height: size*0.01,),
                      Center(
                        child: Text(
                       (loginController.userData.first.details["name"]??"").toString()??"",
                          // "Catchy Dental Clinic",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitle(
                              context,)
                        ),),
                      SizedBox(height: size*0.005,),
                      Row(
                        children: [
                          IconButton(onPressed: (){
                            if(loginController.userData.first.location.toString().isNotEmpty&&(planActive==true
                                &&loginController.userData.first.details["plan"]?["basePlan"]?["details"]?["location"]==true|| isAdminUser)){

                              if(PlatformHelper.platform=='Android'||PlatformHelper.platform=='iOS') {
                                Get.toNamed('/webViewProfilePage', arguments: {
                                  "url": loginController.userData.first.location
                                      .toString() ?? "",
                                  "clinicName": loginController.userData.first
                                      .details["name"].toString() ?? ""
                                });
                              }
                          }
                        }, icon: Icon(Icons.place,color: AppColors.primary,size: size*0.05,)),


                          Center(
                            child: Text(
                              loginController.userData.isNotEmpty && loginController.userData.first.address != null
                                  ? "${loginController.userData.first.address['state'] ?? ''}, ${loginController.userData.first.address['district'] ?? ''},${loginController.userData.first.address['city'] ?? ''}"
                                  : "",  style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size*0.02,),

                      if( loginController.userData.first.name.isNotEmpty)
                      Center(
                        child: Text(
                            "Name: Dr.${loginController.userData.first.name.toString()??""}",
                            // "Catchy Dental Clinic",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(
                              context,color:AppColors.black,fontWeight: FontWeight.bold)
                        ),
                      ),
                      SizedBox(height: size*0.02,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AnimatedIconButton(
                            iconPath: 'assets/images/watsapp.png',
                            text: 'WhatsApp',
                            onTap: () async {
            final userData = loginController.userData.isNotEmpty
            ? loginController.userData.first
                : null;

            if (userData == null) return;

            final bool isMobileAllowed =
            userData.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true;

            final bool isAdminUser =
            userType == 'admin' || userType == 'superAdmin';

            final bool isMobilePlatform =
            PlatformHelper.platform == 'Android' ||
            PlatformHelper.platform == 'iOS';

            // Exit early if conditions fail
            if (!isMobilePlatform) return;
            if (!planActive) return;
            if (!isMobileAllowed && !isAdminUser) return;

            // WhatsApp call (single place)
            WhatsAppUtils.openWhatsApp(
            phoneNumber: userData.mobileNumber?.toString() ?? '',
            message: "Hi Message From ${userData.details?["name"] ?? ''}",
            );
                            },
                          ),
                          AnimatedIconButton(
                            iconPath: 'assets/images/web.png',
                            text: 'Website',
                            onTap: () async {
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
                            },
                          ),
                          AnimatedIconButton(
                            iconPath: 'assets/images/call.png',
                            text: 'Call',
                            onTap: () async {
                       if((planActive==true&&loginController.userData.first.details["plan"]?["basePlan"]?["details"]?["mobileNumber"]==true)|| isAdminUser) {
                               launchCall(loginController.userData.first.mobileNumber.toString() ?? "");
                                          }
                                           },
                          ),
                        ],
                      ),

                      SizedBox(height: size*0.02,),
                      if (loginController.userData.isNotEmpty &&
                          loginController.userData.first.details["description"] != null)
                        Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                            "Description",
                            textAlign: TextAlign.center,softWrap: true,
                            style: TextStyle(
                              color: AppColors.black,fontWeight: FontWeight.bold,fontSize: size*0.035)
                        ),
                      ),
                      Center(
                        child: Text(
                          loginController.userData.first.details["description"]??"A dental clinic provides comprehensive oral health care services, including routine check-ups, teeth cleaning, preventive care, restorative treatments, and cosmetic dentistry. The clinic is dedicated to maintaining healthy smiles through modern equipment, skilled professionals, and a comfortable, patient-friendly environment.",
                            softWrap: true,
                            style: AppTextStyles.caption(
                              context,color: AppColors.black,fontWeight: FontWeight.normal)
                        ),),
                      SizedBox(height: size*0.05,),
                     // if(serviceController.serviceList.isNotEmpty&&(planActive==true&&loginController.userData.first.details["plan"]?["basePlan"]?["details"]["services"]==true|| isAdminUser))
                    TabBar(
                    controller: _tabController1,
                    labelColor: AppColors.black,
                    unselectedLabelColor: Colors.black,
                    unselectedLabelStyle: AppTextStyles.caption(
                    context, fontWeight: FontWeight.bold),
                    tabs:  [
                    const Tab(text: 'Our Services'),
                    if(userType=='superAdmin'||userType=='admin')  const Tab(text: 'Certificate'),

                    ],
                    ),
                    SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: TabBarView(
                    controller: _tabController1,
                    children: [
                      if(serviceController.serviceList.isNotEmpty&&planActive==true&&loginController.userData.first.details["plan"]?["basePlan"]?["details"]["services"]==true|| isAdminUser||userId==editUserId)
                     ListView(
                       // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text('Services',style: AppTextStyles.body(context,fontWeight: FontWeight.bold),),
                          GetBuilder<ServiceController>(
                            builder: (controller) {
                              return Column(
                                children: [
                                  SizedBox(height: size*0.02,),
                                  if(serviceController.serviceList.isEmpty)
                                    Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                                  if(serviceController.isLoading)
                                    const Center(child: CircularProgressIndicator(color: AppColors.primary,)),

                                  if(serviceController.serviceList.isNotEmpty)
                                 AnimationLimiter(
                                   child: ListView.builder(
                                      itemCount: serviceController.serviceList.length,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (BuildContext context, int index) {
                                        final service=serviceController.serviceList[index];
                                        print("${AppConstants.baseUrl}${service.image.toString()??""}");
                                        if (service.image != null && service.image!.isNotEmpty) {
                                         // imgUrl = AppConstants.baseUrl + service.image!.first.replaceAll("\\", "/");
                                          imgUrl = service.image!.first.replaceAll("\\", "/");
                                        }
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
                                                  decoration: BoxDecoration(border: Border.all(color: AppColors.grey,width: 0.3),borderRadius: BorderRadius.circular(10)),
                                                  height: size * 0.31,
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .center,
                                                      children: [
                                                        Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            mainAxisAlignment: MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              Text(service.serviceTitle.toString()??"",
                                                                style: AppTextStyles.body(
                                                                    context,fontWeight: FontWeight.bold,
                                                                    color: AppColors.black),),
                                                              Text(
                                                                "Price Starts from ₹ ${service.serviceCost.toString()??""}",
                                                                style: AppTextStyles.caption(
                                                                    context,
                                                                    color: AppColors.grey),),
                                                              Center(
                                                                child: IconButton(onPressed: (){
                                                                  serviceController.getServiceDetailAdmin(service.serviceId.toString()??"", context);
                                                                  Get.toNamed('/viewServicePage',arguments: {"serviceId":service.serviceId.toString()??""});
                                                                }, icon: Icon(Icons.arrow_forward,color: Colors.black54,size: size*0.07,)),
                                                              )

                                                            ]),
                                                        const SizedBox(width: 10),

                                                        ClipRRect(borderRadius: BorderRadius.circular(8),
                                                          child: Image.network(
                                                            imgUrl,
                                                            fit: BoxFit.cover,
                                                            height: size * 0.18,
                                                            width: size * 0.18,
            errorBuilder: (context, error, stackTrace) {
            return Container(
              height: size * 0.18,
              width: size * 0.18,
            decoration: BoxDecoration(
            color: const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
            Icons.image_outlined,
            color: Colors.grey.shade400,
            size: size * 0.08,
            ),
            );}
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
                                 ),]
                              );
                            }
                          ),
                          ]),
                  if(isAdminUser)
                  GetBuilder<LoginController>(
                  builder: (controller) {
                    return Column(
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
                    );
                  }
                          )
                          ]),)


                    ],
                  ),
                ],
                          ),
              ),
            );
        }
      ),
    ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
