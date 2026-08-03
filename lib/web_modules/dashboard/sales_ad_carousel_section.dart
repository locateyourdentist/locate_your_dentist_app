import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/quill_message_utils.dart';
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
class _HoverLift extends StatefulWidget {
  final Widget child;
  const _HoverLift({required this.child});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _hovering ? -6.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: _hovering ? 0.18 : 0.07,
              ),
              blurRadius: _hovering ? 24 : 14,
              offset: Offset(0, _hovering ? 14 : 6),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
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
      color: const Color(0xFFF6F8FC),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.sell_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sale Ads",
                            style: AppTextStyles.subtitle(
                              context,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            "Instruments & equipment listed by the community",
                            style: AppTextStyles.caption(
                              context,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Get.toNamed('/salePostListWebPage'),
                      icon: Text(
                        "View All",
                        style: AppTextStyles.caption(
                          context,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      label: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 340,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 18),
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

  void _openPost() {
    Get.toNamed('/salePostDetailWebPage/${widget.post.id}');
  }

  Widget _buildImageArea() {
    final images = widget.post.images ?? [];

    if (images.isEmpty) {
      return GestureDetector(
        onTap: _openPost,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Icon(
            _saleAdUserTypeIcon(widget.post.userType ?? ''),
            color: Colors.white,
            size: 42,
          ),
        ),
      );
    }

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: GestureDetector(
          onTap: _openPost,
          child: Image.network(
            images.first,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFF1F3F6),
              child: const Icon(
                Icons.image_outlined,
                color: Colors.grey,
                size: 32,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: GestureDetector(
            onTap: _openPost,
            child: CarouselSlider(
              items: images.map((url) {
                return Image.network(
                  url,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: const Color(0xFFF1F3F6),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 160,
                viewportFraction: 1,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, reason) =>
                    setState(() => _currentIndex = index),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _currentIndex == entry.key ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _currentIndex == entry.key
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final plainMessage = quillMessageToPlainText(post.message);
    final message = plainMessage.isEmpty
        ? "No description provided"
        : plainMessage;
    final price = (post.price ?? '').isEmpty ? "N/A" : post.price!;
    final userType = post.userType ?? '';

    return _HoverLift(
      child: GestureDetector(
        onTap: _openPost,
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            userType,
                            style: AppTextStyles.caption(
                              context,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _saleAdTimeAgo(post.createdDate),
                          style: AppTextStyles.caption(
                            context,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                        context,
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          "₹$price",
                          style: AppTextStyles.body(
                            context,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.call_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            post.mobileNumber ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(
                              context,
                              color: Colors.grey.shade600,
                            ),
                          ),
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
    );
  }
}
