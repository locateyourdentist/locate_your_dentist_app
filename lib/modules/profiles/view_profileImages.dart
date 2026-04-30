import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/profiles/vedio_plays.dart';


 class MediaCarousel extends StatefulWidget {
 final List<AppImage> images;
 const MediaCarousel({required this.images, super.key});
 @override
  State<MediaCarousel> createState() => _MediaCarouselState();
 }
 class _MediaCarouselState extends State<MediaCarousel> {
  late PageController _pageController;
  int currentPage = 0;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void nextPage() {
    int nextPage = currentPage + 1;
    if (nextPage >= widget.images.length) nextPage = 0;
    setState(() => currentPage = nextPage);
    _pageController.animateToPage(nextPage,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }
  void previousPage() {
    int prevPage = currentPage - 1;
    if (prevPage < 0) prevPage = widget.images.length - 1;
    setState(() => currentPage = prevPage);
    _pageController.animateToPage(prevPage,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }
  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width;
    double containerHeight;

    if (s > 800) {
      // Web / Tablet
      containerHeight = 250;
    } else {
      // Mobile
      containerHeight = s * 5;
    }

    if (widget.images.isEmpty) {
      return Container(
        height: kIsWeb== "Web"? s * 0.1:s*0.75,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey[200],border: Border.all(color: AppColors.grey)),
        //s*0.3,
        child:  Center(
          child: Icon(Icons.image,color: AppColors.grey, size: s*0.012),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: kIsWeb== "Web"? s * 0.15:s*0.7,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final media = widget.images[index];

              return GestureDetector(
                onTap: () {
                  if (media.isVideo &&
                      (media.url != null || media.file != null)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerScreen(media: media),
                      ),
                    );
                  }
                },
                child: buildMedia(media, containerHeight),
              );
            },
          ),
        ),

        if (widget.images.length > 1)
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: previousPage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
            ),
          ),

        if (widget.images.length > 1)
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: nextPage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              ),
            ),
          ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 10 : 6,
                  height: currentPage == index ? 10 : 6,
                  decoration: BoxDecoration(
                    color: currentPage == index ? Colors.white : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
  Widget buildMedia(AppImage media, double height) {
    Widget mediaWidget;
    final s= MediaQuery.of(context).size.width;

    if (media.url != null && media.url!.startsWith('http')) {
      print('msdia${media.url}');
      mediaWidget = Image.network(
        media.url!,
        width: s*0.14,
        height:kIsWeb== "Web"? s * 0.3:s*0.85,
        //s*0.02,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, size: height * 0.08),
        ),
      );
    }
    else if (media.file != null) {
      mediaWidget = Image.file(
        media.file!,
        width: double.infinity,
        height: kIsWeb== "Web"? s * 0.1:s*0.65,
        //s*0.015,
        fit: BoxFit.cover,
      );
    }
    else {
      mediaWidget = Container(
        color: Colors.grey[200],
        width: double.infinity,
        height:kIsWeb== "Web"? s * 0.1:s*0.65,
        //s*0.015,
        child: Icon(Icons.image, size: height * 0.012),
      );
    }

    if (media.isVideo) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: mediaWidget),
          Container(
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
          ),
        ],
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(10), child: mediaWidget);
  }}