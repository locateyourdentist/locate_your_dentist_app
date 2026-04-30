import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/serviceModel.dart';

class NetworkImageCarousel extends StatefulWidget {
  //final List<ServiceModel> services;
  final List<String> services;

  const NetworkImageCarousel({super.key, required this.services});

  @override
  State<NetworkImageCarousel> createState() => _NetworkImageCarouselState();
}

class _NetworkImageCarouselState extends State<NetworkImageCarousel> {
  int currentIndex = 0;

  void showPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void showNext() {
    if (currentIndex < widget.services.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (widget.services.isEmpty) {
      return SizedBox(
        width: width * 0.9,
        height: width * 0.6,
        child: Center(child: Text("No Images",style: AppTextStyles.caption(context),)),
      );
    }

    // String? imageUrl;
    // final currentService = widget.services[currentIndex];
    // if (currentService.image != null && currentService.image!.isNotEmpty) {
    //   //imageUrl = "${AppConstants.baseUrl}${currentService.image![0].replaceAll("\\", "/")}";
    //   imageUrl = "${currentService.image![0].replaceAll("\\", "/")}";
    // }
   // String imageUrl = widget.services[currentIndex].replaceAll("\\", "/");
    final img = widget.services[currentIndex];

    String imageUrl = (img ?? "").replaceAll("\\", "/");
    return SizedBox(
      height: width * 0.23,
      width: width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
            //imageUrl != null ?

            Image.network(
              imageUrl??"",
              width: width * 0.6,
              height: width * 0.23,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width * 0.6,
                  height: width * 0.23,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey.shade400,
                    size: width * 0.08,
                  ),
                );
              },
            )
            //     : Container(
            //   width: width * 0.9,
            //   height: width * 1,
            //   color: Colors.grey.shade300,
            //   child: const Center(child: Text("No Image")),
            // ),
          ),

          // Left Arrow
          if (currentIndex > 0)
            Positioned(
              left: 0,
              child: IconButton(
                onPressed: showPrevious,
                icon: const Icon(Icons.arrow_left, size: 50, color: Colors.black54),
              ),
            ),

          // Right Arrow
          if (currentIndex < widget.services.length - 1)
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: showNext,
                icon: const Icon(Icons.arrow_right, size: 50, color: Colors.black54),
              ),
            ),

          // Indicator
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.services.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 12 : 8,
                  height: currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index ? Colors.white : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
