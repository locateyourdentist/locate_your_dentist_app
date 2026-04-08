import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common_widgets/color_code.dart';


class DashboardCarousel extends StatefulWidget {
  final List<String> imageList;
  final Function(int index)? onIndexChanged;

  const DashboardCarousel({
    Key? key,
    required this.imageList,
    this.onIndexChanged,
  }) : super(key: key);

  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    if (widget.imageList.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          'assets/images/job poster.png',
          width: double.infinity,
          height: size * 0.5,
          fit: BoxFit.cover,
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          items: widget.imageList.map((img) {
            return GestureDetector(
              onTap: (){
                print('ffgdf$img');
                //if (img.isEmpty) return;
                Get.toNamed('/viewImagePage', arguments: {
                  'url': img,
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: img.startsWith("http")
                    ? Image.network(
                  img,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/job poster.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  'assets/images/job poster.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: size * 0.5,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration:
            const Duration(milliseconds: 800),
            viewportFraction: 1,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
              widget.onIndexChanged?.call(index);
            },
          ),
        ),

        const SizedBox(height: 12),

        if (widget.imageList.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageList.asMap().entries.map((entry) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentIndex == entry.key ? 22 : 10,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentIndex == entry.key
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}