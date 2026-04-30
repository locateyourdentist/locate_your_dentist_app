import 'dart:convert';
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
import 'package:flutter_quill/flutter_quill.dart';
import 'package:url_launcher/url_launcher.dart';


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
  final ScrollController _scrollController = ScrollController();
  late QuillController _controller;
  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      if (data == null) {
        delta = [{"insert": "\n"}];
      }

      else if (data is List) {
        delta = List<Map<String, dynamic>>.from(data);
      }

      else if (data is String) {
        delta = List<Map<String, dynamic>>.from(jsonDecode(data));
      }

      _controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );

      setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      _controller = QuillController.basic();
      setState(() {});
    }
  }
  @override
  void initState() {
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
        ),
      ),
    );
    _refresh();
      super.initState();
  }
  Future<void> _refresh() async {
    await serviceController.getServiceListAdmin(Api.userInfo.read('selectUId')??"", context);
   await loginController.getProfileByUserId(Api.userInfo.read('selectUId')??"", context);
   if (!mounted) return;
    final data = loginController.userData.isNotEmpty
        ? loginController.userData.first.details["description"]
        : null;
    loadJobDescription(data);
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
    String userId=Api.userInfo.read('userId')??"";
    final user = loginController.userData.isNotEmpty ? loginController.userData.first : null;
    String editUserId = user?.userId?.toString() ?? "";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    final isSameUser = Api.userInfo.read('token') != null && user != null && user.userId.toString() == Api.userInfo.read('userId');
    print("isSameUser: $isSameUser");
    // Future<void> _refresh() async {
    //   //_tabController1 = TabController(length:userType=='superAdmin'? 2:1, vsync: this,);
    //  // serviceController.getServiceListAdmin(loginController.userData.isNotEmpty?loginController.userData.first.userId.toString():"", context);
    //   await serviceController.getServiceListAdmin(Api.userInfo.read('selectUId')??"", context);
    //  await loginController.getProfileByUserId(Api.userInfo.read('selectUId')??"", context);
    // }
    PreferredSizeWidget buildAppBar() {
      if (Api.userInfo.read('token') != null) {
        return CommonWebAppBar(
          height: size * 0.03,
          title: "LYD",
          onLogout: () {},
          onNotification: () {},
        );
      } else {
        return   CommonHeader();
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
                                  height: size*0.15,
                                  padding: const EdgeInsets.all(15),
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          loginController.logoImage.isNotEmpty
                                              ? loginController.logoImage.first ?? ""
                                              : "",
                                          // loginController.editImages.isNotEmpty
                                          //     ? loginController.editImages.first.url ?? ""
                                          //     : "",
                                          height: size*0.08,
                                          width: size*0.08,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: size*0.08,
                                            width: size*0.08,
                                            color: Colors.grey.shade200,
                                            child:  Icon(Icons.image, size: size*0.012,color: AppColors.grey,),
                                          ),
                                        ),
                                      ),

                                       SizedBox(width: size*0.01),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                   user?.details["name"] ?? "",
                                                    style: AppTextStyles.body(context,fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                      if(userType=='admin'||userType=='superAdmin'||userId==editUserId)
                                                        GestureDetector(
                                                          onTap: (){
                                                            loginController.getProfileByUserId(user?.userId??"", context);
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

                                            SizedBox(height: size*0.0001,),

                                            if(isAdminUser)
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        user?.userType ?? "",
                                                        style:  AppTextStyles.caption(context,color: Colors.grey),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                      if(Api.userInfo.read('userType')=='superAdmin'||Api.userInfo.read('userType')=='admin')
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: user?.isActive==true
                                                            ? Colors.green
                                                            : Colors.red,
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(
                                                        user?.isActive==true
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
                                                 SizedBox(width: size*0.001,),
                                                Text(
                                                  "${user?.address['city'] ?? ''}, "
                                                      "${user?.address['district'] ?? ''}",
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: size*0.01,),

                                            Row(
                                              children: [
                                                _actionButton(Icons.call, "Call", () async{
                                                  if ((planActive == true &&
                                                      user?.details["plan"]?["basePlan"]?["details"]?["mobileNumber"] ==
                                                          true) ||
                                                      isAdminUser) {
                                                   await launchCall(user?.mobileNumber
                                                        .toString() ?? "");
                                                  }
                                                },context
                                              ),
                                                 SizedBox(width: size*0.01),
                                                _actionButton(Icons.language, "Website",
                                                        () {
                                                          if((planActive==true&&user?.details["plan"]?["basePlan"]?["details"]?["location"]==true)||
                                                              isAdminUser) {
                                                            if (PlatformHelper.platform == 'Android' ||
                                                                PlatformHelper.platform == 'iOS') {
                                                              Get.toNamed('/webViewProfilePage', arguments: {
                                                                "url": loginController.userData.first
                                                                    .details["website"] ?? "".toString() ?? "",
                                                                "clinicName": user?.details["name"] ?? "".toString()
                                                              });
                                                              if (user?.details["website"] ?? ""
                                                                  .toString()
                                                                  .isEmpty || user?.details["website"] ??
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
                                                SizedBox(width: size*0.01,),
                                                if (Api.userInfo.read('token') != null && isSameUser != true)
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

                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),
                                SizedBox(
                                  height: size*0.03,
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
                                       // if(user?.details["description"].isNotEmpty)
                                         Text("Description",
                                            style: AppTextStyles.body(fontWeight: FontWeight.bold,context)),
                                      //  const SizedBox(height: 10),
                                        // Text(
                                        //   //"Cherub Fertility and women's centre is a Gynecology/Obstetrics Clinic in Rajakilpakkam, Chennai. The clinic is visited by gynecologist like Dr. Florence Vasantha Praba. The timings of Cherub Fertility and women's centre are: Mon-Sun: 00:00-23:59. Some of the services provided by the Clinic are: Abortion / Medical Termination of Pregnancy (MTP),Gynaecological Endoscopy,Gynae Problems,Gynaec Laparoscopy and Female Infertility Treatment etc. Click on map to find directions to reach Cherub Fertility and women's centre. ",
                                        //   loginController.userData.first.details["description"] ?? "No Data found",
                                        //   style:AppTextStyles.caption(fontWeight: FontWeight.normal,context),
                                        // ),
                                        Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  IgnorePointer(
                                              child: QuillEditor(
                                                controller: _controller,
                                                scrollController: _scrollController,
                                                focusNode: FocusNode(),
                                                config: const QuillEditorConfig(
                                                  showCursor: false,
                                                  expands: false,
                                                ),
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                        Container(
                                          height: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: _cardDecoration(),
                                          child: SingleChildScrollView(
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
                                              //if ((serviceController.serviceList.isNotEmpty && planActive == true && loginController.userData.first.details["plan"]?["basePlan"]?["details"]["services"] == true) || isAdminUser || userId == editUserId)
                                                if (serviceController.serviceList.isNotEmpty && (
                                                        planActive == true && user?.details["plan"]?["basePlan"]?["details"]["services"] == true ||
                                                            isAdminUser == true || userId == editUserId))
                                                Container(
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color:Colors.grey.shade100),
                                                  child: Column(
                                                    children: [
                                                   GridView.builder(
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
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
                                                        Get.toNamed('/serviceDetailPageWeb',arguments: {"serviceId":service.serviceId.toString()??""});
                                                        },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Container(
                                                          height: size*0.3,
                                                          padding: const EdgeInsets.all(10),
                                                         //color: Colors.white,
                                                          decoration: _cardDecoration(),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Row(
                                                              children: [
                                                                ClipRRect(
                                                            borderRadius: BorderRadius.circular(8),
                                                            child: Image.network(
                                                              service.image?.isNotEmpty == true
                                                                  ? service.image!.first
                                                                  : "",
                                                              width: size*0.06,
                                                              height: size * 0.3,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_, __, ___) {
                                                                return Container(
                                                                  width: size*0.06,
                                                                  height: size * 0.3,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.grey.shade200,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: Center(
                                                                    child: Icon(
                                                                      Icons.broken_image_outlined,
                                                                      size: size * 0.015,
                                                                      color: Colors.grey.shade500,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),), SizedBox(width: size*0.01), Expanded(
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
                                                                                              ),
                                                      ),
                                                                                    );
                                                                                  },
                                                                                ),]
                                                  ),
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
                                                                  child:GestureDetector(
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
                                                                              "${user?.userType} Certificate",
                                                                              //labProfile['address'].toString(),
                                                                              // "Catchy Dental Clinic",
                                                                              textAlign: TextAlign.center,
                                                                              style: AppTextStyles.caption(
                                                                                  context, color: AppColors.black)
                                                                          ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(10.0),
                                                                        child: ClipRRect(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          child: Builder(
                                                                            builder: (context) {
                                                                              final url = loginController.editCertificates[index].url ?? "";

                                                                              if (url.toLowerCase().endsWith(".pdf")) {
                                                                                return Container(
                                                                                  height: size * 0.3,
                                                                                  width: size * 0.3,
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(color: AppColors.grey, width: 0.6),
                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                  ),
                                                                                  child: Center(
                                                                                    child: ElevatedButton.icon(
                                                                                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                                                                      label: const Text("Open PDF"),
                                                                                      onPressed: ()async {
                                                                                        final Uri pdfUri = Uri.parse(url);
                                                                                        if (await canLaunchUrl(pdfUri)) {
                                                                                        await launchUrl(
                                                                                        pdfUri,
                                                                                        mode: LaunchMode.externalApplication,
                                                                                        );
                                                                                        } else {
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                        const SnackBar(content: Text("Could not open PDF")),
                                                                                        );
                                                                                        }                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              } else {
                                                                                return Image.network(
                                                                                  url,
                                                                                  fit: BoxFit.cover,
                                                                                  height: size * 0.3,
                                                                                  width: size * 0.3,
                                                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                                                    decoration: BoxDecoration(
                                                                                      border: Border.all(color: AppColors.grey, width: 0.6),
                                                                                    ),
                                                                                    height: size * 0.15,
                                                                                    width: size * 0.3,
                                                                                    child: Center(
                                                                                      child: Icon(
                                                                                        Icons.image,
                                                                                        color: AppColors.grey,
                                                                                        size: size * 0.016,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
                                                                            },
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
      width: size*0.063,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding:  EdgeInsets.symmetric(horizontal: size*0.0035, vertical: size*0.005,),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: size*0.01,color: Colors.grey,),
               SizedBox(width: size*0.003),
              Text(label,style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.primary),),
            ],
          ),
        ),
      ),
    );
  }
}
