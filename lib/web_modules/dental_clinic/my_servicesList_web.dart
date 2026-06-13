import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class ViewListServicesWebsite extends StatefulWidget {
  const ViewListServicesWebsite({super.key});
  @override
  State<ViewListServicesWebsite> createState() => _ViewListServicesWebsiteState();
}

class _ViewListServicesWebsiteState extends State<ViewListServicesWebsite> {
  final GlobalKey<ScaffoldState> _scaffoldKeyService = GlobalKey<ScaffoldState>();
  final serviceController = Get.put(ServiceController());
  final loginController = Get.put(LoginController());
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
    await serviceController.getServiceListAdmin(Api.userInfo.read('userId') ?? "", context);
  }
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    return Scaffold(
      key: _scaffoldKeyService,
      backgroundColor: AppColors.scaffoldBg,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: Row(
        children: [
          if (isLoggedIn && isDesktop) const AdminSideBar(),
          Expanded(
            child: GetBuilder<ServiceController>(
              builder: (controller) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: Stack(
                    children: [
                      if (isLoggedIn && !isDesktop)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 10),
                          child: IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => _scaffoldKeyService.currentState?.openDrawer(),
                          ),
                        ),

                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(isMobile ? 10 : 30, isLoggedIn && !isDesktop ? 60 : 30, isMobile ? 10 : 30, 30),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('My Services', style: AppTextStyles.subtitle(context)),
                                        _buildCreateButton(),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    if (controller.isLoading) _buildShimmerGrid(isMobile)
                                    else if (controller.serviceList.isEmpty) _buildEmptyState()
                                    else _buildGrid(isMobile, controller.serviceList),
                                  ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      icon: const Icon(Icons.add),
      label: const Text("Create"),
      onPressed: () {
        serviceController.serviceDetails.clear();
        loginController.serviceFileImages.clear();
        serviceController.selectedServiceId = '';
        serviceController.titleController.clear();
        serviceController.descriptionController.clear();
        serviceController.costController.clear();
        Get.toNamed('/addServicesListWebPage');
      },
    );
  }

  Widget _buildGrid(bool isMobile, List services) {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: isMobile ? 2.5 : 0.8,
        ),
        itemBuilder: (context, index) {
          final double width = MediaQuery.of(context).size.width;
          final service = services[index];
          String imgUrl = (service.image?.isNotEmpty ?? false) ? service.image!.first : "";
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: isMobile ? 1 : 3,
            duration: const Duration(milliseconds: 500),
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: (){
                    Get.toNamed('/serviceDetailPageWeb',arguments: {'serviceId':'${service.serviceId}'});
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Expanded(child: Image.network(imgUrl,height:isMobile ? (width * 0.65) : 300.0,width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image)))),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.serviceTitle ?? "", style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("₹ ${service.serviceCost}", style: const TextStyle(color: AppColors.primary)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () async { await serviceController.getServiceDetailAdmin(service.serviceId.toString(), context); Get.toNamed('/addServicesListWebPage'); }),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _confirmDelete(service.serviceId.toString())),
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
          );
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text("Delete"), content: const Text("Are you sure?"), actions: [
      TextButton(onPressed: () => Get.back(), child:  Text("No",style: AppTextStyles.caption(context),)),
      TextButton(onPressed: () async { 
        await serviceController.deactivateService(id, context); Get.back(); _refresh();
        }, child:  Text("Yes",style: AppTextStyles.caption(context),)),
    ]));
  }

  Widget _buildShimmerGrid(bool isMobile) {
    return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 6, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isMobile ? 1 : 3, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: isMobile ? 2.5 : 0.8), itemBuilder: (_, __) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)))));
  }

  Widget _buildEmptyState() {
    return const Center(child: Column(children: [Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey), SizedBox(height: 10), Text("No services found", style: TextStyle(color: Colors.grey))]));
  }
}
