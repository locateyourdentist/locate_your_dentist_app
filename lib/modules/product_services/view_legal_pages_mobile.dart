import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';

import '../../common_widgets/color_code.dart';

class LegalPagesMobileView extends StatefulWidget {
  const LegalPagesMobileView({super.key});

  @override
  State<LegalPagesMobileView> createState() => _LegalPagesMobileViewState();
}

class _LegalPagesMobileViewState extends State<LegalPagesMobileView> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(selectedTitle??"",style: AppTextStyles.subtitle(context,color: AppColors.white),),
        iconTheme: const IconThemeData(color: AppColors.white), flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary,AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
        
            // Padding(
            //   padding: const EdgeInsets.all(12),
            //   child: DropdownButtonFormField<String>(
            //     value: selectedTitle,
            //     decoration: InputDecoration(
            //       labelText: "Select Page",
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     items: titles.map((item) {
            //       return DropdownMenuItem(
            //         value: item,
            //         child: Text(item),
            //       );
            //     }).toList(),
            //     onChanged: (value) async {
            //       if (value == null) return;
            //
            //       setState(() {
            //         selectedTitle = value;
            //         isLoading = true;
            //       });
            //
            //       final data = await serviceController
            //           .getPrivacyPolicyDetails(value, context);
            //
            //       loadDescription(data);
            //
            //       setState(() {
            //         isLoading = false;
            //       });
            //     },
            //   ),
            // ),
        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
        

            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                    scrollController: _scrollController,
                    focusNode: focusNode,
                    config: const QuillEditorConfig(
                      showCursor: false,
                      padding: EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CommonBottomNavigation(currentIndex: 0),
    );
  }
}