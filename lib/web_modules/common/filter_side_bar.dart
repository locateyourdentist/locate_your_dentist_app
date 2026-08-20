import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

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

                        _sectionTitle("User Type"),

                        _dropdown(
                          "User Type",
                          const [
                            "Dental Clinic",
                            "Dental Lab",
                            "Dental Shop",
                            "Dental Mechanic",
                            "Dental Consultant",
                            "Job Seekers",
                          ],
                          loginController.filterUserType,
                              (val) {
                            loginController.filterUserType = val;
                            if (val != 'Dental Consultant') {
                              loginController.filterSelectedDegree = null;
                              loginController.filterSelectedAvailableLocations = [];
                              loginController.filterSelectedTimingSlots = [];
                            }
                            loginController.update();
                          },
                        ),

                        if (loginController.filterUserType == 'Dental Consultant') ...[
                          const Divider(),
                          _sectionTitle("Degree"),
                          _dropdown(
                            "Degree",
                            loginController.degreeList,
                            loginController.filterSelectedDegree,
                                (val) {
                              loginController.filterSelectedDegree = val;
                              loginController.update();
                            },
                          ),
                          const SizedBox(height: 10),
                          _sectionTitle("Available Timing"),
                          Wrap(
                            spacing: 8,
                            children: ["Morning", "Evening"].map((slot) {
                              final selected = loginController.filterSelectedTimingSlots.contains(slot);
                              return FilterChip(
                                label: Text(slot, style: AppTextStyles.caption(context)),
                                selected: selected,
                                onSelected: (val) {
                                  if (val) {
                                    loginController.filterSelectedTimingSlots.add(slot);
                                  } else {
                                    loginController.filterSelectedTimingSlots.remove(slot);
                                  }
                                  loginController.update();
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          _sectionTitle("Available Location"),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: loginController.filterAvailableLocationController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: "Add a location",
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (_) => loginController.addFilterAvailableLocation(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                                onPressed: () => loginController.addFilterAvailableLocation(),
                              ),
                            ],
                          ),
                          if (loginController.filterSelectedAvailableLocations.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: loginController.filterSelectedAvailableLocations.map((loc) {
                                return Chip(
                                  label: Text(loc, style: AppTextStyles.caption(context)),
                                  onDeleted: () => loginController.removeFilterAvailableLocation(loc),
                                );
                              }).toList(),
                            ),
                        ],

                        const Divider(),

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

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.grey,
                          width: 1,
                        ),
                      ),
                      child: MultiSelectDialogField<String>(
                            checkColor: AppColors.primary,
                            buttonIcon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.white,
                              size: 2,),
                            items: loginController.districts
                                .toSet()
                                .map(
                                  (e) => MultiSelectItem<String>(
                                e.toString(),
                                e.toString(),
                              ),
                            ).toList(),
                            title: Center(
                              child: Text(
                                "Select districts",
                                style: AppTextStyles.body(context),
                              ),),
                            buttonText: Text(
                              loginController.selectedDistricts.isEmpty
                                  ? "District"
                                  : loginController.selectedDistricts.length == 1
                                  ? loginController.selectedDistricts.first
                                  : "${loginController.selectedDistricts.first} +${loginController.selectedDistricts.length - 1}",
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption(context,color: AppColors.black),
                            ),
                            decoration: const BoxDecoration(),
                            searchable: true,
                            dialogHeight: 400,
                            dialogWidth:120,
                            initialValue: loginController.selectedDistricts,
                            onConfirm: (values)async {
                              loginController.selectedDistricts = values.map((e) => e.toString()).toList();
                              await  loginController.fetchTalukas(loginController.selectedDistricts);
                              loginController.update();
                            },
                            chipDisplay: MultiSelectChipDisplay.none(),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.grey,
                              width: 1,
                            ),
                          ),
                          child: MultiSelectDialogField<String>(
                            checkColor: AppColors.primary,
                            buttonIcon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.white,
                              size: 2,),
                            items: loginController.talukas
                                .toSet()
                                .map(
                                  (e) => MultiSelectItem<String>(
                                e.toString(),
                                e.toString(),
                              ),
                            ).toList(),
                            title: Center(
                              child: Text(
                                "Select Taluka",
                                style: AppTextStyles.body(context),
                              ),),
                            buttonText: Text(
                              loginController.selectedTalukas.isEmpty
                                  ? "Taluka"
                                  : loginController.selectedTalukas.length == 1
                                  ? loginController.selectedTalukas.first
                                  : "${loginController.selectedTalukas.first} +${loginController.selectedTalukas.length - 1}",
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption(context,color: AppColors.black),
                            ),
                            decoration: const BoxDecoration(),
                            searchable: true,
                            dialogHeight: 400,
                            dialogWidth:120,
                            initialValue: loginController.selectedTalukas,
                            onConfirm: (values) async{
                              loginController.selectedTalukas = values.map((e) => e.toString()).toList();
                              await loginController.fetchVillages(loginController.selectedTalukas);
                              loginController.update();
                            },
                            chipDisplay: MultiSelectChipDisplay.none(),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.grey,
                              width: 1,
                            ),
                          ),
                          child: MultiSelectDialogField<String>(
                            checkColor: AppColors.primary,
                            buttonIcon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.white,
                              size: 2,
                            ),
                            items: loginController.villages
                                .toSet().map((e) => MultiSelectItem<String>(
                                e.toString(),
                                e.toString(),
                              ),
                            ).toList(),
                            title: Center(
                              child: Text(
                                "Select Areas", style: AppTextStyles.body(context),),
                            ),

                            buttonText: Text(
                              loginController.selectedVillages.isEmpty
                                  ? "Areas"
                                  : loginController.selectedVillages.length == 1
                                  ? loginController.selectedVillages.first
                                  : "${loginController.selectedVillages.first} +${loginController.selectedVillages.length - 1}",
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption(context),
                            ),
                            decoration: const BoxDecoration(),
                            searchable: true,
                            dialogHeight: 400,
                            dialogWidth:120,
                            initialValue: loginController.selectedVillages,

                            onConfirm: (values) {
                              loginController.selectedVillages = values.map((e) => e.toString()).toList();
                              loginController.update();
                            },
                            chipDisplay: MultiSelectChipDisplay.none(),
                          ),
                        ),
                        const Divider(),
                        if (Api.userInfo.read('userType') == 'Job Seekers')
                        // if (token == null ||
                        //     token.toString().isEmpty ||
                        //     Api.userInfo.read('userType') == 'Job Seekers')
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
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style:  AppTextStyles.caption(context,fontWeight: FontWeight.bold)),
    );
  }
  Future<void> getLocation() async {
    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      loginController.latitude = position.latitude;
      loginController.longitude = position.longitude;
      print('latitude ${loginController.latitude}');
      print('longitude ${loginController.longitude}');

    } else {
      Get.snackbar('Location', 'Unable to get location');
    }
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
              title: Text(name,style: AppTextStyles.caption(context),),
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
            : null,

        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(),
        ),
        hint: Text(hint,style: AppTextStyles.caption(context),),

        items: uniqueList.map((e) {
          return DropdownMenuItem<String>(
            value: e,
            child: Text(e,style: AppTextStyles.caption(context),),
          );
        }).toList(),

        onChanged: onChanged,
      ),
    );
  }
  Widget _bottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
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
                String userType=  Api.userInfo.read('sUserType')??"";
                String distance = loginController.selectedDistance1.toString() ?? "0";
                if (distance != "0") {
                  await getLocation();
                } else {
                  loginController.latitude = null;
                  loginController.longitude = null;
                }

                String safeLat =
                (distance != "0" && loginController.latitude != null)
                    ? loginController.latitude.toString()
                    : "";

                String safeLng =
                (distance != "0" && loginController.longitude != null)
                    ? loginController.longitude.toString()
                    : "";
                final filterDegree = loginController.filterUserType == 'Dental Consultant'
                    ? loginController.filterSelectedDegree
                    : null;
                final filterLocations = loginController.filterUserType == 'Dental Consultant'
                    ? loginController.filterSelectedAvailableLocations
                    : null;
                final filterTiming = loginController.filterUserType == 'Dental Consultant'
                    ? loginController.filterSelectedTimingSlots
                    : null;

                if( Api.userInfo.read('userType')=="superAdmin") {
                  await   loginController.getProfileDetails(loginController.filterUserType ?? '',  loginController.selectedState,
                      loginController.selectedDistricts,
                      loginController.selectedTalukas, loginController.selectedVillages,'',safeLat,safeLng, distance,searchController.text.toString(),  context,
                      degreeName: filterDegree, availableLocations: filterLocations, availableTiming: filterTiming);
                }
                else if( Api.userInfo.read('userType')=="admin") {
                  await loginController.getProfileDetails(loginController.filterUserType ?? '', Api.userInfo.read('state') ?? "", loginController.selectedDistricts,
                      loginController.selectedTalukas,  loginController.selectedVillages,'',safeLat,safeLng, distance,searchController.text.toString(), context,
                      degreeName: filterDegree, availableLocations: filterLocations, availableTiming: filterTiming);
                }
                else{
                  await  loginController.getProfileDetails(
                    loginController.filterUserType ?? userType,
                    loginController.selectedState,
                    loginController.selectedDistricts,
                    loginController.selectedTalukas,loginController.selectedVillages,'true',safeLat,safeLng, distance, searchController.text.toString(),
                    context,
                    degreeName: filterDegree, availableLocations: filterLocations, availableTiming: filterTiming,
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
                loginController.selectedDistricts.clear();
                loginController.selectedDistance1 = 0.0;
                loginController.latitude = null;
                loginController.longitude = null;
                  loginController.selectedVillages.clear();
                loginController.resetUserTypeFilters();
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