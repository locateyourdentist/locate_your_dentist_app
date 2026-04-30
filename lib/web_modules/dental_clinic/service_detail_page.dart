import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/product_services/images_scroll_viewing.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class ServiceDetailPageWeb extends StatefulWidget {
  const ServiceDetailPageWeb({Key? key}) : super(key: key);

  @override
  State<ServiceDetailPageWeb> createState() => _ServiceDetailPageWebState();
}

class _ServiceDetailPageWebState extends State<ServiceDetailPageWeb>
    with SingleTickerProviderStateMixin {

  final serviceController = Get.put(ServiceController());
  final loginController = Get.put(LoginController());

  String? serviceId;

  late AnimationController _controller;

  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  late Animation<double> _imageFade;
  late Animation<Offset> _imageSlide;

  late Animation<double> _priceFade;
  late Animation<Offset> _priceSlide;

  late Animation<double> _descFade;
  late Animation<Offset> _descSlide;

  @override
  void initState() {
    super.initState();

    /// Get service id
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['serviceId'] != null) {
      serviceId = args['serviceId'].toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        serviceController.getServiceDetailAdmin(serviceId!, context);
      });
    }

    /// Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    /// Title Animation
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    /// Image Animation
    _imageFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeIn),
      ),
    );

    _imageSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOut),
      ),
    );

    /// Price Animation
    _priceFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeIn),
      ),
    );

    _priceSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
      ),
    );

    /// Description Animation
    _descFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _descSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (serviceId != null) {
      await serviceController.getServiceDetailAdmin(serviceId!, context);
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<ServiceController>(
        builder: (_) {
          if (serviceController.serviceDetails.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final service = serviceController.serviceDetails.first;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Row(
              children: [
                const AdminSideBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child:ConstrainedBox(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SlideTransition(
                                position: _titleSlide,
                                child: FadeTransition(
                                  opacity: _titleFade,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      service.serviceTitle ?? "",
                                      style: AppTextStyles.body(
                                        context,
                                        color: AppColors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),
                              SlideTransition(
                                position: _imageSlide,
                                child: FadeTransition(
                                  opacity: _imageFade,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    padding:  EdgeInsets.all(16),
                                    child: NetworkImageCarousel(
                                      services: loginController.serviceFileImages
                                          .map((e) => e.url ?? "")
                                          .toList(),                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),
                              SlideTransition(
                                position: _priceSlide,
                                child: FadeTransition(
                                  opacity: _priceFade,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          "₹ ${service.serviceCost}",
                                          style: AppTextStyles.subtitle(
                                            context,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SlideTransition(
                                position: _descSlide,
                                child: FadeTransition(
                                  opacity: _descFade,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Description',
                                          style: AppTextStyles.body(
                                            context,
                                            color: AppColors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                         SizedBox(height: size*0.001),
                                        Text(
                                          service.serviceDescription ?? "",
                                          style: AppTextStyles.caption(
                                            context,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
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
        },
      ),
    );
  }
}
