import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/product_services/sale_post_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/model/salePostModel.dart';
import 'package:locate_your_dentist/common_widgets/sale_share_utils.dart';
import 'package:locate_your_dentist/common_widgets/quill_message_utils.dart';
import '../../common_widgets/color_code.dart';

/// Hover/lift affordance used purely for a modern, tactile feel on
/// tappable cards; does not intercept taps.
class _HoverLift extends StatefulWidget {
  final Widget child;
  final double liftScale;
  final BorderRadius? borderRadius;
  const _HoverLift({required this.child, this.liftScale = 1.02, this.borderRadius});

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
        transform: Matrix4.identity()
          ..translate(0.0, _hovering ? -4.0 : 0.0)
          ..scale(_hovering ? widget.liftScale : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_hovering ? 0.18 : 0.0),
              blurRadius: _hovering ? 20 : 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}


class _SalePostRow {
  final String? id;
  final String message;
  final String price;
  final bool negotiable;
  final String userType;
  final String mobileNumber;
  final String postedAgo;
  final String imageAsset;
  final List<PickedSaleImage> pickedImages;
  final List<String> imageUrls;

  const _SalePostRow({
    this.id,
    required this.message,
    required this.price,
    required this.negotiable,
    required this.userType,
    required this.mobileNumber,
    required this.postedAgo,
    required this.imageAsset,
    this.pickedImages = const [],
    this.imageUrls = const [],
  });
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hr ago";
  return "${diff.inDays} day(s) ago";
}

_SalePostRow _rowFromApiModel(SalePostModel model) {
  final message = quillMessageToPlainText(model.message);
  final price = model.price ?? "";
  return _SalePostRow(
    id: model.id,
    message: message.isEmpty ? "No description provided" : message,
    price: price.isEmpty ? "N/A" : price,
    negotiable: false,
    userType: model.userType ?? "",
    mobileNumber: model.mobileNumber ?? "",
    postedAgo: _timeAgo(model.createdDate ?? DateTime.now()),
    imageAsset: "assets/images/tooth.png",
    imageUrls: model.images ?? [],
  );
}

void _openSaleImage(PickedSaleImage img) {
  Get.toNamed('/viewImagePage', arguments: {
    'bytes': img.bytes,
    'file': img.file,
    'url': null,
    'isVideo': false,
  });
}

void _openSaleImageUrl(String url) {
  Get.toNamed('/viewImagePage', arguments: {
    'bytes': null,
    'file': null,
    'url': url,
    'isVideo': false,
  });
}

class SalePostListPage extends StatefulWidget {
  const SalePostListPage({super.key});

  @override
  State<SalePostListPage> createState() => _SalePostListPageState();
}

class _SalePostListPageState extends State<SalePostListPage> {
  final searchController = TextEditingController();
  final serviceController = Get.put(ServiceController());
  String _query = "";

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await serviceController.getSalesListAdmin('', '', context);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<_SalePostRow> get _allPosts =>
      serviceController.salesList.map(_rowFromApiModel).toList();

  List<_SalePostRow> get _filtered {
    final all = _allPosts;
    if (_query.trim().isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where((p) =>
            p.message.toLowerCase().contains(q) ||
            p.userType.toLowerCase().contains(q))
        .toList();
  }

  Widget _userTypeIcon(String userType) {
    switch (userType) {
      case "Dental Clinic":
        return const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 26);
      case "Dental Shop":
        return const Icon(Icons.storefront_rounded, color: Colors.white, size: 26);
      case "Dental Lab":
        return const Icon(Icons.biotech_rounded, color: Colors.white, size: 26);
      case "Dental Mechanic":
        return const Icon(Icons.build_rounded, color: Colors.white, size: 26);
      default:
        return const Icon(Icons.support_agent_rounded, color: Colors.white, size: 26);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(
      builder: (controller) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final posts = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  _HoverLift(
                    liftScale: 1.08,
                    borderRadius: BorderRadius.circular(50),
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.18),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sale Listings",
                          style: TextStyle(fontSize: size * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${posts.length} item(s) for sale",
                          style: TextStyle(fontSize: size * 0.03, color: Colors.white.withOpacity(0.85)),
                        ),
                      ],
                    ),
                  ),
                  _HoverLift(
                    liftScale: 1.06,
                    borderRadius: BorderRadius.circular(14),
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/salePostPage'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// FLOATING SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (val) => setState(() => _query = val),
                        decoration: const InputDecoration(
                          hintText: "Search listings...",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text("No listings found", style: AppTextStyles.caption(context, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _HoverLift(
                            liftScale: 1.015,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 5)),
                                ],
                              ),
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
                                          post.userType,
                                          style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(post.postedAgo, style: AppTextStyles.caption(context, color: Colors.grey.shade500)),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => shareSalePost(
                                          message: post.message,
                                          price: post.price,
                                          mobileNumber: post.mobileNumber,
                                          userType: post.userType,
                                          imageUrl: post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
                                          postId: post.id,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(Icons.share_outlined, size: 16, color: AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption(context, color: AppColors.black, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 10),
                                  if (post.pickedImages.isNotEmpty)
                                    SizedBox(
                                      height: 96,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          for (final img in post.pickedImages)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: _HoverLift(
                                                liftScale: 1.03,
                                                borderRadius: BorderRadius.circular(12),
                                                child: GestureDetector(
                                                  onTap: () => _openSaleImage(img),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: img.bytes != null
                                                        ? Image.memory(img.bytes!, width: 96, height: 96, fit: BoxFit.cover)
                                                        : img.file != null
                                                            ? Image.file(img.file!, width: 96, height: 96, fit: BoxFit.cover)
                                                            : Container(
                                                                width: 96,
                                                                height: 96,
                                                                color: const Color(0xFFF1F3F6),
                                                                child: const Icon(Icons.image_outlined, color: Colors.grey),
                                                              ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  else if (post.imageUrls.isNotEmpty)
                                    SizedBox(
                                      height: 96,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          for (final url in post.imageUrls)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: _HoverLift(
                                                liftScale: 1.03,
                                                borderRadius: BorderRadius.circular(12),
                                                child: GestureDetector(
                                                  onTap: () => _openSaleImageUrl(url),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.network(
                                                      url,
                                                      width: 96,
                                                      height: 96,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context, child, progress) {
                                                        if (progress == null) return child;
                                                        return Container(
                                                          width: 96,
                                                          height: 96,
                                                          color: const Color(0xFFF1F3F6),
                                                          child: const Center(
                                                            child: SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        width: 96,
                                                        height: 96,
                                                        color: const Color(0xFFF1F3F6),
                                                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  else
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.asset(
                                        post.imageAsset,
                                        width: double.infinity,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: double.infinity,
                                          height: 96,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Center(child: _userTypeIcon(post.userType)),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "₹${post.price}",
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.body(context, color: AppColors.primary, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (post.negotiable) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text("Negotiable", style: AppTextStyles.caption(context, color: Colors.green, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                      const Spacer(),
                                      Icon(Icons.call, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          post.mobileNumber,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: AppTextStyles.caption(context, color: Colors.grey.shade600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
