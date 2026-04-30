import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:flutter_quill/flutter_quill.dart';

class PrivacyPolicyMobile extends StatefulWidget {
  const PrivacyPolicyMobile({super.key});

  @override
  State<PrivacyPolicyMobile> createState() => _PrivacyPolicyMobileState();
}

class _PrivacyPolicyMobileState extends State<PrivacyPolicyMobile> {

  final JobController jobController = Get.put(JobController());
  final PlanController planController = Get.put(PlanController());
  final TextEditingController nameController = TextEditingController();
  final _formKeyCreatePrivacyPolicy = GlobalKey<FormState>();
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
      _controller = QuillController(
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

      _controller = QuillController.basic();
      if (mounted) setState(() {});
    }
  }
  void initState() {
    super.initState();
    jobController.selectedTitle="Privacy Policy";
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
        ),

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
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
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

                  final data =
                  await serviceController.getPrivacyPolicyDetails(
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
  }  @override
  @override
  Widget build(BuildContext context) {
    double s=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Center(child: Text("Policies",style: AppTextStyles.subtitle(context,color: AppColors.black),)),
        backgroundColor: AppColors.white,
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKeyCreatePrivacyPolicy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  DropdownButtonFormField<String>(
                    value: jobController.selectedTitle,
                    decoration: InputDecoration(
                      labelText: "Select Policy Type",
                      labelStyle: AppTextStyles.caption(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: typesPolicy.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type,style:AppTextStyles.caption(context),),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      jobController.selectedTitle = value;
                      jobController.update();

                      final data = await serviceController
                          .getPrivacyPolicyDetails(value!, context);

                      loadDescription(data);
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    jobController.selectedTitle ?? "",
                    style: AppTextStyles.subtitle(context),
                  ),

                  const SizedBox(height: 20),

                  Container(
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
                    height: s*1.3,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: QuillEditor(
                      controller: _controller,
                      scrollController: _scrollController,
                      focusNode: _focusNode,
                      config: QuillEditorConfig(
                        placeholder:
                        "${jobController.selectedTitle ?? ""} description...",
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKeyCreatePrivacyPolicy.currentState!
                            .validate()) {

                          if (jobController.selectedTitle == null) {
                            await showSuccessDialog(
                              context,
                              title: "Error",
                              message: "Please Choose title",
                              onOkPressed: () => Get.back(),
                            );
                            return;
                          }

                          final doc = _controller.document;
                          final text = doc.toPlainText().trim();

                          if (text.isEmpty) {
                            await showSuccessDialog(
                              context,
                              title: "Error",
                              message: "Please add content",
                              onOkPressed: () => Get.back(),
                            );
                            return;
                          }

                          final description =
                          jsonEncode(doc.toDelta().toJson());

                          planController.addPrivacyPolicyContent(
                            jobController.selectedTitle!,
                            description,
                            context,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Save",
                        style: AppTextStyles.body(
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}