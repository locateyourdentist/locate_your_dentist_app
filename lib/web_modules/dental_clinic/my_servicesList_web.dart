import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';


class ViewListServicesWebsite extends StatefulWidget {
  const ViewListServicesWebsite({super.key});

  @override
  State<ViewListServicesWebsite> createState() => _ViewListServicesWebsiteState();
}

class _ViewListServicesWebsiteState extends State<ViewListServicesWebsite> {
  final serviceController=Get.put(ServiceController());
  final loginController=Get.put(LoginController());
  String imgUrl = "";
  @override
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
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<ServiceController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: Row(
                children: [
                  const AdminSideBar(),

                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Container(
                            width: double.infinity,
                            //color: Colors.grey[100],
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                              ],
                            ),
                            child: Padding(
                              padding:  const EdgeInsets.all(20.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text('View Lists',
                                             style: AppTextStyles.subtitle(context,color: AppColors.black),),
                                        SizedBox(height: size*0.01,),
                                
                                
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: gradientButton(text: 'Create Services/Products',height: size*0.013,width: size*0.13,
                                          onTap:(){
                                        serviceController.serviceDetails.clear();
                                        loginController.serviceFileImages.clear();
                                        serviceController.selectedServiceId='';
                                        serviceController.titleController.clear();
                                        serviceController.descriptionController.clear();
                                        serviceController.costController.clear();
                                        serviceController.serviceImage!.clear();
                                        Get.toNamed('/addServicesListWebPage',);
                                      },context: context),
                                    ),
                                    SizedBox(height: size*0.01,),
                                
                                        if(serviceController.serviceList.isEmpty)
                                      Center(child: Text('No data found',style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),),
                                    if(serviceController.isLoading)
                                      const CircularProgressIndicator(color: AppColors.primary,),
                                
                                    if (serviceController.serviceList.isNotEmpty)
                                      AnimationLimiter(
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: serviceController.serviceList.length,
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: (size ~/ 350).clamp(1, 4),
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20,
                                            childAspectRatio: 1,
                                          ),
                                          itemBuilder: (context, index) {
                                            final service = serviceController.serviceList[index];
                                            // String imgUrl = (service.image != null && service.image!.isNotEmpty)
                                            //     ? service.image!.first.replaceAll("\\", "/") : "";
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
                                            return AnimationConfiguration.staggeredGrid(
                                              position: index,
                                              duration: const Duration(milliseconds: 600),
                                              columnCount: 4,
                                              child: ScaleAnimation(
                                                child: FadeInAnimation(
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: GestureDetector(
                                                      onTap: () async{
                                                        await serviceController.getServiceDetailAdmin(service.serviceId.toString(), context);
                                                        Get.toNamed('/serviceDetailPageWeb', arguments: {"serviceId": service.serviceId.toString()});
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(10),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors.black12,
                                                              blurRadius: 8,
                                                              offset: Offset(0, 4),
                                                            )
                                                          ],
                                                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                                              child: Image.network(
                                                                imgUrl,
                                                                fit: BoxFit.cover,
                                                                height: size * 0.09,
                                                                width: double.infinity,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return Container(
                                                                    height: size * 0.08,width: double.infinity,
                                                                    color: Colors.grey[200],
                                                                    child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: size*0.022),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.all(5.0),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    service.serviceTitle ?? "",
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: AppTextStyles.caption(
                                                                      context,
                                                                      color: AppColors.black,
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 6),
                                                                  Text(
                                                                    "Starts from ₹ ${service.serviceCost ?? ""}",
                                                                    style: AppTextStyles.caption(context, color: AppColors.black),
                                                                  ),
                                                                  const SizedBox(height: 5),
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed: () async{
                                                                       await   serviceController.getServiceDetailAdmin(service.serviceId.toString(), context);
                                                                          Get.toNamed('/addServicesListWebPage',);
                                                                        },
                                                                        icon: Icon(Icons.edit, color: AppColors.primary, size: size*0.012),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed: () async {
                                                                          confirmRemoveImage(context, index, () async {
                                                                            await serviceController.deactivateService(service.serviceId.toString(), context);
                                                                            serviceController.update();
                                                                            await serviceController.getServiceListAdmin(Api.userInfo.read('userId') ?? "", context);
                                                                            Navigator.pop(context);
                                                                          });
                                                                        },
                                                                        icon:  Icon(Icons.delete, color: Colors.redAccent, size: size*0.012),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
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
                                          },
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
