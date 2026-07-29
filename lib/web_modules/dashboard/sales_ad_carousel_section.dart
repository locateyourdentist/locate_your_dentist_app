import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/salePostModel.dart';

String _saleAdTimeAgo(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hr ago";
  return "${diff.inDays} day(s) ago";
}

IconData _saleAdUserTypeIcon(String userType) {
  switch (userType) {
    case "Dental Clinic":
      return Icons.local_hospital_rounded;
    case "Dental Shop":
      return Icons.storefront_rounded;
    case "Dental Lab":
      return Icons.biotech_rounded;
    case "Dental Mechanic":
      return Icons.build_rounded;
    default:
      return Icons.support_agent_rounded;
  }
}

/// "Sale Ads" promo section for the landing dashboard: a horizontally
/// scrollable row of sale-post cards. Each card shows its own images as a
/// single carousel slider when more than one image is present (falls back
/// to a static image / placeholder otherwise), with all the post's details
/// rendered below the image.
class SalesAdCarouselSection extends StatelessWidget {
  final List<SalePostModel> posts;

  const SalesAdCarouselSection({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      decoration: BoxDecoration(
        color: AppColors.white,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Sale Ads",
                      style: AppTextStyles.subtitle(context, color: AppColors.primary),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/salePostListWebPage'),
                      child: Text(
                        "View All",
                        style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 360,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _SaleAdCard(post: posts[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaleAdCard extends StatefulWidget {
  final SalePostModel post;

  const _SaleAdCard({required this.post});

  @override
  State<_SaleAdCard> createState() => _SaleAdCardState();
}

class _SaleAdCardState extends State<_SaleAdCard> {
  int _currentIndex = 0;

  void _openImage(String url) {
    Get.toNamed('/viewImagePage', arguments: {'url': url});
  }

  Widget _buildImageArea() {
    final images = widget.post.images ?? [];

    if (images.isEmpty) {
      return Container(
        height: 170,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Icon(_saleAdUserTypeIcon(widget.post.userType ?? ''), color: Colors.white, size: 40),
      );
    }

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: GestureDetector(
          onTap: () => _openImage(images.first),
          child: Image.network(
            images.first,
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 170,            width: double.infinity,
              color: const Color(0xFFF1F3F6),
              child: const Icon(Icons.image_outlined, color: Colors.grey, size: 32),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: CarouselSlider(
            items: images.map((url) {
              return GestureDetector(
                onTap: () => _openImage(url),
                child: Image.network(
                  url,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 170,
                    color: const Color(0xFFF1F3F6),
                    child: const Icon(Icons.image_outlined, color: Colors.grey, size: 32),
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 170,
              viewportFraction: 1,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (index, reason) => setState(() => _currentIndex = index),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _currentIndex == entry.key ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _currentIndex == entry.key ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final message = (post.message ?? '').isEmpty ? "No description provided" : post.message!;
    final price = (post.price ?? '').isEmpty ? "N/A" : post.price!;
    final userType = post.userType ?? '';

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageArea(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userType,
                        style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _saleAdTimeAgo(post.createdDate),
                      style: AppTextStyles.caption(context, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "₹$price",
                      style: AppTextStyles.body(context, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Icon(Icons.call, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        post.mobileNumber ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(context, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
