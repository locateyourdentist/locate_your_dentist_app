import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
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
  Widget build(BuildContext context) {
    double s=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonWebAppBar(
        height: s * 0.03,
        title: "LYD",
        onLogout: () {
        },
        onNotification: () {
        },
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return Row(
            children: [
              const AdminSideBar(),
              buildTitleSidebar(),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formKeyCreatePrivacyPolicy,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
          "${jobController.selectedTitle??""}",
                                  style: AppTextStyles.subtitle(
                                    context,
                                  ),
                                ),

                                const SizedBox(height: 25),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isTitleSidebarOpen ? 1 : 0,
                                  child: IgnorePointer(
                                    ignoring: !isTitleSidebarOpen,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isTitleSidebarOpen = false;
                                        });
                                      },
                                      child: Container(
                                        color: Colors.black.withOpacity(0.4),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),),
                                      height: s*0.05,
                                      width: double.infinity,
                                      child: QuillSimpleToolbar(
                                        controller: _controller,
                                        config: QuillSimpleToolbarConfig(
                                          embedButtons: [],
                                          showBackgroundColorButton: false,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: s*0.25,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),),
                                      child: QuillEditor(
                                        controller: _controller,
                                        scrollController: _scrollController,
                                        focusNode: _focusNode,
                                        config: QuillEditorConfig(
                                          placeholder: "${jobController.selectedTitle??""}  description...",
                                          padding: const EdgeInsets.all(16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Center(
                                  child: Container(
                                    width: s*0.15,
                                    height: s*0.018,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKeyCreatePrivacyPolicy.currentState!.validate()) {
                                          if(jobController.selectedTitle==null){
                                            await showSuccessDialog(context, title:"Error",message :"Please Choose title",
                                                onOkPressed: () {Get.back();});                                            return;
                                          }
                                          final doc = _controller.document;
                                          final text = doc.toPlainText().trim();

                                          if (text.isEmpty) {
                                            await showSuccessDialog(context, title:"Error",message :"Please add content",
                                                onOkPressed: () {Get.back();});
                                            return;
                                          }

                                          final description = jsonEncode(doc.toDelta().toJson());
                                        //  final description = jsonEncode(_controller.document.toDelta().toJson());

                                          planController.addPrivacyPolicyContent(jobController.selectedTitle!,description,context);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          backgroundColor: Colors.transparent,shadowColor: Colors.transparent
                                      ),
                                      child: Text(
                                        "Add",
                                        style: AppTextStyles.body(context, color: AppColors.white,fontWeight: FontWeight.bold),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}