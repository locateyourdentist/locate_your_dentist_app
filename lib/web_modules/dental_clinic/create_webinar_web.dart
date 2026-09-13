import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/color_code.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CreateWebinarWebPage extends StatefulWidget {
  const CreateWebinarWebPage({super.key});

  @override
  State<CreateWebinarWebPage> createState() => _CreateWebinarWebPageState();
}

class _CreateWebinarWebPageState extends State<CreateWebinarWebPage> {
  final loginController = Get.put(LoginController());
  final jobController = Get.put(JobController());
  final _formKeyCreateWebinarWeb = GlobalKey<FormState>();
  final planController = Get.put(PlanController());
  String? startTime;
  String? endTime;
  final ImagePicker _picker = ImagePicker();
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String? job;

  void loadWebinarDescription(dynamic data) {
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

          if (delta.isEmpty) {
            delta = [
              {"insert": "\n"},
            ];
          }
        } else {
          delta = [
            {"insert": "\n"},
          ];
        }
      }

      _controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );

      setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      _controller = QuillController.basic();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    jobController.getJobCategoryLists("", context);
    if (args != null && args['job'] != null) {
      job = args['job'];
    } else {
      job = "";
    }
    loginController.getProfileByUserId(
      Api.userInfo.read('userId') ?? "",
      context,
    );
    jobController.selectedWebinarId.toString().isNotEmpty
        ? jobController.selectedWebinarId.toString()
        : "0";
    jobController.checkJobPlanStatus(
      Api.userInfo.read('userId') ?? "",
      context,
    );
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadWebinarDescription(jobController.webDescriptionData);
    });
  }

  Future<List<Uint8List>> convertImages(List<AppImage2> images) async {
    List<Uint8List> result = [];

    for (var img in images) {
      if (kIsWeb) {
        if (img.bytes != null) {
          result.add(img.bytes!);
        }
      } else {
        if (img.file != null) {
          final bytes = await img.file!.readAsBytes();
          result.add(bytes);
        }
      }
    }
    return result;
  }

  Future<void> pickSingleWebinarImage1() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    loginController.webinarImages.clear();

    if (kIsWeb) {
      loginController.webinarImages.add(
        AppImage2(bytes: await image.readAsBytes()),
      );
    } else {
      loginController.webinarImages.add(AppImage2(file: File(image.path)));
    }

    loginController.update();
  }

  Widget _buildSingleImageWidget({required AppImage2 image}) {
    double s = MediaQuery.of(context).size.width;
    return Container(
      width: s * 0.15,
      height: s * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(image),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () async {
                loginController.webinarImages.clear();
                loginController.update();
                if (image.url != null && image.url!.isNotEmpty) {
                  loginController.deleteAwsFile(image.url!, '', context);
                }
              },
              child: const Icon(Icons.cancel, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(AppImage2 image) {
    double s = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      if (image.bytes != null) {
        return Image.memory(
          image.bytes!,
          fit: BoxFit.cover,
          width: s * 0.15,
          height: s * 0.15,
        );
      } else if (image.url != null && image.url!.isNotEmpty) {
        return Image.network(
          image.url!,
          fit: BoxFit.cover,
          width: s * 0.15,
          height: s * 0.15,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              Icons.broken_image,
              size: s * 0.012,
              color: AppColors.grey,
            ),
          ),
        );
      }
    } else {
      if (image.file != null) {
        return Image.file(
          image.file!,
          fit: BoxFit.cover,
          width: s * 0.15,
          height: s * 0.15,
        );
      } else if (image.url != null && image.url!.isNotEmpty) {
        return Image.network(
          image.url!,
          fit: BoxFit.cover,
          width: s * 0.15,
          height: s * 0.15,
          errorBuilder: (_, __, ___) => Center(
            child: Icon(
              Icons.broken_image,
              size: s * 0.012,
              color: AppColors.grey,
            ),
          ),
        );
      }
    }

    return Center(
      child: Icon(
        Icons.image_not_supported,
        color: Colors.red,
        size: s * 0.012,
      ),
    );
  }

  void saveDocument() {
    final jsonData = jsonEncode(_controller.document.toDelta().toJson());
    debugPrint("Saved JSON: $jsonData");
  }

  bool isWithinOneDay(String createdDate) {
    DateTime created = DateTime.parse(createdDate);
    DateTime now = DateTime.now().toUtc();

    Duration difference = now.difference(created);

    return difference.inHours <= 48;
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    final bool isDesktop = size >= 1100;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LYD",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return Row(
            children: [
              if (isDesktop && isLoggedIn) const AdminSideBar(),

              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Form(
                              key: _formKeyCreateWebinarWeb,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: size * 0.03),

                                    Text(
                                      jobController.selectedWebinarId
                                              .toString()
                                              .isNotEmpty
                                          ? "Edit Webinar"
                                          : 'Post New Webinar',
                                      style: AppTextStyles.subtitle(
                                        context,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    SizedBox(height: size * 0.01),
                                    Text(
                                      'Webinar Title',
                                      style: AppTextStyles.caption(
                                        context,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: size * 0.005),

                                    CustomTextField(
                                      hint: "",
                                      icon: Icons.title,
                                      controller: loginController
                                          .webinarTitleJobController,
                                    ),
                                    SizedBox(height: size * 0.005),
                                    Text(
                                      'Webinar description',
                                      style: AppTextStyles.caption(
                                        context,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: size * 0.005),

                                    Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                          ),
                                          height: size > 600
                                              ? size * 0.07
                                              : size * 0.12,
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
                                          height: size * 0.3,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    10,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                          ),
                                          child: QuillEditor(
                                            controller: _controller,
                                            scrollController:
                                                _scrollController,
                                            focusNode: _focusNode,
                                            config: QuillEditorConfig(
                                              placeholder:
                                                  "Webinar description...",
                                              padding: const EdgeInsets.all(
                                                16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size * 0.005),
                                    Text(
                                      'Webinar Date',
                                      style: AppTextStyles.caption(
                                        context,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: size * 0.005),

                                    CustomTextField(
                                      hint: "",
                                      controller: loginController
                                          .webinarDateController,
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2050),
                                            );

                                        if (pickedDate != null) {
                                          loginController
                                                  .webinarDateController
                                                  .text =
                                              "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                        }
                                      },
                                    ),
                                    SizedBox(height: size * 0.005),
                                    Text(
                                      'Webinar Link',
                                      style: AppTextStyles.caption(
                                        context,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: size * 0.005),

                                    CustomTextField(
                                      hint: "",
                                      icon: Icons.person,
                                      maxLines: 2,
                                      controller: loginController
                                          .webinarLinkController,
                                    ),
                                    SizedBox(height: size * 0.01),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Webinar Timing',
                                        style: AppTextStyles.caption(
                                          context,
                                          color: AppColors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size * 0.005),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Start Time',
                                        style: AppTextStyles.caption(
                                          context,
                                          color: AppColors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size * 0.005),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CustomDropdownField(
                                            hint: "Start Hour",
                                            items: const [
                                              "1",
                                              "2",
                                              "3",
                                              "4",
                                              "5",
                                              "6",
                                              "7",
                                              "8",
                                              "9",
                                              "10",
                                              "11",
                                              "12",
                                            ],
                                            selectedValue:
                                                ([
                                                  "1",
                                                  "2",
                                                  "3",
                                                  "4",
                                                  "5",
                                                  "6",
                                                  "7",
                                                  "8",
                                                  "9",
                                                  "10",
                                                  "11",
                                                  "12",
                                                ].contains(
                                                  loginController.startHour,
                                                ))
                                                ? loginController.startHour
                                                : null,
                                            onChanged: (value) {
                                              setState(() {
                                                loginController.startHour =
                                                    value;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: size * 0.01),
                                        Expanded(
                                          child: CustomDropdownField(
                                            hint: "Start Minutes",
                                            items: const [
                                              "00",
                                              "05",
                                              "10",
                                              "15",
                                              "20",
                                              "25",
                                              "30",
                                              "35",
                                              "40",
                                              "45",
                                              "50",
                                              "55",
                                            ],
                                            selectedValue:
                                                ([
                                                  "00",
                                                  "05",
                                                  "10",
                                                  "15",
                                                  "20",
                                                  "25",
                                                  "30",
                                                  "35",
                                                  "40",
                                                  "45",
                                                  "50",
                                                  "55",
                                                ].contains(
                                                  loginController
                                                      .startMinutes,
                                                ))
                                                ? loginController.startMinutes
                                                : null,
                                            onChanged: (value) {
                                              setState(() {
                                                loginController.startMinutes =
                                                    value;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: size * 0.01),
                                        Expanded(
                                          child: CustomDropdownField(
                                            hint: "AM/PM",
                                            items: const ["am", "pm"],
                                            selectedValue:
                                                (["am", "pm"].contains(
                                                  loginController.startPeriod,
                                                ))
                                                ? loginController.startPeriod
                                                : null,
                                            onChanged: (value) {
                                              setState(() {
                                                loginController.startPeriod =
                                                    value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size * 0.005),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'End Time',
                                        style: AppTextStyles.caption(
                                          context,
                                          color: AppColors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size * 0.005),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CustomDropdownField(
                                            hint: "End Hour",
                                            items: const [
                                              "1",
                                              "2",
                                              "3",
                                              "4",
                                              "5",
                                              "6",
                                              "7",
                                              "8",
                                              "9",
                                              "10",
                                              "11",
                                              "12",
                                            ],
                                            selectedValue:
                                                ([
                                                  "1",
                                                  "2",
                                                  "3",
                                                  "4",
                                                  "5",
                                                  "6",
                                                  "7",
                                                  "8",
                                                  "9",
                                                  "10",
                                                  "11",
                                                  "12",
                                                ].contains(
                                                  loginController.endHour,
                                                ))
                                                ? loginController.endHour
                                                : null,
                                            onChanged: (value) {
                                              setState(() {
                                                loginController.endHour =
                                                    value;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: size * 0.01),
                                        Expanded(
                                          child: CustomDropdownField(
                                            hint: "End Minutes",
                                            items: const [
                                              "00",
                                              "05",
                                              "10",
                                              "15",
                                              "20",
                                              "25",
                                              "30",
                                              "35",
                                              "40",
                                              "45",
                                              "50",
                                              "55",
                                            ],
                                            selectedValue:
                                                ([
                                                  "00",
                                                  "05",
                                                  "10",
                                                  "15",
                                                  "20",
                                                  "25",
                                                  "30",
                                                  "35",
                                                  "40",
                                                  "45",
                                                  "50",
                                                  "55",
                                                ].contains(
                                                  loginController.endMinutes,
                                                ))
                                                ? loginController.endMinutes
                                                : null,
                                            onChanged: (value) {
                                              setState(() {
                                                loginController.endMinutes =
                                                    value;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: size * 0.01),
                                        Expanded(
                                          child: CustomDropdownField(
                                            hint: "AM/PM",
                                            items: const ["am", "pm"],
                                            selectedValue:
                                                (["am", "pm"].contains(
                                                  loginController.endPeriod,
                                                ))
                                                ? loginController.endPeriod
                                                : null,
                                            onChanged: (value) {
                                              setState(() {
                                                loginController.endPeriod =
                                                    value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size * 0.005),
                                    Text(
                                      'Image',
                                      style: AppTextStyles.caption(
                                        context,
                                        color: AppColors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: size * 0.005),

                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GetBuilder<LoginController>(
                                            builder: (controller) {
                                              return SizedBox(
                                                height: size * 0.13,
                                                width: size * 0.3,
                                                child:
                                                    controller
                                                        .webinarImages
                                                        .isNotEmpty
                                                    ? _buildSingleImageWidget(
                                                        image: controller
                                                            .webinarImages
                                                            .first,
                                                      )
                                                    : GestureDetector(
                                                        onTap:
                                                            pickSingleWebinarImage1,
                                                        child: Container(
                                                          alignment: Alignment
                                                              .center,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                          child: Icon(
                                                            Icons.add,
                                                            color: AppColors
                                                                .grey,
                                                            size: 22,
                                                          ),
                                                        ),
                                                      ),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: size * 0.03),

                                    Center(
                                      child: Container(
                                        width: size * 0.25,
                                        height: size * 0.018,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.secondary,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (_formKeyCreateWebinarWeb
                                                .currentState!
                                                .validate()) {
                                              saveDocument();
                                              if ((loginController.startHour !=
                                                          null &&
                                                      loginController
                                                          .startHour!
                                                          .isNotEmpty) &&
                                                  (loginController
                                                              .startMinutes !=
                                                          null &&
                                                      loginController
                                                          .startMinutes!
                                                          .isNotEmpty) &&
                                                  (loginController
                                                              .startPeriod !=
                                                          null &&
                                                      loginController
                                                          .startPeriod!
                                                          .isNotEmpty)) {
                                                startTime =
                                                    "${loginController.startHour}:${loginController.startMinutes} ${loginController.startPeriod}";
                                              } else {
                                                startTime = null;
                                                showCustomToast(
                                                  context,
                                                  "Please Choose Start Time",
                                                );
                                                return;
                                              }
                                              if ((loginController.endHour !=
                                                          null &&
                                                      loginController
                                                          .endHour!
                                                          .isNotEmpty) &&
                                                  (loginController
                                                              .endMinutes !=
                                                          null &&
                                                      loginController
                                                          .endMinutes!
                                                          .isNotEmpty) &&
                                                  (loginController
                                                              .endPeriod !=
                                                          null &&
                                                      loginController
                                                          .endPeriod!
                                                          .isNotEmpty)) {
                                                endTime =
                                                    "${loginController.endHour}:${loginController.endMinutes} ${loginController.endPeriod}";
                                              } else {
                                                endTime = null;
                                                showCustomToast(
                                                  context,
                                                  "Please Choose End Time",
                                                );
                                                return;
                                              }
                                              final webinarBytes =
                                                  await convertImages(
                                                    loginController
                                                            .webinarImages ??
                                                        [],
                                                  );

                                              final webinarDescription =
                                                  jsonEncode(
                                                    _controller.document
                                                        .toDelta()
                                                        .toJson(),
                                                  );
                                              bool isSameDay = false;
                                              if (jobController
                                                  .webinar
                                                  .isNotEmpty) {
                                                isSameDay = isWithinOneDay(
                                                  jobController
                                                          .webinar
                                                          .first
                                                          .createdDate
                                                          .toString() ??
                                                      "",
                                                );
                                              }
                                              if (isSameDay ||
                                                  jobController
                                                          .selectedWebinarId ==
                                                      "0") {
                                                await jobController
                                                    .postWebinarAdmin(
                                                      jobController
                                                          .selectedWebinarId
                                                          .toString(),
                                                      loginController
                                                          .selectUserId!,
                                                      loginController
                                                          .selectedUserType!,
                                                      loginController
                                                          .typeNameController
                                                          .text
                                                          .toString(),
                                                      loginController
                                                          .webinarTitleJobController
                                                          .text
                                                          .toString(),
                                                      webinarDescription,
                                                      loginController
                                                          .webinarLinkController
                                                          .text
                                                          .toString(),
                                                      loginController
                                                          .webinarDateController
                                                          .text
                                                          .toString(),
                                                      startTime.toString(),
                                                      endTime.toString(),
                                                      webinarBytes,
                                                      context,
                                                    );
                                              } else {
                                                showSuccessDialog(
                                                  context,
                                                  title: "Alert",
                                                  message:
                                                      "Oops! Editing is allowed only for one day after you purchase a plan.",
                                                  onOkPressed: () {},
                                                );
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            backgroundColor:
                                                Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Text(
                                            job == 'new'
                                                ? "Create Webinar"
                                                : "Edit Webinar",
                                            style: AppTextStyles.body(
                                              context,
                                              color: AppColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
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
