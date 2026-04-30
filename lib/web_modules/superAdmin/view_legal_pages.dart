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


class LegalPagesWebView extends StatefulWidget {
  const LegalPagesWebView({super.key});

  @override
  State<LegalPagesWebView> createState() => _LegalPagesWebViewState();
}

class _LegalPagesWebViewState extends State<LegalPagesWebView> {
  final ServiceController serviceController = Get.put(ServiceController());

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
      selectedTitle!,
      context,
    );

    controller.clear();
    loadDescription(data);
  }
  void loadDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      if (data == null || data.toString().trim().isEmpty) {
        delta = [{"insert": "\n"}];
      } else {
        dynamic decoded = data;

        if (data is String) {
          decoded = jsonDecode(data);
        }

        if (decoded is List) {
          delta = List<Map<String, dynamic>>.from(decoded);
        } else {
          delta = [{"insert": "\n"}];
        }
      }

      _focusNode.unfocus();

      controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
        config: const QuillControllerConfig(
          clipboardConfig: QuillClipboardConfig(
            enableExternalRichPaste: true,
          ),
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
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
      appBar: buildAppBar(),
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          if( Api.userInfo.read('token')!=null)
            const AdminSideBar(),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:  EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration:  BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary,AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child:  Column(
                    children: [
                      Text(
                          selectedTitle,
                          style: AppTextStyles.subtitle(context,color: AppColors.white)
                      ),
                      const SizedBox(height: 15),
                      // Text(
                      //     "Connecting Dental Clinics, Labs, Shops, Mechanics & Professionals",
                      //     textAlign: TextAlign.center,
                      //     style: AppTextStyles.body(context,color: AppColors.white)
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                        )
                      ],
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(selectedTitle),
                      child: IgnorePointer(
                        child: QuillEditor(
                          controller: controller,
                          scrollController:
                          _scrollController,
                          focusNode: focusNode,
                          config:
                          const QuillEditorConfig(
                            showCursor: false,
                          ),
                        ),
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
}