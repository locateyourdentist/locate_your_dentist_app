import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/common_widgets/sale_share_utils.dart';
import 'package:locate_your_dentist/common_widgets/quill_message_utils.dart';
import 'package:locate_your_dentist/model/salePostModel.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../modules/product_services/service_controller.dart';


class SalePostDetailWebPage extends StatefulWidget {
  const SalePostDetailWebPage({super.key});

  @override
  State<SalePostDetailWebPage> createState() => _SalePostDetailWebPageState();
}

class _SalePostDetailWebPageState extends State<SalePostDetailWebPage> {
  final serviceController = Get.put(ServiceController());
  int _currentImageIndex = 0;
  bool _loading = true;
  bool _showSlowLoadHint = false;
  Timer? _slowLoadTimer;

  String? get _postId => Get.parameters['id'];

  SalePostModel? get _post {
    final id = _postId;
    if (id == null) return null;
    for (final post in serviceController.salesList) {
      if (post.id == id) return post;
    }
    return null;
  }
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _slowLoadTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _showSlowLoadHint = false;
    });
    // The backend sleeps after ~15 min idle (Render free tier) and can take
    // up to a minute to wake on the first request, which otherwise looks
    // like a frozen page. Surface a hint once it's taking a while.
    _slowLoadTimer?.cancel();
    _slowLoadTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _loading) setState(() => _showSlowLoadHint = true);
    });
    await serviceController.getSalesListAdmin('', '', context);
    _slowLoadTimer?.cancel();
    if (mounted) setState(() => _loading = false);
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
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    return GetBuilder<ServiceController>(
      builder: (controller) {
        final post = _post;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          appBar: buildAppBar(context),
          drawer: (isLoggedIn && !isDesktop)
              ? const Drawer(width: 250, child: AdminSideBar())
              : null,
          body: Row(
            children: [
              if (isDesktop && isLoggedIn) const AdminSideBar(),
              Expanded(
                child: _loading
                    ? _buildLoading(context)
                    : (post == null && serviceController.salesListError != null)
                        ? _buildLoadError(context)
                        : post == null
                        ? _buildNotFound(context)
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(isMobile ? 16 : 32),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 800),
                                child: _buildDetail(context, post),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (_showSlowLoadHint) ...[
            const SizedBox(height: 16),
            Text(
              "Waking up the server, this can take up to a minute…",
              style: AppTextStyles.caption(context, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text("Couldn't load this listing", style: AppTextStyles.caption(context, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text("Retry", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text("Listing not found", style: AppTextStyles.caption(context, color: Colors.grey)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.offNamed('/salePostListWebPage'),
            child: Text("Browse all listings", style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(BuildContext context, SalePostModel post) {
    final images = post.images ?? [];
    final plainMessage = quillMessageToPlainText(post.message);
    final message = plainMessage.isEmpty ? "No description provided" : plainMessage;
    final price = (post.price ?? '').isEmpty ? "N/A" : post.price!;
    final userType = post.userType ?? '';
    final mobileNumber = post.mobileNumber ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageArea(images, userType),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(userType, style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    if (post.createdDate != null)
                      Text(
                        DateFormat('dd MMM yyyy').format(post.createdDate!),
                        style: AppTextStyles.caption(context, color: Colors.grey.shade500),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text("₹$price", style: AppTextStyles.subtitle(context, color: AppColors.primary)),
                const SizedBox(height: 12),
                Text(message, style: AppTextStyles.body(context, color: AppColors.black)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton.icon(
                          onPressed: mobileNumber.isEmpty ? null : () => launchCall(mobileNumber),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: Text(
                            mobileNumber.isEmpty ? "No contact number" : "Call  $mobileNumber",
                            style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => shareSalePost(
                        message: message,
                        price: price,
                        mobileNumber: mobileNumber,
                        userType: userType,
                        imageUrl: images.isNotEmpty ? images.first : null,
                        postId: post.id,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                      label: Text("Share", style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)),
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

  Widget _buildImageArea(List<String> images, String userType) {
    if (images.isEmpty) {
      return Container(
        height: 320,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary])),
        child: Icon(_userTypeIcon(userType), color: Colors.white, size: 60),
      );
    }
    if (images.length == 1) {
      return Image.network(
        images.first,
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 320, width: double.infinity,
          color: const Color(0xFFF1F3F6),
          child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
        ),
      );
    }
    return Column(
      children: [
        CarouselSlider(
          items: images.map((url) {
            return Image.network(
              url,
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 320,
                color: const Color(0xFFF1F3F6),
                child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 320,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, reason) => setState(() => _currentImageIndex = index),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _currentImageIndex == entry.key ? 18 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _currentImageIndex == entry.key ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
