import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


class ViewListServices extends StatefulWidget {
  const ViewListServices({super.key});

  @override
  State<ViewListServices> createState() => _ViewListServicesState();
}

class _ViewListServicesState extends State<ViewListServices> {
final serviceController=Get.put(ServiceController());
final loginController=Get.put(LoginController());
String imgUrl = "";
  void initState() {
    super.initState();
    serviceController.getServiceListAdmin(Api.userInfo.read('userId')??"", context);
  }
Future<void> _refresh() async {
  serviceController.getServiceListAdmin(Api.userInfo.read('userId')??"", context);
}
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(centerTitle: true,
        backgroundColor:AppColors.scaffoldBg,
        title: Text('View Lists',
          style: AppTextStyles.subtitle(context,color: AppColors.black),),automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
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

      actions: [Container(
        decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
        child: IconButton(
          onPressed: () {
            serviceController.serviceDetails.clear();
            loginController.serviceFileImages.clear();
            serviceController.selectedServiceId='';
            serviceController.titleController.clear();
            serviceController.descriptionController.clear();
            serviceController.costController.clear();
            serviceController.serviceImage!.clear();
            Get.toNamed('/createServicesPage');
          },
          icon: Icon(Icons.add,color: AppColors.white,size: size*0.06,),
        ),
      ),],
      ),

      body: GetBuilder<ServiceController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    if(serviceController.serviceList.isEmpty)
                      Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                    if(serviceController.isLoading)
                      const CircularProgressIndicator(color: AppColors.primary,),

                      if(serviceController.serviceList.isNotEmpty)
                    AnimationLimiter(
                      child: ListView.builder(
                          itemCount: serviceController.serviceList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context,index) {
                            final service=serviceController.serviceList[index];
                            //print("${AppConstants.baseUrl}${service.image.toString()??""}");
                            // if (service.image != null && service.image!.isNotEmpty) {
                            //   imgUrl =  service.image!.first.replaceAll("\\", "/");
                            // }
                            String imgUrl = "";

                            if (service.image != null && service.image!.isNotEmpty) {
                              final validImages = service.image!
                                  .where((e) =>
                              e != null &&
                                  e.toString().isNotEmpty &&
                                  e != "[]" &&
                                  e.toString().startsWith("http"))
                                  .toList();

                              if (validImages.isNotEmpty) {
                                imgUrl = validImages.first.replaceAll("\\", "/");
                              }
                            }
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 1300),
                              child: SlideAnimation(
                                verticalOffset: 120.0,
                                curve: Curves.easeOutBack,
                                child: FadeInAnimation(
                                  child: Padding(
                                    padding:  const EdgeInsets.all(10.0),
                                    child: GestureDetector(
                                      onTap: (){
                                        serviceController.getServiceDetailAdmin(service.serviceId.toString()??"", context);
                                        Get.toNamed('/viewServicePage',arguments: {"serviceId":service.serviceId.toString()??""});
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(color: AppColors.white,borderRadius: BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                             //crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.network(
                                                  imgUrl,
                                                  fit: BoxFit.cover,
                                                  width: size*0.25,
                                                  height:  size*0.25,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: size * 0.25,
                                                      height: size * 0.25,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF1F3F6),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Icon(
                                                        Icons.image_outlined,
                                                        color: Colors.grey.shade400,
                                                        size: size * 0.08,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: size*0.02,),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(service.serviceTitle.toString()??"",softWrap: true, style: AppTextStyles.caption(
                                                        context, color: AppColors.black,fontWeight: FontWeight.bold),),
                                                   SizedBox(height: size*0.02,),
                                                    Text("Starts from ₹${service.serviceCost.toString()??""}",style: AppTextStyles.caption(
                                                        context, color: AppColors.grey),),
                                                    SizedBox(height: size*0.01,),

                                                  ],
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                  //mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      serviceController.getServiceDetailAdmin(service.serviceId.toString()??"",context);
                                                      Get.toNamed('/createServicesPage');
                                                      },
                                                    icon:  Icon(Icons.edit, color: AppColors.primary,size: size*0.05,),
                                                  ),
                                                  //SizedBox(height: 10,),
                                                  IconButton(
                                                    onPressed: ()async {
                                                      confirmRemoveImage(context, index, () async{
                                                       await serviceController.deactivateService(service.serviceId.toString()??"",context);
                                                        serviceController.update();
                                                       await serviceController.getServiceListAdmin(Api.userInfo.read('userId')??"", context);
                                                        Navigator.of(context).pop();
                                                        //Get.back();
                                                      });
                                                    },
                                                    icon: Icon(Icons.delete, color: Colors.redAccent,size: size*0.05,),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
}
