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
      return SizedBox();
      //   Container(
      //   height: size * 0.4,
      //   width: double.infinity,
      //   decoration: BoxDecoration(
      //     color: Colors.grey[200],
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      //   child:  Center(
      //     child: Icon(Icons.image_not_supported, size: size*0.03, color: Colors.grey),
      //   ),
      // );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: size * 0.4,
            autoPlay: true,
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.imageUrls.map((url) {
            return GestureDetector(
              onTap: () {
                Get.toNamed('/viewImagePage', arguments: {'url': url});
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageUrls.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(
                      _currentIndex == entry.key ? 0.9 : 0.4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}