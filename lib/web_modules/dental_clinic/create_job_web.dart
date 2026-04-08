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
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CreateJobPostWeb extends StatefulWidget {
  const CreateJobPostWeb({super.key});

  @override
  State<CreateJobPostWeb> createState() => _CreateJobPostWebState();
}
class _CreateJobPostWebState extends State<CreateJobPostWeb> {
  final loginController=Get.put(LoginController());
  final jobController=Get.put(JobController());
  final _formKeyCreateJobWeb = GlobalKey<FormState>();
  final _formKeyCreateWebinarWeb = GlobalKey<FormState>();
  final planController=Get.put(PlanController());
  String selectedString="Job";
  String? startTime;
  String? endTime;
  String? jobStartTime;
  String? jobEndTime;
  final ImagePicker _picker = ImagePicker();
  File? selectedImageFile;
  File? selectedJobImageFile;
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String? jobId;
  String? job;
  // void loadJobDescription(String text) {
  //   final doc = Document()..insert(0, text);
  //   _controller = QuillController(
  //     document: doc,
  //     selection: const TextSelection.collapsed(offset: 0),
  //   );
  //
  //   setState(() {});
  // }
  void loadJobDescription(String data) {
    try {
      dynamic decoded = jsonDecode(data);

      // 🔥 If still string → decode again
      if (decoded is String) {
        decoded = jsonDecode(decoded);
      }

      // ✅ Ensure it's a List
      if (decoded is List) {
        _controller = QuillController(
          document: Document.fromJson(decoded),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        throw Exception("Invalid format");
      }
    } catch (e) {
      print("Quill parse error: $e");
      final doc = Document()..insert(0, data);

      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    jobController.getJobCategoryLists("",context);
    if (args != null && args['selectedString'] != null) {
      selectedString = args['selectedString'];
    }
    final userId=Api.userInfo.read('userId')??"";
    if (args != null && args['job'] != null) {
      job = args['job'];
    } else {
      job = "";
    }
    loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    jobController.selectedJobId.toString().isNotEmpty? jobController.selectedJobId.toString():"0";
    print('jobid${jobController.selectedJobId}webid${jobController.selectedWebinarId.toString()}');
    jobController.selectedWebinarId.toString().isNotEmpty? jobController.selectedWebinarId.toString():"0";
    jobController.checkJobPlanStatus(userId, context);
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          // onImagePaste: (Uint8List imageBytes) async {
          //   //final imageUrl = await uploadImageToServer(imageBytes);
          //   return imageUrl;
          // },
        ),
      ),
    );
    //loginController.jobDescController.text = _controller.document.toPlainText();
   // final jobDescriptionPlain = _controller.document.toPlainText();
    print('jobb desc${loginController.jobDescController.text}');
    loadJobDescription(loginController.jobDescController.text);
    loadJobDescription(loginController.webinarDescriptionJobController.text);
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
  Future<void> pickSingleJobImage1() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    loginController.jobFileImages.clear();

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      loginController.jobImages.add(AppImage2(bytes: bytes));
    } else {
      loginController.jobFileImages.add(AppImage2(file: File(image.path)));
    }

    loginController.update();
  }
  Future<void> pickSingleWebinarImage1() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    loginController.webinarFileImages.clear();

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      loginController.webinarImages.add(AppImage2(bytes: bytes));
    } else {
      loginController.webinarFileImages.add(AppImage2(file: File(image.path)));
    }

    loginController.update();
  }
  // Future<void> pickImage() async {
  //   final XFile? pickedFile = await _picker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 80,
  //   );
  //
  //   if (pickedFile != null) {
  //     selectedImageFile = File(pickedFile.path);
  //     jobController.webinarImage=null;
  //   }
  // }
  // Future<void> pickImageFromCamera() async {
  //   final XFile? pickedFile = await _picker.pickImage(
  //     source: ImageSource.camera,
  //     imageQuality: 80,
  //   );
  //
  //   if (pickedFile != null) {
  //     selectedImageFile = File(pickedFile.path);
  //   }
  // }
  // Future<void> pickSingleImage() async {
  //   final XFile? pickedImage = await _picker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 80,
  //   );
  //   if (pickedImage != null) {
  //     final selectedImageFile = File(pickedImage.path);
  //
  //     loginController.webinarImages.clear();
  //     loginController.webinarImages.add(selectedImageFile);
  //
  //     loginController.webinarFileImages.clear();
  //     loginController.update();
  //   }
  // }
  // Widget _buildSingleImageWidget({File? file, String? url}) {
  //   return Stack(
  //     children: [
  //       ClipRRect(
  //         borderRadius: BorderRadius.circular(10),
  //         child: _buildImage(file, url),
  //         // file != null
  //         //     ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
  //         //     : Image.network(url!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
  //       ),
  //       Positioned(
  //         right: 0,
  //         top: 0,
  //         child: GestureDetector(
  //           onTap: () async{
  //             loginController.webinarImages.clear();
  //             loginController.webinarFileImages.clear();
  //             loginController.update();
  //             await loginController.deleteAwsFile(url.toString(),'user', context);
  //           },
  //           child: const Icon(Icons.cancel, color: Colors.black,),
  //         ),
  //       ),
  //       Positioned(
  //         right: 10,
  //         bottom: 10,
  //         child: GestureDetector(
  //           onTap: () => pickSingleImage(),
  //           child: Container(
  //             padding: const EdgeInsets.all(4),
  //             decoration: BoxDecoration(
  //               color: Colors.black54,
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: const Icon(Icons.edit, color: Colors.white),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  // Future<void> pickSingleImage1() async {
  //   final XFile? pickedImage = await _picker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 80,
  //   );
  //
  //   if (pickedImage != null) {
  //     final selectedImageFile = File(pickedImage.path);
  //     loginController.jobImages.clear();
  //     loginController.jobImages.add(selectedImageFile);
  //     loginController.jobFileImages.clear();
  //     loginController.update();
  //   }
  // }
  //
  // Widget _buildSingleImageWidget1({File? file, String? url}) {
  //   return Stack(
  //     children: [
  //       ClipRRect(
  //         borderRadius: BorderRadius.circular(10),
  //         child:  _buildImage(file, url),
  //                ),
  //       Positioned(
  //         right: 0,
  //         top: 0,
  //         child: GestureDetector(
  //           onTap: ()async {
  //             loginController.jobImages.clear();
  //             loginController.jobFileImages.clear();
  //             loginController.update();
  //             await loginController.deleteAwsFile(url.toString(),'user', context);
  //           },
  //           child: const Icon(Icons.cancel, color: Colors.black,),
  //         ),
  //       ),
  //       Positioned(
  //         right: 10,
  //         bottom: 10,
  //         child: GestureDetector(
  //           onTap: () => pickSingleImage(),
  //           child: Container(
  //             padding: const EdgeInsets.all(4),
  //             decoration: BoxDecoration(
  //               color: Colors.black54,
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: const Icon(Icons.edit, color: Colors.white),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  // Widget _buildImage(File? file, String? url) {
  //   if (file != null) {
  //     return Image.file(
  //       file,
  //       fit: BoxFit.cover,
  //       width: double.infinity,
  //       height: double.infinity,
  //     );
  //   }
  //
  //   if (url != null && url.isNotEmpty && url != "null") {
  //     return Image.network(
  //       url,
  //       fit: BoxFit.cover,
  //       width: double.infinity,
  //       height: double.infinity,
  //       errorBuilder: (context, error, stackTrace) {
  //         return _errorWidget();
  //       },
  //       loadingBuilder: (context, child, progress) {
  //         if (progress == null) return child;
  //         return const Center(child: CircularProgressIndicator());
  //       },
  //     );
  //   }
  //
  //   return _errorWidget();
  // }
  // Widget _errorWidget() {
  //   return Container(
  //     width: double.infinity,
  //     height: double.infinity,
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF1F3F6),
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Icon(
  //       Icons.image_outlined,
  //       color: Colors.grey.shade400,
  //       size: 40,
  //     ),
  //   );
  // }
  Widget _buildSingleImageWidget({required AppImage2 image}) {
    return Container(
      height: 120,
      width: 200,
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
              onTap: () {
                loginController.jobFileImages.clear();
                loginController.update();
              },
              child: const Icon(Icons.cancel, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }  Widget _buildImage(AppImage2 image) {
    if (kIsWeb) {
      if (image.bytes != null) {
        return Image.memory(
          image.bytes!,
          fit: BoxFit.cover,
        );
      } else if (image.url != null && image.url!.isNotEmpty) {
        return Image.network(
          image.url!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
        );
      }
    } else {
      if (image.file != null) {
        return Image.file(
          image.file!,
          fit: BoxFit.cover,
        );
      } else if (image.url != null && image.url!.isNotEmpty) {
        return Image.network(
          image.url!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
        );
      }
    }

    return const Center(
      child: Icon(Icons.image_not_supported, color: Colors.red),
    );
  }
  void saveDocument() {
    final jsonData =
    jsonEncode(_controller.document.toDelta().toJson());

    debugPrint("Saved JSON: $jsonData");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Document Saved")),
    );
  }
  void loadDocument() {
    const sample = [
      {"insert": "Hello \n"},
      {"insert": "This is rich text editor\n", "attributes": {"bold": true}}
    ];

    _controller.document = Document.fromJson(sample);
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.08,
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

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Container(
                          width: double.infinity,
                          //color: Colors.grey[100],
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Column(
                                children: [
                                  SizedBox(height: size*0.02,),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Radio(
                                        value: "Job",
                                        groupValue: selectedString,
                                        activeColor: AppColors.primary,
                                        fillColor: MaterialStateProperty.all(AppColors.primary),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedString = value.toString();
                                          });
                                        },
                                      ),
                                      Text("Create Job",style: AppTextStyles.caption(context,color: AppColors.black),),

                                      Radio(
                                        value: "Webinar",
                                        groupValue: selectedString,
                                        activeColor: AppColors.black,
                                        fillColor: MaterialStateProperty.all(AppColors.primary),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedString = value.toString();
                                          });
                                        },
                                      ),
                                      Text("Create Webinar",style: AppTextStyles.caption(context,color: AppColors.black),),
                                    ],
                                  ),
                                  if(selectedString=="Job")
                                    Form(
                                      key: _formKeyCreateJobWeb,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: size*0.01,),
                                          Text(jobController.selectedJobId.toString().isNotEmpty? "Edit New Job":  'Post New Job',style: AppTextStyles.subtitle(context,color: AppColors.black),),
                                          SizedBox(height: size*0.01,),
                                          Text('Job Title',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                                          CustomTextField(
                                            hint: "Job Title",
                                            icon: Icons.title,
                                            controller: loginController.jobTitleController,
                                            // fillColor: AppColors.white,
                                            // borderColor: AppColors.grey,
                                          ),
                                          SizedBox(height: size*0.01,),
                                          // CustomTextField(
                                          //   hint: "Job Description",
                                          //   icon: Icons.text_fields,
                                          //   controller: loginController.jobDescController,
                                          //   // fillColor: AppColors.white,
                                          //   // borderColor: AppColors.grey,
                                          //   maxLines: 7,
                                          // ),
                                          // QuillSimpleToolbar(
                                          //   controller: _controller,
                                          //   config: QuillSimpleToolbarConfig(
                                          //     embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   height: MediaQuery.of(context).size.height * 0.2,
                                          //   child: Row(
                                          //     children: [
                                          //       IconButton(
                                          //         icon: const Icon(Icons.save),
                                          //         onPressed: saveDocument,
                                          //       ),
                                          //       IconButton(
                                          //         icon: const Icon(Icons.download),
                                          //         onPressed: loadDocument,
                                          //       ),
                                          //       Expanded(
                                          //         child: QuillEditor(
                                          //           controller: _controller,
                                          //           scrollController: _scrollController,
                                          //           focusNode: _focusNode,
                                          //           config: QuillEditorConfig(
                                          //             placeholder: "Enter job description...",
                                          //             padding: const EdgeInsets.all(16),
                                          //             embedBuilders: FlutterQuillEmbeds.editorBuilders(
                                          //               imageEmbedConfig: QuillEditorImageEmbedConfig(
                                          //                 imageProviderBuilder: (context, imageUrl) {
                                          //                   return NetworkImage(imageUrl);
                                          //                 },
                                          //               ),
                                          //             ),
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
            Column(
            children: [
            SizedBox(
              height: size*0.05,
              child: QuillSimpleToolbar(
              controller: _controller,
              config: QuillSimpleToolbarConfig(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              ),
              ),
            ),

            Row(
            children: [
            IconButton(
            icon:  Icon(Icons.save,color: AppColors.grey,size: size*0.012,),
            onPressed: saveDocument,
            ),
            IconButton(
            icon:  Icon(Icons.download,color: AppColors.grey,size: size*0.012,),
            onPressed: loadDocument,
            ),
            ],
            ),

            SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: QuillEditor(
            controller: _controller,
            scrollController: _scrollController,
            focusNode: _focusNode,
            config: QuillEditorConfig(
            placeholder: "Enter job description...",
            padding: const EdgeInsets.all(16),
            ),
            ),
            ),
            ],
            ),
                                          SizedBox(height: size * 0.01),
                                          Text('Qualification',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                                          CustomTextField(
                                            hint: "Qualification",
                                            icon: Icons.text_fields,
                                            controller: loginController.qualificationJobController,
                                            // fillColor: AppColors.white,
                                            // borderColor: AppColors.grey,
                                            //maxLines: 7,
                                          ),
                                          SizedBox(height: size*0.01,),
                                          Text('Job Type',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),

                                          buildPopupField(
                                            label: "Select Job Type",
                                            value: loginController.selectedJobType,
                                            onTap: () async {
                                              final value = await showSelectionDialog(
                                                context: context,
                                                title: "Select Job Type",
                                                options: ["Full Time", "Part Time", "Remote"],
                                                selectedValue: loginController.selectedJobType,
                                              );
                                              if (value != null) setState(() => loginController.selectedJobType = value);
                                            },
                                          ),
                                          SizedBox(height: size * 0.01),
                                          Text('Select Job Categories',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),

                                          GetBuilder<JobController>(
                                            builder: (jobController) {
                                              final List<String> categoryOptions = jobController.jobCategoryAdmin
                                                  .map((e) => e.name.trim())
                                                  .toList();

                                              return buildPopupField(
                                                label: "Select Job Categories",
                                                value: loginController.selectedCategories.isEmpty
                                                    ? null
                                                    : loginController.selectedCategories.join(", "),
                                                onTap: () async {
                                                  final selected = await showMultiSelectDialog(
                                                    context: context,
                                                    title: "Select Job Categories",
                                                    options: categoryOptions,
                                                    selectedValues: loginController.selectedCategories,
                                                  );
                                                  if (selected != null) {
                                                    setState(() {
                                                      loginController.selectedCategories = selected;
                                                    });
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                          SizedBox(height: size * 0.01),
                                          buildTimeRow(
                                            label: "Start Time",
                                            hour: jobController.startHour,
                                            minutes: jobController.startMinutes,
                                            period: jobController.startPeriod,
                                            onTapHour: () async {
                                              final value = await showSelectionDialog(
                                                context: context,
                                                title: "Start Hour",
                                                options: List.generate(12, (i) => "${i + 1}"),
                                                selectedValue: jobController.startHour,
                                              );
                                              if (value != null) setState(() => jobController.startHour = value);
                                            },
                                            onTapMinutes: () async {
                                              final value = await showSelectionDialog(
                                                context: context,
                                                title: "Start Minutes",
                                                options: List.generate(12, (i) => "${i * 5}".padLeft(2, '0')),
                                                selectedValue: jobController.startMinutes,
                                              );
                                              if (value != null) setState(() => jobController.startMinutes = value);
                                            },
                                            onTapPeriod: () async {
                                              final value = await showSelectionDialog(
                                                context: context,
                                                title: "AM/PM",
                                                options: ["AM", "PM"],
                                                selectedValue: jobController.startPeriod,
                                              );
                                              if (value != null) setState(() => jobController.startPeriod = value);
                                            },
                                          ),
                                          const SizedBox(height: 16),

                                          // End Time
                                          buildTimeRow(
                                            label: "End Time",
                                            hour: jobController.endHour,
                                            minutes: jobController.endMinutes,
                                            period: jobController.endPeriod,
                                            onTapHour: () async {
                                              final value = await showSelectionDialog(
                                                context: context,
                                                title: "End Hour",
                                                options: List.generate(12, (i) => "${i + 1}"),
                                                selectedValue: jobController.endHour,
                                              );
                                              if (value != null) setState(() => jobController.endHour = value);
                                            },
                                            onTapMinutes: () async {
                                              final value = await showSelectionDialog(
                                                context: context,
                                                title: "End Minutes",
                                                options: List.generate(12, (i) => "${i * 5}".padLeft(2, '0')),
                                                selectedValue: jobController.endMinutes,
                                              );
                                              if (value != null) setState(() => jobController.endMinutes = value);
                                            },
                                            onTapPeriod: () async {
                                              final value = await showSelectionDialog(
                                                context: context,
                                                title: "AM/PM",
                                                options: ["AM", "PM"],
                                                selectedValue: jobController.endPeriod,
                                              );
                                              if (value != null) setState(() => jobController.endPeriod = value);
                                            },
                                          ),
                                          SizedBox(height: size * 0.01),
                                          Text('Select Salary',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),

                                          buildPopupField(
                                            label: "Select Salary",
                                            value: loginController.selectedSalary,
                                            onTap: () async {
                                              final value = await showSelectionDialog(
                                                context: context,
                                                title: "Select Salary",
                                                options: [
                                                  "8,000 - 10,000",
                                                  "10,000 - 15,000",
                                                  "15,000 - 20,000",
                                                  "20,000 - 25,000",
                                                  "25,000 - 30,000",
                                                  "30,000 - 35,000",
                                                  "35,000 - 40,000",
                                                  "40,000 - 45,000",
                                                  "45,000 - 50,000",
                                                  "50,000 - 60,000",
                                                  "60,000 - 60,000",
                                                  "70,000 - 80,000",
                                                  "Above 1,00,000",
                                                  "Negotiable"
                                                ],
                                                selectedValue: loginController.selectedSalary,
                                              );
                                              if (value != null) setState(() => loginController.selectedSalary = value);
                                            },
                                          ),

                                          SizedBox(height: size * 0.01),
                                          Text('Select Experience',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),

                                          buildPopupField(
                                            label: "Select Experience",
                                            value: loginController.selectedExperience,
                                            onTap: () async {
                                              final value = await showSelectionDialog(
                                                context: context,
                                                title: "Select Experience",
                                                options: [
                                                  "Fresher",
                                                  "1 Year",
                                                  "2 Years",
                                                  "3 Years",
                                                  "4 Years",
                                                  "5 Years",
                                                  "5 - 8 Years",
                                                  "8 - 10 Years",
                                                  "Above 10 Years"
                                                ],
                                                selectedValue: loginController.selectedExperience,
                                              );
                                              if (value != null) setState(() => loginController.selectedExperience = value);
                                            },
                                          ),
                                          SizedBox(height: size * 0.01),
                                          Column(
                                            mainAxisAlignment:  MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text('Image',style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                                              SizedBox(height: size * 0.005),
                                              SizedBox(
                                                height: size * 0.1,width: size*0.12,
                                                child: GetBuilder<LoginController>(
                                                  builder: (controller) {
                                                    if (controller.jobImages.isNotEmpty) {
                                                      final file = controller.jobImages.first;
                                                      return _buildSingleImageWidget(image: file);
                                                    }
                                                    if (controller.jobFileImages.isNotEmpty) {
                                                      final img = controller.jobFileImages.first;
                                                      print('web img url${img.url}');
                                                      return _buildSingleImageWidget(image: img);
                                                    }
                                                    return GestureDetector(
                                                      onTap: () => pickSingleJobImage1(),
                                                      child: Center(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(color: Colors.grey),
                                                            color: Colors.grey.shade200,
                                                          ),
                                                          child: const Center(
                                                            child: Icon(Icons.add, size: 40, color: Colors.grey),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              // GetBuilder<LoginController>(
                                              //   builder: (controller) {
                                              //     return SizedBox(
                                              //       height: 200,
                                              //       child: controller.jobFileImages.isNotEmpty
                                              //           ? _buildSingleImageWidget(image: controller.jobFileImages.first)
                                              //           : GestureDetector(
                                              //         onTap: pickSingleJobImage1,
                                              //         child: Container(
                                              //           height:120,
                                              //           //s * 0.13,
                                              //           width:200,
                                              //           //s * 0.13,
                                              //           alignment: Alignment.center,
                                              //           decoration: BoxDecoration(
                                              //             border: Border.all(color: Colors.grey),
                                              //             borderRadius: BorderRadius.circular(10),
                                              //           ),
                                              //           child: Center(
                                              //             child: Icon(Icons.add, color: AppColors.grey, size: size * 0.012),
                                              //           ),
                                              //         ),
                                              //       ),
                                              //     );
                                              //   },
                                              // ),
                                              const SizedBox(height: 20),

                                              // Row(
                                              //   mainAxisAlignment: MainAxisAlignment.center,
                                              //   children: [
                                              //     ElevatedButton.icon(
                                              //       onPressed: () async {
                                              //         await pickImage1();
                                              //         setState(() {});
                                              //       },
                                              //       icon:  Icon(Icons.photo,color: AppColors.primary,size: size*0.06,),
                                              //       label:  Text("Pick Image",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.primary),),
                                              //     ),
                                              //
                                              //     const SizedBox(width: 15),
                                              //
                                              //   ],
                                              // ),
                                            ],
                                          ),
                                          SizedBox(height: size * 0.02),

                                          Center(
                                            child:  Container(
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
                                                  if (_formKeyCreateJobWeb.currentState!.validate()) {
                                                    saveDocument();
                                                    print("selectedJobType= ${loginController.selectedJobType}");
                                                    print("jobTitleController = ${loginController.jobTitleController.text}");
                                                    print("jobDescController = ${loginController.jobDescController.text}");
                                                    print("selectedSalary = ${loginController.selectedSalary}");
                                                    print("STATE = ${loginController.stateController.text}");
                                                    print("DISTRICT = ${loginController.districtController.text}");
                                                    print("CITY = ${loginController.cityController.text}");
                                                    print("qualificationJobController = ${loginController.qualificationJobController.text}");
                                                    print("selectedExperience = ${loginController.selectedExperience.toString()}");
                                                    print("name = ${loginController.typeNameController.text.toString()}");
                                                    print("CERTIFICATES = ${loginController.certificates}");
                                                    print('jobcategory${loginController.selectedCategories}');
                                                    if ((jobController.startHour != null && jobController.startHour!.isNotEmpty) &&
                                                        (jobController.startMinutes != null && jobController.startMinutes!.isNotEmpty) &&
                                                        (jobController.startPeriod != null && jobController.startPeriod!.isNotEmpty)) {
                                                      jobStartTime="${jobController.startHour}:${jobController.startMinutes} ${jobController.startPeriod}";
                                                    } else {
                                                      startTime = null;
                                                      showCustomToast(context, "Please Choose Start Time",);
                                                      return;

                                                    }
                                                    if ((jobController.endHour != null && jobController.endHour!.isNotEmpty) &&
                                                        (jobController.endMinutes != null && jobController.endMinutes!.isNotEmpty) &&
                                                        (jobController.endPeriod != null && jobController.endPeriod!.isNotEmpty)) {
                                                      jobEndTime="${jobController.endHour}:${jobController.endMinutes} ${jobController.endPeriod}";
                                                    } else {
                                                      endTime = null;
                                                      showCustomToast(context,  "Please Choose End Time",);
                                                      return;
                                                    }
                                                    if(loginController.selectedJobType==null){
                                                      showCustomToast(context,  "Please Choose Job Type",);
                                                      return;
                                                    }
                                                    if (loginController.selectedCategories == null ||
                                                        loginController.selectedCategories!.isEmpty) {
                                                      showCustomToast(context,  "Please Choose Job category",);
                                                      return;
                                                    }

                                                    if(loginController.selectedSalary==null){
                                                      showCustomToast(context,  "Please Choose salary",);
                                                      return;
                                                    }
                                                    if(loginController.selectedExperience==null){
                                                      showCustomToast(context,  "Please Choose experience",);
                                                      return;
                                                    }
                                                    final jobImageBytes = await convertImages(loginController.jobImages ?? []);

                                                    //final jobDescriptionJson = jsonEncode(_controller.document.toDelta().toJson());
                                                    final jobDescriptionPlain = _controller.document.toPlainText();
                                                    final jobDescription =
                                                    jsonEncode(_controller.document.toDelta().toJson());
                                                   // if ((jobController.jobCount ?? 0) > 0) {
                                                      await jobController.postJobsAdmin(
                                                         jobController.selectedJobId.toString()??"0",
                                                          //jobController.selectedJobId.toString().isNotEmpty? jobController.selectedJobId.toString():"0",
                                                          loginController.selectUserId!,
                                                          loginController.selectedUserType!,
                                                          loginController.selectedJobType.toString(),
                                                          loginController.selectedCategories,
                                                          loginController.typeNameController.text.toString(),
                                                          loginController.jobTitleController.text.toString(),
                                                          jobDescription,
                                                          //jobDescriptionPlain,
                                                         // jobDescriptionJson,
                                                          // loginController.jobDescController.text
                                                          //     .toString(),
                                                          loginController.selectedSalary.toString(),
                                                          loginController.qualificationJobController.text.toString(),
                                                          loginController.selectedExperience.toString(),
                                                          Api.userInfo.read('state').toString()??"",
                                                         // loginController.stateController.text.toString(),
                                                          Api.userInfo.read('district').toString()??"",
                                                         // loginController.districtController.text.toString(),
                                                          Api.userInfo.read('city').toString()??"",
                                                          //loginController.cityController.text.toString(),
                                                          jobStartTime.toString(),
                                                          jobEndTime.toString(),jobImageBytes,
                                                          //loginController.jobImages.isNotEmpty?loginController.jobImages:[],
                                                          context
                                                      );
                                                      await jobController.getJobListAdmin(context);
                                                 //   }
                                                 //   else{
                                                 //      showCustomToast(context,  "Please buy new plan");
                                                 //      showSuccessDialog(context, title:"Alert",message :"Oops! Your plan has expired. Please purchase a new plan to continue posting jobs.",
                                                 //          onOkPressed: () {
                                                 //            kIsWeb?Get.toNamed('/viewPlanPageWeb'): Get.toNamed('/viewPlanPage');
                                                 //          });
                                                 //    //  planController.checkPlanList.isNotEmpty? showPlanAlerts(planController.checkPlanList??[],context):"";
                                                 //
                                                 //    }
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    backgroundColor: Colors.transparent,shadowColor: Colors.transparent
                                                ),
                                                child: Text(
                                                  job=='new'? "Create Job":  'Edit Job',
                                                  style: AppTextStyles.body(context, color: AppColors.white,fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 30,)

                                        ],

                                      ),
                                    ),

                                  if(selectedString=="Webinar")
                                    Form(
                                      key: _formKeyCreateWebinarWeb,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20.0,right: 20),
                                        child: Column(
                                          children: [
                                            SizedBox(height: size*0.03,),

                                            Text(jobController.selectedWebinarId.toString().isNotEmpty? "Edit Webinar":  'Post New Webinar',style: AppTextStyles.subtitle(context,color: AppColors.black),),
                                            SizedBox(height: size*0.01,),
                                            CustomTextField(
                                              hint: "Webinar Title",
                                              icon: Icons.title,
                                              controller: loginController.webinarTitleJobController,
                                              // fillColor: AppColors.white,
                                              // borderColor: AppColors.grey,
                                            ),
                                            SizedBox(height: size*0.01,),
                                            // CustomTextField(
                                            //   hint: "Webinar Description",
                                            //   icon: Icons.text_fields,
                                            //   controller: loginController.webinarDescriptionJobController,
                                            //   // fillColor: AppColors.white,
                                            //   // borderColor: AppColors.grey,
                                            //   maxLines: 4,
                                            // ),
                                            // SizedBox(height: size * 0.01),

                                            Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey.shade100,
                                                      borderRadius: BorderRadius.circular(10)),
                                                  height: size*0.05,
                                                  child: QuillSimpleToolbar(
                                                    controller: _controller,
                                                    config: QuillSimpleToolbarConfig(
                                                      embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                                                    ),
                                                  ),
                                                ),

                                                // Row(
                                                //   children: [
                                                //     IconButton(
                                                //       icon:  Icon(Icons.save,color: AppColors.grey,size: size*0.012,),
                                                //       onPressed: saveDocument,
                                                //     ),
                                                //     IconButton(
                                                //       icon:  Icon(Icons.download,color: AppColors.grey,size: size*0.012,),
                                                //       onPressed: loadDocument,
                                                //     ),
                                                //   ],
                                                // ),

                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey.shade100,
                                                      borderRadius: BorderRadius.circular(10)),
                                                  child: QuillEditor(
                                                    controller: _controller,
                                                    scrollController: _scrollController,
                                                    focusNode: _focusNode,
                                                    config: QuillEditorConfig(
                                                      placeholder: "Enter webinar description...",
                                                      padding: const EdgeInsets.all(16),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: size * 0.01),
                                            CustomTextField(
                                              hint: "Webinar Date",
                                              controller: loginController.webinarDateController, 
                                              // fillColor: AppColors.white,
                                              // borderColor: AppColors.grey,
                                              readOnly: true,
                                              onTap: () async {
                                                DateTime? pickedDate = await showDatePicker(
                                                  context: context,
                                                  initialDate:DateTime.now(),
                                                  firstDate: DateTime(1900),
                                                  lastDate:  DateTime(2050),
                                                );

                                                if (pickedDate != null) {
                                                  loginController.webinarDateController.text =
                                                  "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                                }
                                              },
                                            ),
                                            SizedBox(height: size * 0.01),

                                            CustomTextField(
                                              hint: "Webinar Link",
                                              icon: Icons.person,maxLines: 2,
                                              controller: loginController.webinarLinkController,
                                              //fillColor: AppColors.white,borderColor: AppColors.grey,
                                            ),
                                            SizedBox(height: size * 0.01),
                                            Align(
                                                alignment: Alignment.topLeft,
                                                child: Text('Webinar Timing',style: AppTextStyles.caption
                                                  (context,color: AppColors.black,fontWeight: FontWeight.bold),)),
                                            SizedBox(height: size * 0.01),
                                            Align(
                                                alignment: Alignment.topLeft,
                                                child: Text('Start Time',style: AppTextStyles.caption
                                                  (context,color: AppColors.black,fontWeight: FontWeight.bold),)),
                                            SizedBox(height: size * 0.01),

                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: CustomDropdownField(
                                                      hint: "Start Hour",
                                                      // icon: Icons.place,
                                                      //fillColor: Colors.grey.shade100,borderColor: AppColors.white,
                                                      items: const ["1","2","3","4","5","6","7","8","9","10","11","12"],
                                                      selectedValue: (
                                                          ["1","2","3","4","5","6","7","8","9","10","11","12"].
                                                          contains(loginController.startHour))
                                                          ? loginController.startHour
                                                          : null,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          loginController.startHour = value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: size * 0.01),
                                                  Expanded(
                                                    child: CustomDropdownField(
                                                      hint: "Start Minutes",
                                                      //fillColor: Colors.grey.shade100,borderColor: AppColors.white,
                                                      items: const ["00","05","10","15","20","25","30","35","40","45","50","55"],
                                                      selectedValue: (
                                                          ["00","05","10","15","20","25","30","35","40","45","50","55"].
                                                          contains(loginController.startMinutes))
                                                          ? loginController.startMinutes
                                                          : null,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          loginController.startMinutes = value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: size * 0.01),
                                                  Expanded(
                                                    child: CustomDropdownField(
                                                      hint: "AM/PM",
                                                      // icon: Icons.place,
                                                      //fillColor: AppColors.white,borderColor: AppColors.grey,
                                                      items: const ["am","pm"],
                                                      selectedValue: (
                                                          ["am","pm"].
                                                          contains(loginController.startPeriod))
                                                          ? loginController.startPeriod
                                                          : null,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          loginController.startPeriod = value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ]),
                                            SizedBox(height: size * 0.01),
                                            Align(
                                                alignment: Alignment.topLeft,
                                                child: Text('End Time',style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),)),
                                            SizedBox(height: size * 0.01),

                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: CustomDropdownField(
                                                      hint: "End Hour",
                                                      // icon: Icons.timelapse,
                                                      //fillColor: AppColors.white,borderColor: AppColors.grey,
                                                      //fillColor: AppColors.white,borderColor: AppColors.grey,
                                                      items: const ["1","2","3","4","5","6","7","8","9","10","11","12"],
                                                      selectedValue: (
                                                          ["1","2","3","4","5","6","7","8","9","10","11","12"].
                                                          contains(loginController.endHour))
                                                          ? loginController.endHour
                                                          : null,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          loginController.endHour = value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: size * 0.01),
                                                  Expanded(
                                                    child: CustomDropdownField(
                                                      hint: "End Minutes",
                                                      //icon: Icons.place,
                                                      //fillColor: AppColors.white,borderColor: AppColors.grey,
                                                      items: const ["00","05","10","15","20","25","30","35","40","45","50","55"],
                                                      selectedValue: (
                                                          ["00","05","10","15","20","25","30","35","40","45","50","55"].
                                                          contains(loginController.endMinutes))
                                                          ? loginController.endMinutes
                                                          : null,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          loginController.endMinutes = value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: size * 0.01),
                                                  Expanded(
                                                    child: CustomDropdownField(
                                                      hint: "AM/PM",
                                                      // icon: Icons.place,
                                                      //fillColor: AppColors.white,borderColor: AppColors.grey,
                                                      items: const ["am","pm"],
                                                      selectedValue: (
                                                          ["am","pm"].
                                                          contains(loginController.endPeriod))
                                                          ? loginController.endPeriod
                                                          : null,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          loginController.endPeriod = value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ]),
                                            SizedBox(height: size * 0.01),
             Text('Image',style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                                            SizedBox(height: size * 0.005),

                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                              GetBuilder<LoginController>(
                                              builder: (controller) {
                                              return SizedBox(
                                                height: size * 0.1,
                                                width: size*0.13,
                                              child: controller.webinarImages.isNotEmpty
                                              ? _buildSingleImageWidget(image: controller.webinarImages.first)
                                                  : GestureDetector(
                                              onTap: pickSingleWebinarImage1,
                                              child: Container(
                                                height: size * 0.1,
                                                width: size*0.13,
                                              //s * 0.13,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                              child: Icon(Icons.add, color: AppColors.grey, size: size * 0.012),
                                              ),
                                              ),
                                              ),
                                              );
                                              },
                                              ),


                                                // SizedBox(
                                                //   height: size * 0.1,
                                                //   width: size*0.13,
                                                //   child: GetBuilder<LoginController>(
                                                //     builder: (controller) {
                                                //       if (controller.webinarImages.isNotEmpty) {
                                                //         final file = controller.webinarImages.first;
                                                //         return _buildSingleImageWidget(file: file);
                                                //       }
                                                //       if (controller.webinarFileImages.isNotEmpty) {
                                                //         final img = controller.webinarFileImages.first;
                                                //         print('web img url${img.url}');
                                                //         return _buildSingleImageWidget(url: "${img.url}");
                                                //       }
                                                //       return GestureDetector(
                                                //         onTap: () => pickSingleImage(),
                                                //         child: Container(
                                                //           decoration: BoxDecoration(
                                                //             borderRadius: BorderRadius.circular(10),
                                                //             border: Border.all(color: Colors.grey),
                                                //             color: Colors.grey.shade200,
                                                //           ),
                                                //           child: const Center(
                                                //             child: Icon(Icons.add, size: 40, color: Colors.grey),
                                                //           ),
                                                //         ),
                                                //       );
                                                //     },
                                                //   ),
                                                // ),
                                                const SizedBox(height: 20),
                                                // Row(
                                                //   mainAxisAlignment: MainAxisAlignment.center,
                                                //   children: [
                                                //     ElevatedButton.icon(
                                                //       onPressed: () async {
                                                //         await pickImage();
                                                //         setState(() {});
                                                //       },
                                                //       icon:  Icon(Icons.photo,color: AppColors.primary,size: size*0.06,),
                                                //       label:  Text("Pick Image",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.primary),),
                                                //     ),
                                                //
                                                //     const SizedBox(width: 15),
                                                //
                                                //   ],
                                                // ),
                                              ],
                                            ),

                                            SizedBox(height: size * 0.03),

                                            Container(
                                              width: size*0.25,
                                              height: size*0.018,
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
                                                  if (_formKeyCreateWebinarWeb.currentState!.validate()) {
                                                    saveDocument();
                                                    if ((loginController.startHour != null && loginController.startHour!.isNotEmpty) &&
                                                        (loginController.startMinutes != null && loginController.startMinutes!.isNotEmpty) &&
                                                        (loginController.startPeriod != null && loginController.startPeriod!.isNotEmpty)) {
                                                      startTime="${loginController.startHour}:${loginController.startMinutes} ${loginController.startPeriod}";
                                                    } else {
                                                      startTime = null;
                                                      showCustomToast(context,  "Please Choose Start Time",);
                                                      return;
                                                    }
                                                    if ((loginController.endHour != null && loginController.endHour!.isNotEmpty) &&
                                                        (loginController.endMinutes != null && loginController.endMinutes!.isNotEmpty) &&
                                                        (loginController.endPeriod != null && loginController.endPeriod!.isNotEmpty)) {
                                                      endTime="${loginController.endHour}:${loginController.endMinutes} ${loginController.endPeriod}";
                                                    } else {
                                                      endTime = null;
                                                      showCustomToast(context,  "Please Choose End Time",);
                                                      return;
                                                    }
                                                    final webinarBytes = await convertImages(loginController.webinarImages ?? []);

                                                    final jobDescriptionPlain = _controller.document.toPlainText();
                                                    final webinarDescription =
                                                    jsonEncode(_controller.document.toDelta().toJson());
                                                    bool isSameDay= false;
                                                    if(jobController.webinar.isNotEmpty)
                                                      isSameDay= isWithinOneDay(jobController.webinar.first.createdDate.toString()??"");
                                                    print('sameday$isSameDay');
                                                    if(isSameDay||jobController.selectedWebinarId=="0") {
                                                      await jobController.postWebinarAdmin(
                                                        //jobController.selectedWebinarId.toString().isNotEmpty? jobController.selectedWebinarId.toString():"0",
                                                          jobController.selectedWebinarId
                                                              .toString(),
                                                          loginController.selectUserId!,
                                                          loginController.selectedUserType!,
                                                          loginController.typeNameController.text
                                                              .toString(),
                                                          loginController
                                                              .webinarTitleJobController.text
                                                              .toString(),
                                                          webinarDescription,
                                                          //jobDescriptionPlain,
                                                          // loginController
                                                          //     .webinarDescriptionJobController
                                                          //     .text.toString(),
                                                          loginController.webinarLinkController
                                                              .text.toString(),
                                                          loginController.webinarDateController
                                                              .text.toString(),
                                                          startTime.toString(),
                                                          endTime.toString(),webinarBytes,
                                                          // loginController.webinarImages.isNotEmpty
                                                          //     ? loginController.webinarImages
                                                          //     : [],
                                                          context
                                                      );
                                                    }
                                                    else{
                                                      showSuccessDialog(context, title:"Alert",
                                                          message :"Oops! Editing is allowed only for one day after you purchase a plan.", onOkPressed: () {});

                                                    }
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    backgroundColor: Colors.transparent,shadowColor: Colors.transparent
                                                ),
                                                child: Text(
                                                  job=='new'? "Create Webinar":"Edit Webinar",
                                                  style: AppTextStyles.body(context, color: AppColors.white,fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 30,)
                                          ],

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
          }
      ),
    );
  }
  Widget buildWebinarImage(String? imageUrl) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GetBuilder<JobController>(
        builder: (controller) {
          if (controller.webinarImage != null) {
            // Show picked image from device
            return Image.file(
              selectedImageFile!,
              fit: BoxFit.cover,
            );
          } else if (imageUrl != null && imageUrl.isNotEmpty) {
            // Show network image if already uploaded
            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported);
              },
            );
          } else {
            return const Center(child: Icon(Icons.image));
          }
        },
      ),
    );
  }
  bool isWithinOneDay(String createdDate) {
    DateTime created = DateTime.parse(createdDate);
    DateTime now = DateTime.now().toUtc();

    Duration difference = now.difference(created);

    return difference.inHours <= 24;
  }
  Future<String?> showSelectionDialog({
    required BuildContext context,
    required String title,
    required List<String> options,
    String? selectedValue,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        double size = MediaQuery.of(context).size.width;
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: size*0.013,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return RadioListTile<String>(
                  title: Text(option,style: AppTextStyles.caption(context),),
                  value: option,
                  groupValue: selectedValue,
                  onChanged: (value) => Navigator.pop(context, value),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<List<String>?> showMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<String> options,
    required List<String> selectedValues,
  }) async {
    return showDialog<List<String>>(
      context: context,
      builder: (context) {
        final tempSelected = List<String>.from(selectedValues);
        double size = MediaQuery.of(context).size.width;
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: size*0.013,
                child: ListView(
                  shrinkWrap: true,
                  children: options.map((e) {
                    return CheckboxListTile(
                      title: Text(e,style: AppTextStyles.caption(context),),
                      //checkColor: AppColors.white,
                      //activeColor: AppColors.primary,
                        selectedTileColor:AppColors.primary,
                      // fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                      //   if (states.contains(MaterialState.selected)) {
                      //     return AppColors.primary;
                      //   }
                      //   return Colors.grey.shade300;
                      // }),
                      value: tempSelected.contains(e),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) tempSelected.add(e);
                          else tempSelected.remove(e);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child:  Text("Cancel",style: AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold),),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child:  Text("OK",style: AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold),),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget buildPopupField({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? label,
              style: TextStyle(
                color: value == null ? Colors.grey : Colors.black,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget buildTimeRow({
    required String label,
    required String? hour,
    required String? minutes,
    required String? period,
    required VoidCallback onTapHour,
    required VoidCallback onTapMinutes,
    required VoidCallback onTapPeriod,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: buildPopupField(label: "Hour", value: hour, onTap: onTapHour)),
            const SizedBox(width: 8),
            Expanded(child: buildPopupField(label: "Minutes", value: minutes, onTap: onTapMinutes)),
            const SizedBox(width: 8),
            Expanded(child: buildPopupField(label: "AM/PM", value: period, onTap: onTapPeriod)),
          ],
        ),
      ],
    );
  }
}
