import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/color_code.dart';
import '../../common_widgets/common_textstyles.dart';
import '../common/common_side_bar.dart';

class _RevealIn extends StatelessWidget {
  final Widget child;
  const _RevealIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class PrivacyPolicyPagesWebView extends StatefulWidget {
  const PrivacyPolicyPagesWebView({super.key});

  @override
  State<PrivacyPolicyPagesWebView> createState() =>
      _PrivacyPolicyPagesWebViewState();
}

class _PrivacyPolicyPagesWebViewState
    extends State<PrivacyPolicyPagesWebView> {
  final ServiceController serviceController = Get.put(ServiceController());
  final GlobalKey<ScaffoldState> _scaffoldKeyLegal = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  late QuillController controller;
  final FocusNode _focusNode = FocusNode();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = QuillController.basic();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final data = await serviceController.getPrivacyPolicyUrl(context);

    controller.clear();
    loadDescription(data);
    if (mounted) setState(() => isLoading = false);
  }

  void loadDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      final bool isEmpty = data == null ||
          (data is String && data.trim().isEmpty) ||
          (data is List && data.isEmpty);

      if (isEmpty) {
        delta = [
          {"insert": "\n"},
        ];
      } else {
        dynamic decoded = data;

        if (data is String) {
          decoded = jsonDecode(data);
        }

        if (decoded is List && decoded.isNotEmpty) {
          delta = List<Map<String, dynamic>>.from(decoded);
        } else {
          delta = [
            {"insert": "\n"},
          ];
        }
      }

      _focusNode.unfocus();

      controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
        config: const QuillControllerConfig(
          clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
        ),
      );

      if (mounted) setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      controller = QuillController.basic();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool canGoBack = Navigator.of(context).canPop();

    PreferredSizeWidget buildAppBar() {
      if (isLoggedIn) {
        return CommonWebAppBar(
          height: width * 0.03,
          title: "LYD",
          onLogout: () {},
          onNotification: () {},
        );
      } else {
        return CommonHeader();
      }
    }

    return Scaffold(
      key: _scaffoldKeyLegal,
      appBar: buildAppBar(),
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: (isLoggedIn && !isDesktop)
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      body: Row(
        children: [
          if (isDesktop && isLoggedIn) const AdminSideBar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, isDesktop, isMobile, isLoggedIn, canGoBack),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 18 : 32,
                      vertical: isMobile ? 18 : 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 780),
                        child: isLoading
                            ? _buildLoadingState(context)
                            : _RevealIn(child: _buildContentCard(context, isMobile)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDesktop,
    bool isMobile,
    bool isLoggedIn,
    bool canGoBack,
  ) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 10,
        isMobile ? 20 : 22,
        isMobile ? 18 : 20,
        isMobile ? 20 : 10,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLoggedIn && !isDesktop)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _RoundIconButton(
                      icon: Icons.menu_rounded,
                      onTap: () => _scaffoldKeyLegal.currentState?.openDrawer(),
                    ),
                  )
                else if (canGoBack)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Get.back(),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.privacy_tip_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "LEGAL",
              style: AppTextStyles.caption(
                context,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ).copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 6),
            Text(
              "Privacy Policy",
              style: AppTextStyles.headline1(context, color: AppColors.white),
            ),
            const SizedBox(height: 10),
            Text(
              "How Locate Your Dentist collects, uses, and protects your information.",
              style: AppTextStyles.body(context, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 120),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Loading policy...",
              style: AppTextStyles.caption(context, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 28 : 40,
        horizontal: isMobile ? 18 : 44,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: KeyedSubtree(
          key: const ValueKey("Privacy Policy"),
          child: IgnorePointer(
            child: QuillEditor(
              controller: controller,
              scrollController: _scrollController,
              focusNode: focusNode,
              config: const QuillEditorConfig(
                showCursor: false,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
