import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';

class ClinicImageCarousel extends StatefulWidget {
  const ClinicImageCarousel({super.key, required this.imageUrls});
  final List<String> imageUrls;

  @override
  State<ClinicImageCarousel> createState() => _ClinicImageCarouselState();
}

class _ClinicImageCarouselState extends State<ClinicImageCarousel> {
  int _currentIndex = 0;
  final loginController = Get.put(LoginController());
  final planController = Get.put(PlanController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (widget.imageUrls.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height:width>600? size * 0.35:size * 0.2,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction:width>600? 0.33:0.5,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.imageUrls.map((url) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: GestureDetector(
                onTap: () async {
                  Get.toNamed('/viewImagePage', arguments: {'url': url});
                  Api.userInfo.write('selectUId', planController.posterImage[0].userId.toString());
                  await loginController.getProfileByUserId(planController.posterImage[0].userId.toString(), context);
                  Get.toNamed('/clinicProfileWebPage');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
            return Container(
              width: _currentIndex == entry.key ? 10 : 8,
              height: _currentIndex == entry.key ? 10 : 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == entry.key
                    ? Colors.black
                    : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}