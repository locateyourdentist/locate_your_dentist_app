import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/modules/product_services/sale_post_controller.dart';
import 'package:locate_your_dentist/model/salePostModel.dart';
import 'package:locate_your_dentist/common_widgets/sale_share_utils.dart';
import 'package:locate_your_dentist/common_widgets/quill_message_utils.dart';
import '../../common_widgets/color_code.dart';
import '../../modules/product_services/service_controller.dart';


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
          ..translate(0.0, _hovering ? -5.0 : 0.0)
          ..scale(_hovering ? widget.liftScale : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_hovering ? 0.18 : 0.0),
              blurRadius: _hovering ? 22 : 0,
              offset: const Offset(0, 12),
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

// _SalePostRow _rowFromItem(SalePostItem item) {
//   return _SalePostRow(
//     message: item.message.isEmpty ? "No description provided" : item.message,
//     price: item.price.isEmpty ? "N/A" : item.price,
//     negotiable: item.negotiable,
//     userType: item.userType,
//     mobileNumber: item.mobileNumber,
//     postedAgo: _timeAgo(item.postedAt),
//     imageAsset: "assets/images/tooth.png",
//     pickedImages: item.images,
//   );
// }
//
//
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

class SalePostListWebPage extends StatefulWidget {
  const SalePostListWebPage({super.key});

  @override
  State<SalePostListWebPage> createState() => _SalePostListWebPageState();
}

class _SalePostListWebPageState extends State<SalePostListWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKeySaleList = GlobalKey<ScaffoldState>();
  final searchController = TextEditingController();
  final salePostController = Get.put(SalePostController());
  String _query = "";
  final serviceController = Get.put(ServiceController());
  final PlanController planController = Get.put(PlanController());

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<_SalePostRow> get _allPosts => [
        ...serviceController.salesList.map(_rowFromApiModel),
      // ...salePostController.posts.map(_rowFromItem),
        //..._samplePosts,
      ];

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

  IconData _userTypeIcon(String userType) {
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
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
    await serviceController.getSalesListAdmin( "","",context);
  }
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    return GetBuilder<ServiceController>(
      builder: (controller) {
        final posts = _filtered;
        return _buildScaffold(context, posts, isDesktop, isMobile, isLoggedIn);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    List<_SalePostRow> posts,
    bool isDesktop,
    bool isMobile,
    bool isLoggedIn,
  ) {
    return Scaffold(
      key: _scaffoldKeySaleList,
      backgroundColor: const Color(0xFFF6F8FC),
      drawer: (isLoggedIn && !isDesktop)
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      appBar: buildAppBar(context),
      body: Row(
        children: [
          if (isDesktop && isLoggedIn) const AdminSideBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoggedIn && !isDesktop)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: AppColors.black),
                            onPressed: () => _scaffoldKeySaleList.currentState?.openDrawer(),
                          ),
                        ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: isDesktop ? 32 : 24, horizontal: isDesktop ? 32 : 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                              child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Sale Listings", style: AppTextStyles.subtitle(context, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text("${posts.length} item(s) for sale", style: AppTextStyles.caption(context, color: Colors.white.withOpacity(0.85))),
                                ],
                              ),
                            ),
                            _HoverLift(
                              liftScale: 1.04,
                              borderRadius: BorderRadius.circular(14),
                              child: ElevatedButton.icon(
                                onPressed: () => Api.userInfo.read('token')==null?Get.toNamed('/registerPageWeb'):Get.toNamed('/salePostWebPage'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.add, color: AppColors.primary),
                                label: Text("Post Sale Instruments", style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SEARCH BAR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
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
                                  hintText: "Search listings by keyword or user type...",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (posts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text("No listings found", style: AppTextStyles.caption(context, color: Colors.grey)),
                              ],
                            ),
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio: crossAxisCount == 2 ? 2.6 : 3.4,
                              ),
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                return _HoverLift(
                                  liftScale: 1.015,
                                  borderRadius: BorderRadius.circular(18),
                                  child: Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: post.id == null
                                          ? null
                                          : () => Get.toNamed('/salePostDetailWebPage/${post.id}'),
                                      child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: Colors.grey.shade100),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6)),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        post.pickedImages.isNotEmpty
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  for (final img in post.pickedImages)
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 6),
                                                      child: _HoverLift(
                                                        liftScale: 1.06,
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: GestureDetector(
                                                          onTap: () => _openSaleImage(img),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(12),
                                                            child: img.bytes != null
                                                                ? Image.memory(img.bytes!, width: 152, height: 152, fit: BoxFit.cover)
                                                                : img.file != null
                                                                    ? Image.file(img.file!, width: 152, height: 152, fit: BoxFit.cover)
                                                                    : Container(
                                                                        width: 52,
                                                                        height: 52,
                                                                        color: const Color(0xFFF1F3F6),
                                                                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                                                                      ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              )
                                            : post.imageUrls.isNotEmpty
                                                ? Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      for (final url in post.imageUrls)
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 6),
                                                          child: _HoverLift(
                                                            liftScale: 1.06,
                                                            borderRadius: BorderRadius.circular(12),
                                                            child: GestureDetector(
                                                              onTap: () => _openSaleImageUrl(url),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(12),
                                                                child: Image.network(
                                                                  url,
                                                                  width: 152,
                                                                  height: 152,
                                                                  fit: BoxFit.cover,
                                                                  loadingBuilder: (context, child, progress) {
                                                                    if (progress == null) return child;
                                                                    return Container(
                                                                      width: 52,
                                                                      height: 52,
                                                                      color: const Color(0xFFF1F3F6),
                                                                      child: const Center(
                                                                        child: SizedBox(
                                                                          width: 18,
                                                                          height: 18,
                                                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                                    width: 52,
                                                                    height: 52,
                                                                    color: const Color(0xFFF1F3F6),
                                                                    child: const Icon(Icons.image_outlined, color: Colors.grey),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  )
                                                : ClipRRect(
                                                    borderRadius: BorderRadius.circular(14),
                                                    child: Image.asset(
                                                      post.imageAsset,
                                                      width: 150,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        width: 150,
                                                        height: 150,
                                                        decoration: BoxDecoration(
                                                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                                                          borderRadius: BorderRadius.circular(14),
                                                        ),
                                                        child: Icon(_userTypeIcon(post.userType), color: Colors.white, size: 28),
                                                      ),
                                                    ),
                                                  ),
                                        const SizedBox(width: 10),
                                        Expanded(
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
                                                    child: Text(post.userType, style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600)),
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
                                              Row(
                                                children: [
                                                  Text("₹${post.price}", style: AppTextStyles.body(context, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                                  if (post.negotiable) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                                      child: Text("Negotiable", style: AppTextStyles.caption(context, color: Colors.green, fontWeight: FontWeight.w600)),
                                                    ),
                                                  ],
                                                  const Spacer(),
                                                  Icon(Icons.call, size: 14, color: Colors.grey.shade500),
                                                  const SizedBox(width: 4),
                                                  Text(post.mobileNumber, style: AppTextStyles.caption(context, color: Colors.grey.shade600)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ]),)
                                    )));
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 30),
                    ],
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
