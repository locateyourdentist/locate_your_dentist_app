import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClinicImageCarousel extends StatefulWidget {
  const ClinicImageCarousel({super.key, required this.imageUrls});
  final List<String> imageUrls;

  @override
  State<ClinicImageCarousel> createState() => _ClinicImageCarouselState();
}

class _ClinicImageCarouselState extends State<ClinicImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height;

    if (widget.imageUrls.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: size * 0.4,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.33,
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
                onTap: () {
                  Get.toNamed('/viewImagePage', arguments: {'url': url});
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