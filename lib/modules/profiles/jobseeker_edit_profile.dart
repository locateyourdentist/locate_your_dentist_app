import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/profiles/clinic_edit_profile.dart';
import 'package:locate_your_dentist/modules/profiles/pdf_path_view_page.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import '../../common_widgets/color_code.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  final _formKeyEditJobProfile = GlobalKey<FormState>();
  final jobController=Get.put(JobController());
  final loginController=Get.put(LoginController());
  late QuillController _controller;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Future<void> pickSingleImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      final file = File(pickedImage.path);
      loginController.images.clear();
      loginController.images.add(file);
      loginController.editImages.clear();
      loginController.update();
    }
  }
  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta;

      if (data == null || data.toString().trim().isEmpty) {
        delta = [
          {"insert": "\n"}
        ];
      }

      else if (data is String) {
        final trimmed = data.trim();

        if (trimmed.isEmpty || trimmed == "[]") {
          delta = [
            {"insert": "\n"}
          ];
        } else {
          final decoded = jsonDecode(trimmed);

          if (decoded is List && decoded.isNotEmpty) {
            delta = List<Map<String, dynamic>>.from(decoded);
          } else {
            delta = [
              {"insert": "\n"}
            ];
          }
        }
      }

      else if (data is List && data.isNotEmpty) {
        delta = List<Map<String, dynamic>>.from(data);
      }

      else {
        delta = [
          {"insert": "\n"}
        ];
      }

      _controller.document = Document.fromJson(delta);
      setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      _controller.document = Document.fromJson([
        {"insert": "\n"}
      ]);

      setState(() {});
    }
  }
  Future<void> pickSingleImage1() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      final file = File(pickedImage.path);

      loginController.logoImages.clear();
      loginController.logoImage.clear();

      loginController.logoImages.add(file);
      loginController.update();
    }
  }
  Future<void> pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path!;
        loginController.certificates.clear();
        loginController.editCertificates.clear();

        setState(() {
          loginController.certificates.add(File(filePath));
        });

        print("PDF selected: $filePath");
      } else {
        print("No file selected");
      }
    } catch (e) {
      print('Error picking PDF: $e');
      Get.snackbar("Error", "Failed to pick PDF");
    }
  }
  Widget _buildSingleImageWidget({File? file, String? url}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: file != null
              ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
              : Image.network(url!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              loginController.images.clear();
              loginController.editImages.clear();
              loginController.logoImages.clear();
              loginController.update();
            },
            child: const Icon(Icons.cancel, color: Colors.black),
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
  Widget _buildSinglePdfWidget({File? file, String? url}) {
    final fileName = file?.path.split('/').last ?? url?.split('/').last ?? "PDF";
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewPDFPage(pdfUrl:loginController.userData.first.certificates[0]??""),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),

        // DELETE BUTTON
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              loginController.certificates.clear();
              loginController.editCertificates.clear();
              loginController.update();
            },
            child: const Icon(Icons.cancel, color: Colors.black),
          ),
        ),

        // EDIT BUTTON
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => pickResume(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  Future<void> pickDOB(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime lastAllowedDate = DateTime(
      today.year - 21,
      today.month,
      today.day,
    );
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1955),
      firstDate: lastAllowedDate,
      lastDate: lastAllowedDate,
    );
    if (pickedDate != null) {
      loginController.dobController.text = formatDate(pickedDate);
    }
  }
  @override
  void initState(){
    super.initState();
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
        ),

      ),
    );
    _refresh();
  }
  Future<void> _refresh() async {
    //loginController.getProfileByUserId(userId!, context);
    await loginController.fetchStates();
    loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    jobController.getJobCategoryLists("",context);
    loadJobDescription(loginController.descriptionData);
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    final _items = jobController.jobCategoryAdmin;
    //jobCategories.map((e) => MultiSelectItem<String>(e, e)).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile", style: AppTextStyles.subtitle(context)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKeyEditJobProfile,
          child: Column(
            children: [
          
              sectionTitle("Personal Information", size),
              CustomTextField(
                hint: "Name",
                icon: Icons.person,
                controller: loginController.fullNameController,
              ),
              SizedBox(height: size * 0.03),
            CustomTextField(
              hint: "Date of Birth",
              controller: loginController.dobController,  fillColor: AppColors.white,
              borderColor: AppColors.grey,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  loginController.dobController.text =
                  "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                }
              },
            ),
            SizedBox(height: size * 0.03),
              CustomTextField(
                  hint: "Email",
                  icon: Icons.email,
                  controller: loginController.emailController,
                  keyboardType: TextInputType.emailAddress
              ),
              SizedBox(height: size * 0.03),
          
              CustomTextField(
                hint: "Mobile Number",
                icon: Icons.phone,
                controller: loginController.mobileController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Mobile Number cannot be empty";
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                    return "Enter a valid 10-digit mobile number starting with 6-9";
                  }
                  return null;
                },
              ),
              SizedBox(height: size * 0.03),

              // const SizedBox(height: 20),
          
              sectionTitle("Location Details", size),
              CustomTextField(
                hint: "State",
                icon: Icons.map,
                controller: loginController.stateController,
              ),
              SizedBox(height: size * 0.03),
          
              CustomTextField(
                hint: "District",
                icon: Icons.location_city,
                controller: loginController.districtController,
              ),
              SizedBox(height: size * 0.03),
              CustomTextField(
                hint: "City",
                icon: Icons.location_city,
                controller: loginController.cityController,
              ),
              SizedBox(height: size * 0.03),
              CustomTextField(
                hint: "Area",
                icon: Icons.location_city,
                controller: loginController.areaController,
              ),
              SizedBox(height: size * 0.03),
              CustomTextField(
                hint: "Pincode",
                icon: Icons.location_city,
                controller: loginController.pinCodeController,
              ),
              const SizedBox(height: 20),
              // CustomTextField(
              //   hint: "About Me",
              //   icon: Icons.location_on,maxLines: 5,
              //   controller: loginController.descriptionController,
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
                        // embedButtons: FlutterQuillEmbeds.toolbarButtons(),
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
                        placeholder: "Enter  description...",
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size*0.03,),
              sectionTitle( "Select Preferences Job Categories",size),
              SizedBox(height: size*0.01,),
            GetBuilder<JobController>(
              builder: (jobController) {
                final List<MultiSelectItem<String>> categoryItems =
                jobController.jobCategoryAdmin
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
            sectionTitle("Educational Details", size),
          
               Text("UG Details", style: AppTextStyles.body(context,fontWeight: FontWeight.bold)),
              SizedBox(height: size * 0.02),

              CustomTextField(
                hint: "College Name",
                controller: loginController.ugCollege,
              ),
              SizedBox(height: size * 0.03),
              CustomTextField(
                hint: "Degree",
                controller: loginController.ugDegree,
              ),
              SizedBox(height: size * 0.03),
              CustomTextField(
                hint: "Percentage",
                controller: loginController.ugPercentage,
              ),
              SizedBox(height: size * 0.03),


              // CustomTextField(
              //   hint: "College Name",
              //   controller: loginController.pgCollege,
              // ),
              // SizedBox(height: size * 0.03),
              //
              // CustomTextField(
              //   hint: "Degree",
              //   controller: loginController.pgDegree,
              // ),
              // SizedBox(height: size * 0.03),
              //
              // CustomTextField(
              //   hint: "Percentage",
              //   controller: loginController.pgPercentage,
              // ),
              GetBuilder<LoginController>(
                  builder: (controller) {
                    return  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          loginController.togglePGDetails();
                        },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                   // shadowColor: AppColors.primary.withOpacity(0.5),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    ),),
                        child: Text(
                          loginController.showPGDetails ? "Hide PG Details" : "Add PG Details",textAlign: TextAlign.right,
                            style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white)
                        )
                      ),

                      // PG Details section
                      loginController.showPGDetails
                          ? GetBuilder<LoginController>(
                          builder: (controller) {
                              return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                               Text(
                                "PG Details", style: AppTextStyles.body(context,fontWeight: FontWeight.bold)

                              ),
                              const SizedBox(height: 10),

                              CustomTextField(
                                hint: "College Name",
                                controller: loginController.pgDetails.collegeName,
                              ),
                              const SizedBox(height: 10),

                              CustomTextField(
                                hint: "Degree",
                                controller: loginController.pgDetails.degree,
                              ),
                              const SizedBox(height: 10),

                              CustomTextField(
                                hint: "Percentage",
                                controller: loginController.pgDetails.percentage,
                              ),
                              const SizedBox(height: 10),

                              // CustomTextField(
                              //   hint: "About Me",
                              //   icon: Icons.location_on,
                              //   controller: loginController.descriptionController,
                              // ),
                              const SizedBox(height: 20),
                                                  ],
                                                );
                            }
                          )
                          : const SizedBox.shrink(),
                    ],
                  );
                }
              ),
              SizedBox(height: size * 0.03),
              GetBuilder<LoginController>(
                  builder: (controller) {
                    return Column(
                    children: [
                      for (int i = 0; i < loginController.experienceList.length; i++)
                        _experienceFields(i,size),

                      SizedBox(height: size * 0.03),
                      Text('Upload Image(Not Mandatory)',style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                      SizedBox(height: size * 0.01),
                             SizedBox(
                               height: size * 0.5,
                               child: GetBuilder<LoginController>(
                                 builder: (controller) {
                    if (controller.images.isNotEmpty) {
                      final file = controller.images.first;

                      return _buildSingleImageWidget(file: file);
                    }
                    if (controller.editImages.isNotEmpty) {
                      final img = controller.editImages.first;
                      print('job img url${img.url}}');
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

                      SizedBox(height: size * 0.06),
                      Text('Upload Resume',style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                      SizedBox(height: size * 0.01),
                      SizedBox(
                                 height: size * 0.15,
                                 child: GetBuilder<LoginController>(
                                 builder: (_) {
                    if (loginController.certificates.isNotEmpty) {
                      final file = loginController.certificates.first;
                      return _buildSinglePdfWidget(file: file);
                    }
                    if (loginController.editCertificates.isNotEmpty) {
                      final pdf = loginController.editCertificates.first;
                      return _buildSinglePdfWidget(url: pdf.url);
                    }
                    return GestureDetector(
                      onTap: () => pickResume(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                          color: Colors.grey.shade200,
                        ),
                        child: const Center(
                          child: Icon(Icons.picture_as_pdf, size: 40, color: Colors.grey),
                        ),
                      ),
                    );
                                 },
                               ),
                             ),


                      SizedBox(height: size * 0.03),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.white),
                        onPressed: () => loginController.addExperienceField(),
                        icon:  Icon(Icons.add,size: size*0.05,color: AppColors.primary),
                        label:  Text("Add Experience",style: AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold),),
                      )
                    ],
                                 );
                 }
               ),
              SizedBox(height: size * 0.06),
          
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKeyEditJobProfile.currentState!.validate()) return;

                    print("---- DEBUG: Form values ----");
                    print("UserId: ${Api.userInfo.read('userId')}");
                    print("UserType: ${Api.userInfo.read('userType')}");
                    print("FullName: ${loginController.fullNameController.text}");
                    print("Mobile: ${loginController.mobileController.text}");
                    print("Email: ${loginController.emailController.text}");
                    print("Address: ${loginController.addressController.text}");
                    print("ConfirmPassword: ${loginController.confirmPasswordController.text}");
                    print("Taluk: ${loginController.stateController.text}");
                    print("District: ${loginController.districtController.text}");
                    print("City: ${loginController.cityController.text}");
                    print("PinCode: ${loginController.pinCodeController.text}");
                    print("TypeName: ${loginController.typeNameController.text}");
                    print("Images: ${loginController.images}");
                    print("Certificates: ${loginController.certificates}");


                    List<Map<String, dynamic>> expJson = loginController.experienceList.map((e) {
                      print("Experience Field: ${e.companyName.text}, ${e.experience.text}, ${e.jobDescription.text}");
                      return {
                        "companyName": e.companyName.text ?? "",
                        "experience": e.experience.text ?? "",
                        "jobDescription": e.jobDescription.text ?? "",
                      };
                    }).toList();

                    Map<String, dynamic> finalJson = {
                      "details": {
                        "collegeDetails": {
                          "ugDegree": {
                            "name": loginController.ugCollege.text ?? "",
                            "degree": loginController.ugDegree.text ?? "",
                            "percentage": loginController.ugPercentage.text ?? "",
                          },
                          "pgDegree": {
                            "name": loginController.pgCollege.text ?? "",
                            "degree": loginController.pgDegree.text ?? "",
                            "percentage": loginController.pgPercentage.text ?? "",
                          },
                        },
                        "experienceDetails": expJson,
                      }
                    };
                    print("Details JSON: $finalJson");
                    final userType = "${Api.userInfo.read('userType')}";
                    if (userType == null || userType.isEmpty) {
                      Get.snackbar("Error", "Please select user type");
                      return;
                    }
                      print('userid${Api.userInfo.read('userId')} ');
                    try {
                      await loginController.registerUser(
                        userId: Api.userInfo.read('userId') ?? "",
                        userType: userType,
                        fullName: loginController.fullNameController.text ?? "",
                        martialStatus:loginController.selectedMartialStatus!,
                        dob: loginController.dobController.text??"",
                        mobile: loginController.mobileController.text ?? "",
                        email: loginController.emailController.text ?? "",
                        // address: loginController.addressController.text ?? "",
                        // confirmPassword: loginController.confirmPasswordController.text ?? "",
                        taluk: loginController.stateController.text ?? "",
                        district: loginController.districtController.text ?? "",
                        city: loginController.cityController.text ?? "",area: loginController.areaController.text??"",
                        pinCode: loginController.pinCodeController.text ?? "",
                        typeName: loginController.typeNameController.text ?? "",
                        image: loginController.images.isNotEmpty ? loginController.images : [],
                        certificate: loginController.certificates.isNotEmpty ? loginController.certificates : [],
                        description: loginController.descriptionController.text,
                        jobCategory:loginController.selectedCategories,
                        details: finalJson,
                        context: context,
                      );
                      print("Register API called successfully");
                    } catch (e, st) {
                      print("Register Error: $e");
                      print("Stack Trace: $st");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Save Changes",
                    style: AppTextStyles.body(context,fontWeight: FontWeight.bold,color: AppColors.white),
                  ),
                ),
              ),
          
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text, double size) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(
          text,
          style: TextStyle(fontSize: size * 0.032, fontWeight: FontWeight.bold,color: AppColors.primary),
        ),
      ),
    );
  }
}
Widget editField({
  required String label,
  required TextEditingController controller,
  required double size,
  TextInputType keyboard = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: TextField(
      controller: controller,
      keyboardType: keyboard,
      style: TextStyle(fontSize: size * 0.04),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        TextStyle(color: Colors.black54, fontSize: size * 0.04),

        filled: true,
        fillColor: Colors.grey.shade100,

        // Border (UNFOCUSED)
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(14),
        ),

        // Border (FOCUSED)
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 0.3),
          borderRadius: BorderRadius.circular(14),
        ),

        // Border (DISABLED)
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}
Widget _buildCertificatePreview(cert, double size) {
  String fileName = getCertificateFileName(cert);

  if (cert.file != null) {
    final filePath = cert.file!.path.toLowerCase();
    if (filePath.endsWith(".pdf")) {
      return _pdfPlaceholder(size, fileName);
    }
    return Image.file(cert.file!, fit: BoxFit.cover, width: size * 0.3, height: size * 0.3);
  }

  if (cert.url != null && cert.url!.isNotEmpty) {
    final url = cert.url!.toLowerCase();
    if (url.endsWith(".pdf")) {
      return _pdfPlaceholder(size, fileName);
    }
    return Image.network(cert.url!, fit: BoxFit.cover, width: size * 0.3, height: size * 0.3);
  }

  return _errorPlaceholder(size);
}
Widget _pdfPlaceholder(double size, String fileName) {
  return Container(
    color: Colors.grey.shade300,
    width: size * 0.3,
    height: size * 0.3,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
        const SizedBox(height: 4),
        Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:  TextStyle(fontSize: size*0.012,fontWeight: FontWeight.normal,color: AppColors.black),
        ),
      ],
    ),
  );
}
Widget _errorPlaceholder(double size) {
  return Container(
    color: Colors.grey.shade200,
    width: size * 0.3,
    height: size * 0.3,
    child: const Center(
      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
    ),
  );
}
Widget _experienceFields(int index,size) {
  final loginController=Get.put(LoginController());
  final exp = loginController.experienceList[index];

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Experience ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
             SizedBox(height: size*0.02,),
            if (index > 0)
              GetBuilder<LoginController>(
                  builder: (controller) {
                    return IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => loginController.removeExperienceField(index),
                  );
                }
              ),
          ],
        ),

        CustomTextField(
          hint: "Company Name",
          controller: exp.companyName,
        ),
        SizedBox(height: size * 0.03),
        CustomTextField(
          hint: "Experience (e.g. 4 years)",
          controller: exp.experience,
        ),
        SizedBox(height: size * 0.03),
        CustomTextField(
          hint: "Job Description",
          controller: exp.jobDescription,
        ),            SizedBox(height: size * 0.03),

      ],
    ),
  );
}
