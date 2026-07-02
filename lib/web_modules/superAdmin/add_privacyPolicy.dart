import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:flutter_quill/flutter_quill.dart';

class PrivacyPolicyWeb extends StatefulWidget {
  const PrivacyPolicyWeb({super.key});

  @override
  State<PrivacyPolicyWeb> createState() => _PrivacyPolicyWebState();
}

class _PrivacyPolicyWebState extends State<PrivacyPolicyWeb> {
  final JobController jobController = Get.put(JobController());
  final PlanController planController = Get.put(PlanController());
  final TextEditingController nameController = TextEditingController();
  final ServiceController serviceController = Get.put(ServiceController());

  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool isTitleSidebarOpen = false;
  String? tempSelectedTitle;
  final List<String> typesPolicy = const [
    "Privacy Policy",
    "Refund Policy",
    "Terms & Conditions",
    "Return Policy",
    "Cookie Policy",
    "Disclaimer",
  ];

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
      _controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
        config: const QuillControllerConfig(
          clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      print("Quill load error: $e");
      _controller = QuillController.basic();
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    jobController.selectedTitle = "Privacy Policy";
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
      ),
    );
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final data = await serviceController.getPrivacyPolicyDetails(
      jobController.selectedTitle!,
      context,
    );
    _controller.clear();
    loadDescription(data);
  }

  Widget buildTitleSidebar() {
    double s = MediaQuery.of(context).size.width;
    return Container(
      width: s * 0.14,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: GetBuilder<JobController>(
        builder: (controller) {
          return ListView.builder(
            itemCount: typesPolicy.length,
            itemBuilder: (context, index) {
              final type = typesPolicy[index];

              return RadioListTile<String>(
                value: type,
                groupValue: jobController.selectedTitle,
                activeColor: AppColors.primary,
                title: Text(type),

                onChanged: (value) async {
                  jobController.selectedTitle = value;
                  jobController.update();

                  final data = await serviceController.getPrivacyPolicyDetails(
                    value!,
                    context,
                  );

                  loadDescription(data);
                },
              );
            },
          );
        },
      ),
    );
  }

  void showPolicyPopup() {
    Get.dialog(
      AlertDialog(
        title: const Text("Select Policy"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: typesPolicy.length,
            itemBuilder: (context, index) {
              final type = typesPolicy[index];

              return RadioListTile<String>(
                value: type,
                groupValue: jobController.selectedTitle,
                activeColor: AppColors.primary,
                title: Text(type),
                onChanged: (value) async {
                  Get.back();

                  jobController.selectedTitle = value;
                  jobController.update();

                  final data = await serviceController.getPrivacyPolicyDetails(
                    value!,
                    context,
                  );

                  loadDescription(data);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildTitleSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return isMobile
        ? ElevatedButton.icon(
            onPressed: showPolicyPopup,
            icon: const Icon(Icons.list),
            label: Text(jobController.selectedTitle ?? "Select Policy"),
          )
        : buildTitleSidebar();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 768;
    final bool isDesktop = width >= 1100;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonWebAppBar(
        height: 60,
        title: "LYD",
        onLogout: () {},
        onNotification: () {},
      ),
      drawer: (isLoggedIn && !isDesktop)
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      body: GetBuilder<JobController>(
        builder: (_) {
          return Row(
            children: [
              if (isDesktop && isLoggedIn) const AdminSideBar(),

              if (!isMobile) buildTitleSidebar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isMobile)
                              DropdownButtonFormField<String>(
                                initialValue: jobController.selectedTitle,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: typesPolicy
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: AppTextStyles.caption(context),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) async {
                                  jobController.selectedTitle = value;
                                  jobController.update();
                                  final data = await serviceController
                                      .getPrivacyPolicyDetails(value!, context);
                                  loadDescription(data);
                                },
                              ),

                            if (isMobile) const SizedBox(height: 20),

                            Text(
                              jobController.selectedTitle ?? "",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),
                            if (!isMobile)
                              Container(
                                height: width * 0.4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: QuillSimpleToolbar(
                                  controller: _controller,
                                  config: const QuillSimpleToolbarConfig(
                                    embedButtons: [],
                                    showBackgroundColorButton: false,
                                  ),
                                ),
                              ),

                            Container(
                              height: isMobile ? 350 : 500,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: QuillEditor(
                                controller: _controller,
                                scrollController: _scrollController,
                                focusNode: _focusNode,
                                config: QuillEditorConfig(
                                  padding: const EdgeInsets.all(16),
                                  placeholder:
                                      "${jobController.selectedTitle} description...",
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            Center(
                              child: SizedBox(
                                width: 150,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final text = _controller.document
                                        .toPlainText()
                                        .trim();

                                    if (text.isEmpty) {
                                      Get.snackbar(
                                        "Error",
                                        "Please add content",
                                      );
                                      return;
                                    }

                                    final description = jsonEncode(
                                      _controller.document.toDelta().toJson(),
                                    );

                                    await planController
                                        .addPrivacyPolicyContent(
                                          jobController.selectedTitle!,
                                          description,
                                          context,
                                        );
                                  },
                                  child: const Text(
                                    "Save Policy",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
