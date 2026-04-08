// import 'package:flutter/material.dart';
// import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
// import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
// import 'package:get/get.dart';
// import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
// import '../../common_widgets/color_code.dart';
//
//
// class AddJobCategory extends StatefulWidget {
//   const AddJobCategory({super.key});
//
//   @override
//   State<AddJobCategory> createState() => _AddJobCategoryState();
// }
//
// class _AddJobCategoryState extends State<AddJobCategory> {
//   final jobController=Get.put(JobController());
//   final List<String> userTypes = const [
//     "Dental Clinic",
//     "Dental Lab",
//     "Dental Shop",
//     "Dental Mechanic",
//     "Dental Consultant"
//   ];
//   @override
//   Widget build(BuildContext context) {
//     double size = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,backgroundColor: AppColors.white,
//         title: Text('Add Job Category',
//           style: AppTextStyles.subtitle(context,color: AppColors.black),),automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: Container(
//               decoration:  const BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [AppColors.primary, AppColors.secondary],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: const Center(
//                 child: Icon(
//                   Icons.arrow_back,
//                   color: AppColors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//             children: [
//
//               Row(
//                 children: [
//                   Text(
//                     "Select User Type",
//                     style: AppTextStyles.caption(
//                       context,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//
//                   const SizedBox(width: 10),
//                   SizedBox(
//                     width: size * 0.55,
//                     child: GetBuilder<JobController>(
//                         builder: (controller) {
//                           return CustomDropdownField(
//                             hint: "Select User Type",
//                             borderColor: AppColors.grey,
//                             fillColor: AppColors.white,
//                             items: userTypes,
//                             selectedValue: controller.selectedUserType,
//                             onChanged: (value)async {
//                               controller.selectedUserType = value;
//                               await jobController.createJobCategoryAdmin(controller.selectedUserType!,'',context);
//                               jobController.update();
//                             },
//                           );
//                         }
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/job_category_model.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:get/get.dart';

class JobCategoryScreen extends StatefulWidget {
  const JobCategoryScreen({super.key});

  @override
  State<JobCategoryScreen> createState() => _JobCategoryScreenState();
}

class _JobCategoryScreenState extends State<JobCategoryScreen> {
  //final JobCategoryService service = JobCategoryService();
  List<JobCategoryModel> categories = [];
  final jobController = Get.put(JobController());
  final TextEditingController nameController = TextEditingController();

  final List<String> userTypes = const [
    "All",
    "Dental Clinic",
    "Dental Lab",
    "Dental Shop",
    "Dental Mechanic",
    "Dental Consultant"
  ];

  @override
  void initState() {
    super.initState();
    jobController.selectedUserType = "All";
    fetchCategories();
  }
  Future<void> fetchCategories() async {
    await jobController.getJobCategoryLists(
        jobController.selectedUserType == "All" ? "" : jobController
            .selectedUserType!, context);
    // await jobController.getJobCategoryLists("",context);
  }

  void addCategory() async {
    await jobController.createJobCategoryAdmin(
        jobController.selectedUserType!, nameController.text, context);
    nameController.clear();
    fetchCategories();
  }

  void openCategoryDialog({JobCategoryModel? model}) {
    if (model != null) {
      nameController.text = model.name;
      jobController.selectedUserType = model.userType;
    } else {
      nameController.clear();
      jobController.selectedUserType = null;
    }
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Center(
              child: Text(
                model != null ? "Update Category" : "Add Category",
                style: AppTextStyles.caption(
                    context, color: AppColors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GetBuilder<JobController>(
                    builder: (controller) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: CustomDropdownField(
                          hint: "Select User Type",
                          borderColor: AppColors.white,
                          fillColor: AppColors.white,
                          items: const [
                            "Dental Clinic",
                            "Dental Lab",
                            "Dental Shop",
                            "Dental Mechanic",
                            "Dental Consultant"
                          ],
                          selectedValue: controller.selectedUserType,
                          onChanged: (value) {
                            controller.selectedUserType = value;
                            controller.update();
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  CustomTextField(
                    hint: "Job Category",
                    icon: Icons.location_city,
                    controller: nameController,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (model != null) {
                    await jobController.updateJobCategoryAdmin(
                        model.id,
                        nameController.text,
                        jobController.isActive.toString(),
                        context);
                  } else {
                    // Add
                    await jobController.createJobCategoryAdmin(
                        jobController.selectedUserType!,
                        nameController.text,
                        context);
                  }
                  Navigator.pop(context);
                  fetchCategories();
                },
                child: Center(
                  child: Text(
                    model != null ? "Update" : "Add",
                    style: AppTextStyles.caption(
                        context, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
    );
  }
  void deleteCategory(String id) async {
    // await jobController.updateJobCategoryAdmin(model.id, nameController.text,jobController.isActive.toString(),context);
    fetchCategories();
  }
  Future<void> _refresh() async {
    fetchCategories();
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.white,
        title: Text('Add Job Category',
          style: AppTextStyles.subtitle(context, color: AppColors.black),),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: AppColors.black, size: size * 0.05),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<JobController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10,),
                    Text(
                      "Select User Type",
                      style: AppTextStyles.caption(
                        context,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10,),

                    // GetBuilder<JobController>(
                    //     builder: (controller) {
                    //       return CustomDropdownField(
                    //         hint: "Select User Type",
                    //         borderColor: AppColors.grey,
                    //         fillColor: AppColors.white,
                    //         items: userTypes,
                    //         selectedValue: controller.selectedUserType,
                    //         onChanged: (value) async {
                    //           controller.selectedUserType = value;
                    //           //await jobController.createJobCategoryAdmin(controller.selectedUserType=="All"?"":controller.selectedUserType!,nameController.text.toString(),context);
                    //           fetchCategories();
                    //           jobController.update();
                    //         },
                    //       );
                    //     }
                    // ),
                    GestureDetector(
                      child: _modernFilterBox(
                          icon: Icons.person_outline,
                          label: jobController.selectedUserType ?? "Select User Type",
                          onTap: _showUserTypeDialog
                        // optional styling for your modern box
                      ),
                    ),
                    const SizedBox(height: 10),

                    Center(
                      child: Container(
                        width: size * 0.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.transparent,shadowColor: AppColors.transparent
                          ),
                          onPressed: () {
                            openCategoryDialog();
                          },
                          child: Text("Add", style: AppTextStyles.caption(
                              context, color: AppColors.white,
                              fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child:  GetBuilder<JobController>(
                          builder: (controller) {
                            return ListView.builder(
                            itemCount: jobController.jobCategoryAdmin.length,
                            itemBuilder: (_, index) {
                              final item = jobController.jobCategoryAdmin[index];
                              return Card(
                                child: ListTile(
                                  title: Text(item.name, style: AppTextStyles.body(
                                      context, color: AppColors.black,
                                      fontWeight: FontWeight.bold),),
                                  subtitle: Text(item.userType,
                                      style: AppTextStyles.caption(
                                          context, color: AppColors.black,
                                          fontWeight: FontWeight.normal)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit, color: AppColors.primary,
                                          size: size * 0.06,),
                                        onPressed: () =>
                                            openCategoryDialog(model: item),
                                      ),
                                      IconButton(
                                          icon: Icon(
                                            Icons.delete, color: Colors.red,
                                            size: size * 0.06,),
                                          onPressed: () async {
                                            showDeleteDialog(
                                              context: context,
                                              title: "Delete Category",
                                              message: "This category will be permanently removed.",
                                              onConfirm: () async {
                                                print('itrm id${item.id}');
                                                await jobController
                                                    .deleteJobCategoryLists(
                                                    item.id, context);
                                                await fetchCategories();
                                                jobController.update();
                                              },
                                            );
                                          }
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      ),
                    )
                  ],
                ),
              ),
            );
          }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
  void _showUserTypeDialog() {
    final userTypes = [
      "All",
      "Dental Clinic",
      "Dental Lab",
      "Dental Shop",
      "Dental Mechanic",
      "Dental Consultant"
    ];

    String? tempSelected = jobController.selectedUserType;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title:  Text(
            "Select User Type",
            style: AppTextStyles.caption(fontWeight: FontWeight.bold,context),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: userTypes.map((type) {
                  return RadioListTile<String>(
                    value: type,
                    groupValue: tempSelected,
                    activeColor: AppColors.primary,
                    title: Text(type,style: AppTextStyles.caption(fontWeight: FontWeight.bold,context),),
                    onChanged: (value) {
                      tempSelected = value;
                      Navigator.pop(context);
                      jobController.selectedUserType = value;
                      jobController.getJobCategoryLists(
                        value == "All" ? "" : value!,
                        context,
                      );
                      jobController.update();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _modernFilterBox({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  label,
                  style: AppTextStyles.caption(context,fontWeight: FontWeight.bold)
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
  class ModernUserTypeSelector extends StatelessWidget {
  final List<String> userTypes;
  const ModernUserTypeSelector({super.key, required this.userTypes});

  @override
  Widget build(BuildContext context) {
  final jobController = Get.find<JobController>();
  return GestureDetector(
  onTap: () => _showUserTypePopup(context, jobController),
  child: Container(
 // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  decoration: BoxDecoration(
  color: AppColors.white,
  border: Border.all(color: AppColors.grey),
  borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  Obx(() => Text(
  jobController.selectedUserType ?? "Select User Type",
  style: const TextStyle(fontSize: 16),
  )),
  const Icon(Icons.arrow_drop_down),
  ],
  ),
  ),
  );
  }

  void _showUserTypePopup(BuildContext context, JobController controller) {
  showModalBottomSheet(
  context: context,
  shape: const RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  backgroundColor: Colors.white,
  builder: (_) {
  return SizedBox(
  height: 300,
  child: Column(
  children: [
  const Padding(
  padding: EdgeInsets.all(16.0),
  child: Text(
  "Select User Type",
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  ),
  const Divider(height: 1),
  Expanded(
  child: ListView.builder(
  itemCount: userTypes.length,
  itemBuilder: (context, index) {
  final type = userTypes[index];
  return ListTile(
  title: Text(type),
  onTap: () async {
  controller.selectedUserType = type;
  final jobController = Get.put(JobController());
  Future<void> fetchCategories() async {
    await jobController.getJobCategoryLists(jobController.selectedUserType == "All" ? "" :
    jobController.selectedUserType!, context);
    // await jobController.getJobCategoryLists("",context);
  }  controller.update();
  Navigator.pop(context);
  },
  );
  },
  ),
  ),
  ],
  ),
  );
  },
  );
  }
  }

