import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/common_widgets/watsapp_utils.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/modules/profiles/view_profileImages.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:get/get.dart';
import '../../common_widgets/common_widget_all.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

  class LabProfile extends StatefulWidget {
  const LabProfile({super.key});
  @override
  State<LabProfile> createState() => _LabProfileState();
  }
  class _LabProfileState extends State<LabProfile> with SingleTickerProviderStateMixin {
  final loginController =Get.put(LoginController());
  String imgUrl='';
  String? images;
  dynamic planActive;
  late TabController _tabController;
  final serviceController=Get.put(ServiceController());
  final userType = Api.userInfo.read('userType')?.toString() ?? "";
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length:userType=='superAdmin'? 2:1, vsync: this,);
    //loginController.getProfileByUserId(Api.userInfo.read('selectUserId')??"", context);
    _loadPlanStatus();
  }
  void _loadPlanStatus() async {
     planActive = await getPlanActive();
    print('planStatus $planActive');
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  bool getPlanActive() {
   // loginController.getProfileByUserId(Api.userInfo.read('selectUserId')??"", context);
    final userData =  loginController.userData;
    if (userData.isEmpty) return false;
    final raw = userData.first.details["plan"]?["basePlan"]?["isActive"];
    print('raw$raw');
    return raw == true || raw == "true";
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    //print('ff${AppConstants.baseUrl + loginController.userData.first.images[0]}');
    if (loginController.userData.isNotEmpty &&
        loginController.userData.first.images.isNotEmpty) {
      print('ff${loginController.userData.first.images.first}',);
       images = loginController.userData.first.images.first.toString();
       print('Zxxz$images');
    }
    String userId=Api.userInfo.read('userId')??"";
    String editUserId=loginController.userData.isNotEmpty?loginController.userData.first.userId.toString():"";
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,backgroundColor: AppColors.white,
          // title: Text(loginController.userData.isNotEmpty ? "${loginController.userData.first.userType.split(" ").last} Profile" : "Profile",
          //   style: AppTextStyles.subtitle(context,color: AppColors.black),),automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
          actions: [
            if(userType=='admin'||userType=='superAdmin'||userId==editUserId)
              GestureDetector(
                onTap: ()async{
                 //await loginController.getProfileByUserId(loginController.userData.first.userId??"", context);
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
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return SafeArea(
            child: ListView(
              children: [
                //const SizedBox(height: 15,),
                if(loginController.userData.isEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 15,),
                      Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                    ],
                  ),
                if(loginController.isLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.primary,)),
                if(loginController.userData.isNotEmpty)
                Column(
                  children: [
                    MediaCarousel(
                      images: loginController.editImages.isNotEmpty
                          ? loginController.editImages
                          .where((img) =>
                      img.url != null &&
                          img.url!.startsWith('http') &&
                          !img.url!.contains('undefined'))
                          .toList() : [],
                      // images: loginController.editImages
                      //     .where((img) =>
                      // img.url != null &&
                      //     img.url!.startsWith('http') &&
                      //     !img.url!.contains('undefined'))
                      //     .toList(),
                    ),

                           Container(
                      width: double.infinity,
                      transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(50),
                            topRight: Radius.circular(50)),
                      ),
                      child: SingleChildScrollView(
                       // physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                   loginController.userData.first.details["name"],
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: size * 0.04,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,AppColors.secondary
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom( backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),),

                                      onPressed: (){
                                        print(loginController.userData.first.mobileNumber.toString() ?? "");
                                        print(loginController.userData.first.email.toString() ?? "");
                                        Get.toNamed('/labContactForm',arguments:{
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
                                        }, child: Text('Contact',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white),)),
                                )
                              ],
                            ),
                            const SizedBox(height: 5),
                                    Center(
                                    child: Text(
                                    loginController.userData.isNotEmpty && loginController.userData.first.address != null
                                    ? "${loginController.userData.first.address['state'] ?? ''}, ${loginController.userData.first.address['district'] ?? ''},${loginController.userData.first.address['city'] ?? ''}"
                                        : "",  style: const TextStyle(color: Colors.grey),
                                    ),
                                    ),

                       SizedBox(height: size*0.02,),
                            if( loginController.userData.first.name.isNotEmpty)
                              Center(
                                child: Text(
                                    "Name: Dr.${loginController.userData.first.name.toString()??""}",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.caption(
                                        context,color:AppColors.black,fontWeight: FontWeight.bold)
                                ),
                              ),
                            SizedBox(height: size*0.02,),
                            if(isAdminUser)
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                                                    await loginController.getProfileByUserId(loginController.userData.first.userId??"", context);
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
                              ),
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
                            const SizedBox(height: 15),

                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                  "Description",
                                  textAlign: TextAlign.center,softWrap: true,
                                  style: TextStyle(
                                      color: AppColors.black,fontWeight: FontWeight.bold)
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text( loginController.userData.first.details["description"]??"A dental clinic provides comprehensive oral health care services, including routine check-ups, teeth cleaning, preventive care, restorative treatments, and cosmetic dentistry. The clinic is dedicated to maintaining healthy smiles through modern equipment, skilled professionals, and a comfortable, patient-friendly environment.",
                            ),
                            const SizedBox(height: 20),

                            TabBar(
                              controller: _tabController,
                              labelColor: AppColors.black,
                              unselectedLabelColor: Colors.black,
                              unselectedLabelStyle: AppTextStyles.caption(
                                  context, fontWeight: FontWeight.bold),
                              tabs:  [
                                const Tab(text: 'Our Products'),
                              if(userType=='superAdmin')  const Tab(text: 'Certification'),
                              ],
                            ),

                              SizedBox(
                              height: MediaQuery.of(context).size.height * 1.2,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10,),
                                      if(serviceController.serviceList.isEmpty)
                                        Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                                      if(serviceController.isLoading)
                                        const CircularProgressIndicator(color: AppColors.primary,),
                                      if(serviceController.serviceList.isNotEmpty&&(planActive==true&&loginController.userData.first.details["plan"]?["basePlan"]?["details"]["services"]==true||
                                          isAdminUser||userId==editUserId))
                                       // Text('Services',style: AppTextStyles.body(context,fontWeight: FontWeight.bold),),
                                      GetBuilder<ServiceController>(
                                          builder: (controller) {
                                            return AnimationLimiter(
                                              child: ListView.builder(
                                                  itemCount: serviceController.serviceList.length,
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemBuilder: (BuildContext context, int index) {
                                                    final service=serviceController.serviceList[index];
                                                    print("${AppConstants.baseUrl}${service.image.toString()??""}");
                                                    if (service.image != null && service.image!.isNotEmpty) {
                                                      imgUrl = AppConstants.baseUrl + service.image!.first.replaceAll("\\", "/");
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
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(service.serviceTitle.toString()??"",
                                                                            style: AppTextStyles.body(
                                                                                context,fontWeight: FontWeight.bold,
                                                                                color: AppColors.black),),
                                                                          Text(
                                                                            "Price Starts from ${service.serviceCost.toString()??""}",
                                                                            style: AppTextStyles.caption(
                                                                                context,
                                                                                color: AppColors.grey),),
                                                                          IconButton(onPressed: (){
                                                                            serviceController.getServiceDetailAdmin(service.serviceId.toString()??"", context);
                                                                            Get.toNamed('/viewServicePage',arguments: {"serviceId":service.serviceId.toString()??""});
                                                                          }, icon: Icon(Icons.arrow_forward,color: Colors.black54,size: size*0.07,))

                                                                        ]),
                                                                    const SizedBox(width: 10),

                                                                    Column(
                                                                      children: [
                                                                        ClipRRect(borderRadius: BorderRadius.circular(8),
                                                                          child: Image.network(
                                                                            imgUrl,
                                                                            fit: BoxFit.cover,
                                                                            height: size * 0.16,
                                                                            width: size * 0.16,
                                                                            errorBuilder: (context, error, stackTrace) =>
                                                                                Image.asset(
                                                                                  'assets/images/lp3.jpg',
                                                                                  // "assets/images/doctor1.jpg",
                                                                                  fit: BoxFit.cover,
                                                                                  height: size * 0.16,
                                                                                  width: size * 0.16,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ],
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
                                            );
                                          }
                                      ),
                                    ],
                                  ),
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
                                                                    child: Container(
                                                                      //height: size * 0.7,
                                                                      width: double.infinity,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(10),),
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
                                                                          const SizedBox(height: 5,),
                                                                          ClipRRect(
                                                                            borderRadius: BorderRadius.circular(10),
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

                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
  }

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient:  LinearGradient(
                  colors: [ AppColors.primary.withOpacity(0.3),
                    AppColors.secondary.withOpacity(0.6),],
                  //colors: [widget.color.withOpacity(0.2), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Icon(widget.icon, color: widget.color, size: 32),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: AppTextStyles.caption(context,
                  color:  AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
