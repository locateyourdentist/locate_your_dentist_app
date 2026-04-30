import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/job_category_model.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class JobCategoryScreenWeb extends StatefulWidget {
  const JobCategoryScreenWeb({super.key});

  @override
  State<JobCategoryScreenWeb> createState() => _JobCategoryScreenWebState();
}

class _JobCategoryScreenWebState extends State<JobCategoryScreenWeb> {

  final JobController jobController = Get.put(JobController());
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
        jobController.selectedUserType == "All"
            ? ""
            : jobController.selectedUserType!,
        context);
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
      builder: (_) {
        double s=MediaQuery.of(context).size.width;
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          child: Container(
            width:s*0.14 ,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Center(
                  child: Text(
                    model != null
                        ? "Update Category"
                        : "Add Category",
                    style: AppTextStyles.caption(
                      context,fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Text("Select User Type",style: AppTextStyles.caption(context,),),
                const SizedBox(height: 10),
                GetBuilder<JobController>(
                    builder: (controller) {
                      return CustomDropdownField(
                      hint: " ",
                      fillColor: Colors.grey[100],
                      borderColor: AppColors.grey,
                      //items:userTypes.map((e) => e!='All').toList(),
                        items: userTypes.where((e) => e != "All").toList(),
                        selectedValue: controller.selectedUserType,
                      onChanged: (value) {
                        controller.selectedUserType = value;
                        controller.update();
                      },
                    );
                  }
                ),
                const SizedBox(height: 15),
                Text("Enter Job Category",style: AppTextStyles.caption(context,fontWeight: FontWeight.normal),),
                const SizedBox(height: 10),

                CustomTextField(
                  hint: " ",
                  icon: Icons.work,
                  controller: nameController,
                  fillColor: Colors.grey[100],
                  borderColor: AppColors.grey,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {

                      if (model != null) {
                        await jobController.updateJobCategoryAdmin(
                            model.id,
                            nameController.text,
                            jobController.isActive.toString(),
                            context);
                      } else {
                        await jobController.createJobCategoryAdmin(
                            jobController.selectedUserType!,
                            nameController.text,
                            context);
                      }

                      Navigator.pop(context);
                      fetchCategories();
                    },
                    child: Text(model != null ? "Update" : "Add",style: AppTextStyles.caption(context,color: AppColors.white),),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
  void _showUserTypeDialog() {
    String? tempSelected = jobController.selectedUserType;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:  Center(child: Text("Select User Type",style: AppTextStyles.body(context,fontWeight: FontWeight.bold),)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: userTypes.map((type) {

                return RadioListTile<String>(
                  value: type,
                  groupValue: tempSelected,
                  title: Text(type,style: AppTextStyles.caption(context),),
                  onChanged: (value) async {

                    tempSelected = value;

                    Navigator.pop(context);

                    jobController.selectedUserType = value;

                    await jobController.getJobCategoryLists(
                        value == "All" ? "" : value!,
                        context);

                    jobController.update();
                  },
                );
              }).toList(),
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
        padding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [

            Icon(icon, color: AppColors.primary),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption(
                  context,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Icon(Icons.keyboard_arrow_down)
          ],
        ),
      ),
    );
  }
  Widget _categoryTable() {
    final size = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text("S.No", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text("Category", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text("User Type", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text("Actions", style: AppTextStyles.caption(context, color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: jobController.jobCategoryAdmin.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = jobController.jobCategoryAdmin[index];
              final isEven = index % 2 == 0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isEven ? Colors.grey[100] : Colors.white,
                    borderRadius: index == jobController.jobCategoryAdmin.length - 1
                        ? const BorderRadius.vertical(bottom: Radius.circular(12))
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),

                  child: Row(
                    children: [

                      Expanded(
                        flex: 1,
                        child: Text("${index + 1}",
                            style: AppTextStyles.caption(context)),
                      ),

                      Expanded(
                        flex: 3,
                        child: Text(item.name,
                            style: AppTextStyles.caption(context)),
                      ),

                      Expanded(
                        flex: 3,
                        child: Text(item.userType,
                            style: AppTextStyles.caption(context)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [

                            IconButton(
                              icon: Icon(Icons.edit,
                                  size: size * 0.012,
                                  color: AppColors.primary),
                              onPressed: () {
                                openCategoryDialog(model: item);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  size: size * 0.012,
                                  color: Colors.red),
                              onPressed: () async {
                                showDeleteDialog(
                                  context: context,
                                  title: "Delete Category",
                                  message:
                                  "This category will be permanently removed.",
                                  onConfirm: () async {
                                    await jobController
                                        .deleteJobCategoryLists(item.id, context);

                                    fetchCategories();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  @override
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
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Text(
                                "Job Categories",
                                style: AppTextStyles.subtitle(
                                  context,
                                ),
                              ),

                              const SizedBox(height: 25),

                              Row(
                                children: [

                                  Expanded(
                                    child: _modernFilterBox(
                                      icon: Icons.person_outline,
                                      label: jobController.selectedUserType ??
                                          "Select User Type",
                                      onTap: _showUserTypeDialog,
                                    ),
                                  ),

                                  const SizedBox(width: 15),

                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.transparent,shadowColor: AppColors.transparent,elevation: 16),
                                    icon:  Icon(Icons.add,size: s*0.012,color:AppColors.black,),
                                    label:
                                     Text("Add Category",style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                                    onPressed: () {
                                      openCategoryDialog();
                                    },
                                  )
                                ],
                              ),

                              const SizedBox(height: 25),

                              Expanded(
                                child: _categoryTable(),
                              ),
                            ],
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