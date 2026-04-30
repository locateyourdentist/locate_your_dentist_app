import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';

class FilterSidebar extends StatefulWidget {
  const FilterSidebar({super.key});

  @override
  State<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends State<FilterSidebar> {
  final loginController = Get.put(LoginController());
  final jobController = Get.put(JobController());

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loginController.fetchStates();
    jobController.getJobCategoryLists("", context);
  }

  @override
  Widget build(BuildContext context) {
    final token = Api.userInfo.read('token');

    return GetBuilder<LoginController>(
      builder: (controller) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.grey, width: 0.3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [

                        // ================= DISTANCE =================
                        _sectionTitle("Distance"),

                        Slider(
                          value: loginController.selectedDistance1 ?? 0.0,
                          min: 0,
                          max: 30,
                          divisions: 6,
                          label: "${(loginController.selectedDistance1 ?? 0).round()} Km",
                          onChanged: (value) {
                            loginController.selectedDistance1 = value;
                            loginController.update();
                          },
                        ),

                        Text(
                          "${(loginController.selectedDistance1 ?? 0).round()} Km",
                          style: AppTextStyles.caption(
                            context,
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Divider(),

                        _sectionTitle("Location"),

                        _dropdown(
                          "State",
                          loginController.states.map((e) => e.toString()).toList(),
                          loginController.selectedState,
                              (val) {
                            loginController.selectedState = val;
                            loginController.fetchDistricts(val ?? "");
                            loginController.update();
                          },
                        ),

                        const SizedBox(height: 10),

                        _dropdown(
                          "District",
                          loginController.districts.map((e) => e.toString()).toList(),
                          loginController.selectedDistrict,
                              (val) {
                            loginController.selectedDistrict = val;
                            loginController.fetchTalukas(val ?? "");
                            loginController.selectedTaluka = null;
                            loginController.update();
                          },
                        ),
                        const SizedBox(height: 10),

                        _dropdown(
                          "Taluka",
                          loginController.talukas.map((e) => e.toString()).toList(),
                          loginController.selectedTaluka,
                              (val) {
                            loginController.selectedTaluka = val;
                            loginController.update();
                          },
                        ),

                        const Divider(),

                        if (token == null ||
                            token.toString().isEmpty ||
                            Api.userInfo.read('userType') == 'Job Seekers')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _multiCheckbox(),

                              const Divider(),

                              _sectionTitle("Job Type"),
                              _checkboxList(
                                ["Full Time", "Part Time", "Remote"],
                                loginController.selectedJobType,
                                    (val) {
                                  loginController.selectedJobType = val;
                                  loginController.update();
                                },
                              ),

                              const Divider(),

                              _sectionTitle("Salary"),
                              ExpansionTile(
                                title: const Text("Select Salary Range"),
                                children: [
                                  _checkboxList(
                                    [
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
                                      "60,000 - 70,000",
                                      "70,000 - 80,000",
                                      "Above 1,00,000",
                                      "Negotiable",
                                    ],
                                    loginController.selectedSalary,
                                        (val) {
                                      loginController.selectedSalary = val;
                                      loginController.update();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  _bottomButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        "Filters",
        style: AppTextStyles.body(
          context,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _checkboxList(
      List<String> options,
      String? selected,
      Function(String) onChanged,
      ) {
    return Column(
      children: options.map((e) {
        return CheckboxListTile(
          value: selected == e,
          onChanged: (_) => onChanged(e),
          title: Text(e, style: AppTextStyles.caption(context)),
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _multiCheckbox() {
    return GetBuilder<JobController>(
      builder: (jobController) {
        return ExpansionTile(
          title: Text(
            "Job Categories",
            style: AppTextStyles.caption(context),
          ),
          children: jobController.jobCategoryAdmin.map((e) {
            final name = e.name;
            final selected =
            loginController.selectedCategories.contains(name);

            return CheckboxListTile(
              value: selected,
              onChanged: (val) {
                if (val == true) {
                  loginController.selectedCategories.add(name);
                } else {
                  loginController.selectedCategories.remove(name);
                }
                loginController.update();
              },
              title: Text(name),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _dropdown(
      String hint,
      List<String> list,
      String? selectedValue,
      Function(String?) onChanged,
      ) {
    final uniqueList = list.toSet().toList();

    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: (selectedValue != null && uniqueList.contains(selectedValue))
            ? selectedValue
            : null, // 👈 THIS MAKES RESET WORK

        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(),
        ),
        hint: Text(hint),

        items: uniqueList.map((e) {
          return DropdownMenuItem<String>(
            value: e,
            child: Text(e),
          );
        }).toList(),

        onChanged: onChanged,
      ),
    );
  }
  Widget _bottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [

          // APPLY
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () async {
                await jobController.getJobListJobSeekers(
                  search: "",
                  state: loginController.selectedState,
                  district: loginController.selectedDistrict,
                  city: loginController.selectedTaluka,
                  salary: loginController.selectedSalary,
                  jobType: loginController.selectedJobType,
                  jobCategory: loginController.selectedCategories,
                  context: context,
                );
                String userType=  Api.userInfo.read('sUserType');

                if( Api.userInfo.read('userType')=="superAdmin") {
                  await   loginController.getProfileDetails('',  loginController.selectedState,
                      loginController.selectedDistrict,
                      loginController.selectedTaluka, '',loginController.latitude.toString(),loginController.longitude.toString(),loginController.selectedDistance.toString(),searchController.text.toString(),  context);
                }
                else if( Api.userInfo.read('userType')=="admin") {
                  await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", loginController.selectedDistrict,
                      loginController.selectedTaluka, '',loginController.latitude.toString(),loginController.longitude.toString(),loginController.selectedDistance.toString(),searchController.text.toString(), context);
                }
                else{
                  await  loginController.getProfileDetails(
                    userType,
                    loginController.selectedState,
                    loginController.selectedDistrict,
                    loginController.selectedTaluka,'true',loginController.latitude.toString(),loginController.longitude.toString(), loginController.selectedDistance.toString(), searchController.text.toString(),
                    context,
                  );
                }
              },
              child: Text(
                "Apply",
                style: AppTextStyles.caption(
                  context,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // RESET
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                loginController.selectedCategories.clear();
                loginController.selectedState = null;
                loginController.selectedDistrict = null;
                loginController.selectedTaluka = null;
                loginController.selectedJobType = null;
                loginController.selectedSalary = null;

                loginController.selectedDistance1 = 0.0;
                loginController.latitude = null;
                loginController.longitude = null;

                loginController.update();
              },
              child: Text(
                "Reset",
                style: AppTextStyles.caption(
                  context,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}