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

/// Fades + slides a child in once on build, for a gentle section reveal.
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
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class LegalPagesWebView extends StatefulWidget {
  const LegalPagesWebView({super.key});

  @override
  State<LegalPagesWebView> createState() => _LegalPagesWebViewState();
}

class _LegalPagesWebViewState extends State<LegalPagesWebView> {
  final ServiceController serviceController = Get.put(ServiceController());
  final GlobalKey<ScaffoldState> _scaffoldKeyLegal = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final List<String> titles = const [
    "Privacy Policy",
    "Terms & Conditions",
    "Cookie Policy",
    "Refund Policy",
    "Disclaimer",
  ];

  late String selectedTitle;
  late QuillController controller;
  final FocusNode _focusNode = FocusNode();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedTitle = Api.userInfo.read('legalPage') ?? "Privacy Policy";
    controller = QuillController.basic();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final data = await serviceController.getPrivacyPolicyDetails(
      selectedTitle,
      context,
    );

    controller.clear();
    loadDescription(data);
  }

  void loadDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      if (data == null || data.toString().trim().isEmpty) {
        delta = [
          {"insert": "\n"},
        ];
      } else {
        dynamic decoded = data;

        if (data is String) {
          decoded = jsonDecode(data);
        }

        if (decoded is List) {
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
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  IconData _iconForTitle(String title) {
    switch (title) {
      case "Privacy Policy":
        return Icons.privacy_tip_outlined;
      case "Terms & Conditions":
        return Icons.gavel_rounded;
      case "Cookie Policy":
        return Icons.cookie_outlined;
      case "Refund Policy":
        return Icons.currency_rupee_rounded;
      case "Disclaimer":
        return Icons.info_outline_rounded;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    final bool isDesktop = width >= 1100;
    PreferredSizeWidget buildAppBar() {
      if (Api.userInfo.read('token') != null) {
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
      backgroundColor: const Color(0xFFF6F8FC),
      drawer: (isLoggedIn && !isDesktop)
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      body: Row(
        children: [
          if (isDesktop && isLoggedIn) const AdminSideBar(),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isDesktop ? 48 : 36,
                    horizontal: isDesktop ? 60 : 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((isLoggedIn && !isDesktop))
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: AppColors.white,
                            ),
                            onPressed: () =>
                                _scaffoldKeyLegal.currentState?.openDrawer(),
                          ),
                        ),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconForTitle(selectedTitle),
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              "Legal & Policies",
                              style: AppTextStyles.caption(
                                context,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              selectedTitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.subtitle(
                                context,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        Center(
                          child: _RevealIn(
                            child: Container(
                            constraints: const BoxConstraints(maxWidth: 1100),
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 44 : 26,
                              horizontal: isDesktop ? 50 : 22,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: KeyedSubtree(
                                key: ValueKey(selectedTitle),
                                child: IgnorePointer(
                                  child: QuillEditor(
                                    controller: controller,
                                    scrollController: _scrollController,
                                    focusNode: focusNode,
                                    config: const QuillEditorConfig(
                                      showCursor: false,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                      //  if (!isLoggedIn) const CommonFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    //  bottomNavigationBar: !isLoggedIn ?SizedBox(height:isDesktop?320:150,child: const CommonFooter()):SizedBox(),
    );
  }
}
