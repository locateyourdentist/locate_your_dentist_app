import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import '../../common_widgets/color_code.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CreateJobPost extends StatefulWidget {
  const CreateJobPost({super.key});

  @override
  State<CreateJobPost> createState() => _CreateJobPostState();
}
class _CreateJobPostState extends State<CreateJobPost> {
  final loginController=Get.put(LoginController());
  final jobController=Get.put(JobController());
  final _formKeyCreateJob = GlobalKey<FormState>();
  final _formKeyCreateWebinar = GlobalKey<FormState>();
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
  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      if (data == null || data.toString().trim().isEmpty) {
        delta = [{"insert": "\n"}];
      }
      else {
        dynamic decoded = data;
        if (data is String) {
          decoded = jsonDecode(data);
        }
        if (decoded is List) {
          delta = List<Map<String, dynamic>>.from(decoded);
          if (delta.isEmpty) {
            delta = [{"insert": "\n"}];
          }
        } else {
          delta = [{"insert": "\n"}];
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
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
        ),

      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedString == "Webinar") {
        print("Loading Webinar Description");
        loadJobDescription(
            jobController.webDescriptionData);
      } else {
        print("Loading Job Description");
        loadJobDescription(
            jobController.jobDescriptionData);
      }
    });
    loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    jobController.selectedJobId.toString().isNotEmpty? jobController.selectedJobId.toString():"0";
    print('jobid${jobController.selectedJobId}webid${jobController.selectedWebinarId.toString()}');
    jobController.selectedWebinarId.toString().isNotEmpty? jobController.selectedWebinarId.toString():"0";
    jobController.checkJobPlanStatus(userId, context);
  }
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      selectedImageFile = File(pickedFile.path);
      jobController.webinarImage=null;
    }
  }
  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      selectedImageFile = File(pickedFile.path);
    }
  }
  Future<void> pickSingleImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      final selectedImageFile = File(pickedImage.path);

      loginController.webinarImages1.clear();
      loginController.webinarImages1.add(selectedImageFile);

      loginController.webinarFileImages.clear();
      loginController.update();
    }
  }
  Widget _buildSingleImageWidget({File? file, String? url}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _buildImage(file, url),
          // file != null
          //     ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
          //     : Image.network(url!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () async{
              loginController.webinarImages.clear();
              loginController.webinarFileImages.clear();
              loginController.update();
              await loginController.deleteAwsFile(url.toString(),'user', context);
              },
            child: const Icon(Icons.cancel, color: Colors.black,),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: GestureDetector(
            onTap: () => pickSingleImage(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
  Future<void> pickSingleImage1() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      final selectedImageFile = File(pickedImage.path);
      loginController.jobImages1.clear();
      loginController.jobImages1.add(selectedImageFile);
      loginController.jobFileImages.clear();
      loginController.update();
    }
  }

  Widget _buildSingleImageWidget1({File? file, String? url}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:  _buildImage(file, url),
          // file != null
          //     ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
          //     : Image.network(url!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: ()async {
              loginController.jobImages.clear();
              loginController.jobFileImages.clear();
              loginController.update();
              await loginController.deleteAwsFile(url.toString(),'user', context);
              },
            child: const Icon(Icons.cancel, color: Colors.black,),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: GestureDetector(
            onTap: () => pickSingleImage(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildImage(File? file, String? url) {
    if (file != null) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (url != null && url.isNotEmpty && url != "null") {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _errorWidget();
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    return _errorWidget();
  }
  Widget _errorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
    decoration: BoxDecoration(
    color: const Color(0xFFF1F3F6),
    borderRadius: BorderRadius.circular(16),
    ),
    child: Icon(
    Icons.image_outlined,
    color: Colors.grey.shade400,
    size: 40,
    ),
    );
    Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Add/Edit Jobs Webinars',
          style: AppTextStyles.subtitle(context,color: AppColors.white),),automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
           Navigator.pop(context);
                },
            child: const Center(
              child: Icon(
                Icons.arrow_back,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<JobController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size*0.03,),

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
                    key: _formKeyCreateJob,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size*0.03,),
                        Text(jobController.selectedJobId.toString().isNotEmpty? "Edit New Job":  'Post New Job',style: AppTextStyles.subtitle(context,color: AppColors.black),),
                        SizedBox(height: size*0.03,),
                        CustomTextField(
                          hint: "Job Title",
                          icon: Icons.title,
                          controller: loginController.jobTitleController,
                          fillColor: AppColors.white,
                          borderColor: AppColors.grey,
                        ),
                        SizedBox(height: size*0.03,),
                        // CustomTextField(
                        //   hint: "Job Description",
                        //   icon: Icons.text_fields,
                        //   controller: loginController.jobDescController,
                        //    fillColor: AppColors.white,
                        //   borderColor: AppColors.grey,maxLines: 3,
                        // ),
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),),
                              height: size*0.4,
                              width: double.infinity,
                              child: QuillSimpleToolbar(
                                controller: _controller,
                                config: QuillSimpleToolbarConfig(
                                  //embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                                  embedButtons: [],
                                  showBackgroundColorButton: false,
                                ),
                              ),
                            ),
                            Container(
                              height: size*0.5,
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
                                  placeholder: "Job description...",
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size * 0.03),
                        CustomDropdownField(
                          hint: "Select JobType",
                          //icon: Icons.timelapse,
                          fillColor: AppColors.white,borderColor: AppColors.grey,
                          items: const ["Full Time", "Part Time", "Remote"],
                          //selectedValue: loginController.selectedJobType,
                          selectedValue: (["Full Time", "Part Time", "Remote"].contains(loginController.selectedJobType))
                              ? loginController.selectedJobType
                              : null,
                          onChanged: (value) {
                            setState(() {
                              loginController.selectedJobType = value;
                            });
                          },
                        ),
                        SizedBox(height: size * 0.03),
                        GetBuilder<JobController>(
                          builder: (jobController) {
                            final List<MultiSelectItem<String>> categoryItems =
                            jobController!.jobCategoryAdmin
                                .map(
                                  (e) => MultiSelectItem<String>(
                                e.name.trim(),
                                e.name.trim(),
                              ),
                            ).toList();
                            return MultiSelectDialogField<String>(
                              items: categoryItems,
                              selectedColor: AppColors.primary,
                              initialValue: loginController.selectedCategories,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.grey, width: 1),
                              ),
                              buttonText: Text(
                                "Select Job Categories",
                                style: AppTextStyles.caption(
                                  context,
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              onConfirm: (results) {
                                loginController.selectedCategories = results;
                                loginController.update();
                              },
                            );
                          },
                        ),
                        SizedBox(height: size * 0.03),
                        Text('Start Time',style: AppTextStyles.caption
                          (context,color: AppColors.black,fontWeight: FontWeight.bold),),
                        SizedBox(height: size * 0.02),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: size*0.3,
                                child: CustomDropdownField(
                                  hint: "Start Hour",
                                  // icon: Icons.place,
                                  fillColor: AppColors.white,borderColor: AppColors.grey,
                                  items: const ["1","2","3","4","5","6","7","8","9","10","11","12"],
                                  selectedValue: (
                                      ["1","2","3","4","5","6","7","8","9","10","11","12"].
                                      contains(jobController.startHour))
                                      ? jobController.startHour
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      jobController.startHour = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: size*0.3,
                                child: CustomDropdownField(
                                  hint: "Start Minutes",
                                  fillColor: AppColors.white,borderColor: AppColors.grey,
                                  items: const ["00","05","10","15","20","25","30","35","40","45","50","55"],
                                  selectedValue: (
                                      ["00","05","10","15","20","25","30","35","40","45","50","55"].
                                      contains(jobController.startMinutes))
                                      ? jobController.startMinutes
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      jobController.startMinutes = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: size*0.3,
                                child: CustomDropdownField(
                                  hint: "AM/PM",
                                  // icon: Icons.place,
                                  fillColor: AppColors.white,borderColor: AppColors.grey,
                                  items: const ["am","pm"],
                                  selectedValue: (
                                      ["am","pm"].
                                      contains(jobController.startPeriod))
                                      ? jobController.startPeriod
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      jobController.startPeriod = value;
                                    });
                                  },
                                ),
                              ),
                            ]),
                        SizedBox(height: size * 0.01),
                        Text('End Time',style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                        SizedBox(height: size * 0.02),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: size*0.3,
                                child: CustomDropdownField(
                                  hint: "End Hour",
                                  // icon: Icons.timelapse,
                                  fillColor: AppColors.white,borderColor: AppColors.grey,
                                  items: const ["1","2","3","4","5","6","7","8","9","10","11","12"],
                                  selectedValue: (
                                      ["1","2","3","4","5","6","7","8","9","10","11","12"].
                                      contains(jobController.endHour))
                                      ? jobController.endHour
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      jobController.endHour = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: size*0.3,
                                child: CustomDropdownField(
                                  hint: "End Minutes",
                                  //icon: Icons.place,
                                  fillColor: AppColors.white,borderColor: AppColors.grey,
                                  items: const ["00","05","10","15","20","25","30","35","40","45","50","55"],
                                  selectedValue: (
                                      ["00","05","10","15","20","25","30","35","40","45","50","55"].
                                      contains(jobController.endMinutes))
                                      ? jobController.endMinutes
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      jobController.endMinutes = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: size*0.3,
                                child: CustomDropdownField(
                                  hint: "AM/PM",
                                  // icon: Icons.place,
                                  fillColor: AppColors.white,borderColor: AppColors.grey,
                                  items: const ["am","pm"],
                                  selectedValue: (
                                      ["am","pm"].
                                      contains(jobController.endPeriod))
                                      ? jobController.endPeriod
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      jobController.endPeriod = value;
                                    });
                                  },
                                ),
                              ),
                            ]),
                        SizedBox(height: size * 0.03),

                        CustomDropdownField(
                          hint: "Select Salary(Per Month)",
                          //icon: Icons.monetization_on,
                          fillColor: AppColors.white,borderColor: AppColors.grey,
                          items: const [
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
                          selectedValue: ([
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
                          ].contains(loginController.selectedSalary))
                              ? loginController.selectedSalary
                              : null,
                          onChanged: (value) {
                            setState(() {
                              loginController.selectedSalary = value;
                            });
                          },
                        ),

                        SizedBox(height: size * 0.03),
                        CustomTextField(
                          hint: "Qualification",
                          icon: Icons.person,
                          controller: loginController.qualificationJobController,
                          fillColor: AppColors.white,borderColor: AppColors.grey,maxLines: 3,
                        ),
                        SizedBox(height: size * 0.04),
                        CustomDropdownField(
                          hint: "Select Experience",
                         // icon: Icons.place,
                          fillColor: AppColors.white,borderColor: AppColors.grey,
                          items: const ["Fresher", "1 Year", "2 Years","3 Years","4 Years","5 Years","5 - 8 Years","8 -10 Years","Above 10 Years",],
                          selectedValue: ([
                            "Fresher",
                            "1 Year",
                            "2 Years",
                            "3 Years",
                            "4 Years",
                            "5 Years",
                            "5 - 8 Years",
                            "8 -10 Years",
                            "Above 10 Years",
                          ].contains(loginController.selectedExperience))
                              ? loginController.selectedExperience
                              : null,                      onChanged: (value) {
                            setState(() {
                              loginController.selectedExperience = value;
                            });
                          },
                        ),
                        SizedBox(height: size * 0.03),
                        Column(
                          children: [
                            SizedBox(
                              height: size * 0.5,
                              child: GetBuilder<LoginController>(
                                builder: (controller) {
                                  if (controller.jobImages1.isNotEmpty) {
                                    final file = controller.jobImages1.first;
                                    return _buildSingleImageWidget(file: file);
                                  }
                                  if (controller.jobFileImages.isNotEmpty) {
                                    final img = controller.jobFileImages.first;
                                    print('web img url${img.url}');
                                    return _buildSingleImageWidget1(url: "${img.url}");
                                  }
                                  return GestureDetector(
                                    onTap: () => pickSingleImage1(),
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
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Buttons Row
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
                        SizedBox(height: size * 0.06),

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
                                if (_formKeyCreateJob.currentState!.validate()) {

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
                                    showCustomToast(context,  "Please Choose Start Time",);
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
                                 // final raw = jobController.planActive;
                                 // print('rawf$raw');
                                  // raw == true || raw == "true";
                                  if ((jobController.jobCount ?? 0) > 0) {
                                    await jobController.postJobsAdmin(
                                       jobController.selectedJobId.toString()??"0",
                                       //  jobController.selectedJobId.toString().isNotEmpty? jobController.selectedJobId.toString():"0",
                                        loginController.selectUserId!,
                                        loginController.selectedUserType!,
                                        loginController.selectedJobType
                                            .toString(),
                                        loginController.selectedCategories,
                                        loginController.typeNameController.text
                                            .toString(),
                                        loginController.jobTitleController.text
                                            .toString(),
                                        loginController.jobDescController.text
                                            .toString(),
                                        loginController.selectedSalary.toString(),
                                        loginController.qualificationJobController
                                            .text.toString(),
                                        loginController.selectedExperience
                                            .toString(),
                                        loginController.stateController.text
                                            .toString(),
                                        loginController.districtController.text
                                            .toString(),
                                        loginController.cityController.text
                                            .toString(),
                                        jobStartTime.toString(),
                                        jobEndTime.toString(),loginController.jobImages1.isNotEmpty?loginController.jobImages1:[],context
                                    );
                                    await jobController.getJobListAdmin(context);
                                 }
                                  else{
                                  // showCustomToast(context,  "Please buy new plan");
                                   showSuccessDialog(context, title:"Alert",message :"Oops! Your plan has expired. Please purchase a new plan to continue posting jobs.",
                                       onOkPressed: () {
                                     Get.toNamed('/viewPlanPage');
                                   });
                                   //planController.checkPlanList.isNotEmpty? showPlanAlerts(planController.checkPlanList??[],context):"";

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
                      key: _formKeyCreateWebinar,
                      child: Column(
                        children: [
                          SizedBox(height: size*0.03,),

                          Text(jobController.selectedWebinarId.toString().isNotEmpty? "Edit Webinar":  'Post New Webinar',style: AppTextStyles.subtitle(context,color: AppColors.black),),
                          SizedBox(height: size*0.03,),
                          CustomTextField(
                            hint: "Webinar Title",
                            icon: Icons.title,
                            controller: loginController.webinarTitleJobController,
                            fillColor: AppColors.white,
                            borderColor: AppColors.grey,
                          ),
                          SizedBox(height: size*0.03,),
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),),
                                height: size*0.15,
                                width: double.infinity,
                                child: QuillSimpleToolbar(
                                  controller: _controller,
                                  config: QuillSimpleToolbarConfig(
                                    embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                                  ),
                                ),
                              ),
                              Container(
                                height: size*0.1,
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
                                    placeholder: "Enter webinar description...",
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // CustomTextField(
                          //   hint: "Webinar Description",
                          //   icon: Icons.text_fields,
                          //   controller: loginController.webinarDescriptionJobController,
                          //   fillColor: AppColors.white,
                          //   borderColor: AppColors.grey,maxLines: 4,
                          // ),
                          SizedBox(height: size * 0.03),
                          CustomTextField(
                            hint: "Webinar Date",
                            controller: loginController.webinarDateController,  fillColor: AppColors.white,
                            borderColor: AppColors.grey,
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
                          SizedBox(height: size * 0.03),

                          CustomTextField(
                            hint: "Webinar Link",
                            icon: Icons.person,maxLines: 2,
                            controller: loginController.webinarLinkController,
                            fillColor: AppColors.white,borderColor: AppColors.grey,
                          ),
                          SizedBox(height: size * 0.03),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text('Working hours',style: AppTextStyles.caption
                                (context,color: AppColors.black,fontWeight: FontWeight.bold),)),
                          SizedBox(height: size * 0.02),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text('Start Time',style: AppTextStyles.caption
                                (context,color: AppColors.black,fontWeight: FontWeight.bold),)),
                          SizedBox(height: size * 0.02),

                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                          SizedBox(
                            width: size*0.3,
                            child: CustomDropdownField(
                              hint: "Start Hour",
                             // icon: Icons.place,
                              fillColor: AppColors.white,borderColor: AppColors.grey,
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
                                SizedBox(
                            width: size*0.3,
                            child: CustomDropdownField(
                              hint: "Start Minutes",
                              fillColor: AppColors.white,borderColor: AppColors.grey,
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
                                SizedBox(
                                  width: size*0.3,
                                  child: CustomDropdownField(
                                    hint: "AM/PM",
                                    // icon: Icons.place,
                                    fillColor: AppColors.white,borderColor: AppColors.grey,
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
                          SizedBox(height: size * 0.02),

                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size*0.3,
                                  child: CustomDropdownField(
                                    hint: "End Hour",
                                   // icon: Icons.timelapse,
                                    fillColor: AppColors.white,borderColor: AppColors.grey,
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
                                SizedBox(
                                  width: size*0.3,
                                  child: CustomDropdownField(
                                    hint: "End Minutes",
                                    //icon: Icons.place,
                                    fillColor: AppColors.white,borderColor: AppColors.grey,
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
                                SizedBox(
                                  width: size*0.3,
                                  child: CustomDropdownField(
                                    hint: "AM/PM",
                                    // icon: Icons.place,
                                    fillColor: AppColors.white,borderColor: AppColors.grey,
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
                          SizedBox(height: size * 0.03),

                          Column(
                            children: [
                              SizedBox(
                                height: size * 0.5,
                                child: GetBuilder<LoginController>(
                                  builder: (controller) {
                                    if (controller.webinarImages1.isNotEmpty) {
                                      final file = controller.webinarImages1.first;
                                      return _buildSingleImageWidget(file: file);
                                    }
                                    if (controller.webinarFileImages.isNotEmpty) {
                                      final img = controller.webinarFileImages.first;
                                      print('web img url${img.url}');
                                      return _buildSingleImageWidget(url: "${img.url}");
                                    }
                                    return GestureDetector(
                                      onTap: () => pickSingleImage(),
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
                                    );
                                  },
                                ),
                              ),
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

                          SizedBox(height: size * 0.06),

                          Container(
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
                                if (_formKeyCreateWebinar.currentState!.validate()) {
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
                                        loginController
                                            .webinarDescriptionJobController
                                            .text.toString(),
                                        loginController.webinarLinkController
                                            .text.toString(),
                                        loginController.webinarDateController
                                            .text.toString(),
                                        startTime.toString(),
                                        endTime.toString(),
                                        loginController.webinarImages1.isNotEmpty
                                            ? loginController.webinarImages1
                                            : [], context
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
                ],
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
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

}
