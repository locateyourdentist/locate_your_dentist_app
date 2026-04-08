import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../common_widgets/color_code.dart';
import '../common_widgets/common_textstyles.dart';
import '../modules/auth/login_screen/login_controller.dart';
import '../modules/dashboard/jobController.dart';
import '../api/api.dart';



class FilterDrawer extends StatefulWidget {
  final VoidCallback onApply;
  final VoidCallback onReset;
  //final ScrollController scrollController;
  const FilterDrawer({
    super.key,
    required this.onApply,
    required this.onReset,
   // required this.scrollController,
  });
  @override
  State<FilterDrawer> createState() => _FilterDrawerContentState();
}
class _FilterDrawerContentState extends State<FilterDrawer> {
  final loginController = Get.put(LoginController());
  final jobController = Get.put(JobController());

  @override
  void initState() {
    super.initState();
    loginController.selectedArea = null;
    loginController.selectedUserType=null;
    loginController.selectedDistrict=null;
    loginController.selectedCategories.clear();
    loginController.fetchStates();
    jobController.getJobCategoryLists("", context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GetBuilder<LoginController>(
        builder: (controller) {
          return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          //  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, -5))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                // Center(
                //   child: Container(
                //     width: 60,
                //     height: 5,
                //     decoration: BoxDecoration(
                //       color: Colors.grey[300],
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 15),

                Center(
                  child: Text(
                    '🔍 Filter Jobs',
                    style: AppTextStyles.caption(context,
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 25),
                _sectionTitle("Distance"),
                _selectableHorizontal(
                  options: ["5 Km", "10 Km", "15 Km", "20 Km"],
                  selectedValue: loginController.selectedDistance,
                  onSelect: (val) => setState(() => loginController.selectedDistance = val),
                ),
                const SizedBox(height: 20),

                _sectionTitle("Select Location"),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                 children: [
                Expanded(child: _stateDropdown(width)),
                const SizedBox(width: 20),
                Expanded(child: _districtDropdown()),
               ],),
                const SizedBox(height: 20),

                _talukaDropdown(),
                const SizedBox(height: 20),

                if ((Api.userInfo.read('userType') == 'Job Seekers') ||(Api.userInfo.read('userType') == null))...[
                  _sectionTitle("Job Categories"),
                  _jobCategoriesMultiSelect(),
                  const SizedBox(height: 20),
                  _sectionTitle("Job Type"),
                  _selectableHorizontal(
                    options: ["Full Time", "Part Time", "Remote"],
                    selectedValue: loginController.selectedJobType,
                    onSelect: (val) => setState(() => loginController.selectedJobType = val),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle("Salary"),
                  _selectableHorizontal(
                    options: [
                      "8k-10k",
                      "10k-20k",
                      "20k-30k",
                      "30k-40k",
                      "40k-50k",
                      "50k-75k",
                      "75k-1L",
                      "Above 1L",
                      "Negotiable"
                    ],
                    selectedValue: loginController.selectedSalary,
                    onSelect: (val) => setState(() => loginController.selectedSalary = val),
                  ),
                  const SizedBox(height: 25),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: width*0.15,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: widget.onApply,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.transparent,shadowColor: AppColors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text("Apply",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        width: width*0.15,
                        child: ElevatedButton(
                          onPressed: widget.onReset,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text("Reset",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(
      title,
      style: AppTextStyles.caption(context,
          color: AppColors.black, fontWeight: FontWeight.bold),
    ),
  );

  Widget _selectableHorizontal({
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelect,
  }) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = selectedValue == option;

          return GestureDetector(
            onTap: () => onSelect(option),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _stateDropdown(double width) {
    return GetBuilder<LoginController>(
      builder: (controller) {
        return SizedBox(
          height: 55,
          child: CustomDropdown<String>.search(
            hintText: "Select State",
            //items: loginController.states.map((s) => s['name'].toString()).toList(),
            items: loginController.states.map((s) => s.toString()).toList(),
            //initialItem: loginController.selectedState,
            onChanged: (val) {
              loginController.selectedState = val;
              loginController.districts.clear();
              loginController.talukas.clear();
              loginController.villages.clear();
              loginController.selectedDistrict = null;
              loginController.selectedTaluka = null;
              loginController.selectedVillage = null;

              if (val != null) {
                final state = loginController.states.firstWhere((s) => s == val);
                //loginController.fetchDistricts(state['code'].toString());
                loginController.fetchDistricts(state.toString());
                loginController.update();
              }
            },
            decoration: CustomDropdownDecoration(
              closedBorder: Border.all(color: Colors.grey.shade300, width: 1),
              closedBorderRadius: BorderRadius.circular(12),
              expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
              expandedBorderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _districtDropdown() {
    return GetBuilder<LoginController>(
      builder: (controller) {
        return CustomDropdown<String>.search(
          hintText: "Select District",
          items: loginController.districts.map((d) => d.toString()).toList(),
          //initialItem: loginController.selectedDistrict,
          onChanged: (val) {
            loginController.selectedDistrict = val;
            loginController.talukas.clear();
            loginController.villages.clear();
            loginController.selectedTaluka = null;
            loginController.selectedVillage = null;
            if (val != null) {
              final district = loginController.districts.firstWhere((d) => d == val);
             // loginController.fetchTalukas(district['code'].toString());
              loginController.fetchTalukas(district.toString());
              loginController.update();
            }
          },
          decoration: CustomDropdownDecoration(
            closedBorder: Border.all(color: Colors.grey.shade300, width: 1),
            closedBorderRadius: BorderRadius.circular(12),
            expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
            expandedBorderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
  Widget _talukaDropdown() {
    return GetBuilder<LoginController>(
      builder: (controller) {
        return CustomDropdown<String>.search(
          hintText: "Select Taluka/Town",
          items: loginController.talukas.map((t) => t.toString()).toList(),
          //initialItem: loginController.selectedTaluka,
          onChanged: (val) {
            loginController.selectedTaluka = val;
            if (val != null) {
              final taluka = loginController.talukas.firstWhere((t) => t == val);
              //loginController.fetchVillages(taluka['code'].toString());
              loginController.fetchVillages(taluka.toString());
              loginController.update();
            }
          },
          decoration: CustomDropdownDecoration(
            closedBorder: Border.all(color: Colors.grey.shade300, width: 1),
            closedBorderRadius: BorderRadius.circular(12),
            expandedBorder: Border.all(color: AppColors.primary, width: 1.5),
            expandedBorderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
  Widget _jobCategoriesMultiSelect() {
    return GetBuilder<JobController>(
      builder: (jobController) {
        final List<MultiSelectItem<String>> categoryItems = jobController.jobCategoryAdmin
            .map((e) => MultiSelectItem<String>(e.name.trim(), e.name.trim()))
            .toList();
        return MultiSelectDialogField<String>(
          dialogWidth: MediaQuery.of(context).size.width * 0.25,
          dialogHeight: MediaQuery.of(context).size.height * 0.6,
          items: categoryItems,
          selectedColor: AppColors.primary,
          initialValue: loginController.selectedCategories,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          buttonText: Text(
            "Select Job Categories",
            style: AppTextStyles.caption(context, color: Colors.grey),
          ),
          onConfirm: (results) {
            loginController.selectedCategories = results;
            loginController.update();
          },
        );
      },
    );
  }
}