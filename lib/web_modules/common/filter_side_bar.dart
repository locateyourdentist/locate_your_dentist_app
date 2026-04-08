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
  final TextEditingController searchController=TextEditingController();
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
                  color: AppColors.white,borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey,width: 0.3)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),

                  Padding(
                    padding:  EdgeInsets.all(10.0),
                    child: Column(
                     // padding: const EdgeInsets.all(16),
                      children: [
                        _sectionTitle("Distance"),
                        // _checkboxList(
                        //   ["5 Km", "10 Km", "15 Km", "20 Km"],
                        //   loginController.selectedDistance,
                        //       (val) => setState(() {
                        //     loginController.selectedDistance = val;
                        //   }),
                        // ),
                        // Text("Select Distance"),
                        Slider(
                          value: loginController.selectedDistance1,
                          min: 0,
                          max: 30,
                          divisions: 3,
                          label: "${loginController.selectedDistance1.round()} Km",
                          onChanged: (double value) {
                            setState(() {
                              loginController.selectedDistance1 = value;
                              loginController.selectedDistance1 = value.toDouble();
                            });
                          },
                        ),
                        Text("${loginController.selectedDistance1.round()} Km",style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                        const Divider(),

                        _sectionTitle("Location"),
                        _dropdown("State", loginController.states,
                                (val) {
                              loginController.selectedState = val;
                              loginController.fetchDistricts(val);
                              loginController.update();
                            }),
                        const SizedBox(height: 10),

                        _dropdown("District", loginController.districts,
                                (val) {
                              loginController.selectedDistrict = val;
                              loginController.fetchTalukas(val);
                              loginController.update();
                            }),
                        const SizedBox(height: 10),

                        _dropdown("Taluka", loginController.talukas,
                                (val) {
                              loginController.selectedTaluka = val;
                              loginController.update();
                            }),

                      //  const Divider(),
                        if(Api.userInfo.read('token')==null||Api.userInfo.read('token')=='Job Seekers')
                         Column(
                           mainAxisAlignment: MainAxisAlignment.start,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                       // _sectionTitle("Job Categories"),
                        _multiCheckbox(),

                        const Divider(),

                        _sectionTitle("Job Type"),
                        _checkboxList(
                          ["Full Time", "Part Time", "Remote"],
                          loginController.selectedJobType,
                              (val) => setState(() {
                            loginController.selectedJobType = val;
                          }),
                        ),

                        const Divider(),

                        _sectionTitle("Select Salary(Per Month)",),
                        // _checkboxList(
                        //   [ "8,000 - 10,000",
                        //     "10,000 - 15,000",
                        //     "15,000 - 20,000",
                        //     "20,000 - 25,000",
                        //     "25,000 - 30,000",
                        //     "30,000 - 35,000",
                        //     "35,000 - 40,000",
                        //     "40,000 - 45,000",
                        //     "45,000 - 50,000",
                        //     "50,000 - 60,000",
                        //     "60,000 - 60,000",
                        //     "70,000 - 80,000",
                        //     "Above 1,00,000",
                        //     "Negotiable"],
                        //   loginController.selectedSalary,
                        //       (val) => setState(() {
                        //     loginController.selectedSalary = val;
                        //   }),
                       // ),
                             ExpansionTile(
                               title: Text("Select Salary Range"),
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
                                     "60,000 - 70,000", // fixed typo
                                     "70,000 - 80,000",
                                     "Above 1,00,000",
                                     "Negotiable",
                                   ],
                                   loginController.selectedSalary,
                                       (val) => setState(() {
                                     loginController.selectedSalary = val;
                                   }),
                                 ),
                               ],
                             ),
                             ])
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
      padding:  EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child:  Center(
        child: Text(
          "Filters",
          style: AppTextStyles.body(context,color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  /// CHECKBOX LIST
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
          title: Text(e,style: AppTextStyles.caption(context),),
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
  Widget _multiCheckbox() {
    return GetBuilder<JobController>(
      builder: (jobController) {
        return ExpansionTile(
          title: Text("Job Categories",style: AppTextStyles.caption(context),),
          children: [
            Column(
              children: jobController.jobCategoryAdmin.map((e) {
                final name = e.name;
                final selected =
                loginController.selectedCategories.contains(name);
            
                return CheckboxListTile(
                  value: selected,
                    selectedTileColor:AppColors.primary,
                  onChanged: (val) {
                    if (val == true) {
                      loginController.selectedCategories.add(name);
                    } else {
                      loginController.selectedCategories.remove(name);
                    }
                    loginController.update();
                  },
                  title: Text(name,style: AppTextStyles.caption(context),),
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _dropdown(
      String hint,
      List list,
      Function(String) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      hint: Text(hint,style: AppTextStyles.caption(context,color: AppColors.grey),),
      items: list
          .map((e) => DropdownMenuItem(
        value: e.toString(),
        child: Text(e.toString(),style: AppTextStyles.caption(context,color: AppColors.black),),
      ))
          .toList(),
      onChanged: (val) => onChanged(val!),
    );
  }


  Widget _bottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async{
                await jobController.getJobListJobSeekers(
                  search: "",
                  //searchController.text.isNotEmpty?searchController.text:"",
                  state: loginController.selectedState,
                  district: loginController.selectedDistrict,
                  city: loginController.selectedTaluka,
                  salary: loginController.selectedSalary,
                  jobType: loginController.selectedJobType,
                  jobCategory: loginController.selectedCategories,
                  context: context,
                );
//Get.toNamed('/jobListJobSeekersWebPage');
                Api.userInfo.read('userType')!='superAdmin'?
                await loginController.getProfileDetails(
                  "",
                  loginController.selectedState,
                  loginController.selectedDistrict,
                  loginController.selectedTaluka,"true",'','',loginController.selectedDistance1.toString(),searchController.text.toString(),
                  context,
                ) :await loginController.getProfileDetails(
                  "",
                  loginController.selectedState,
                  loginController.selectedDistrict,
                  loginController.selectedTaluka,"",'','',loginController.selectedDistance1.toString(),searchController.text.toString(),
                  context,
                );
},
              child:  Text("Apply",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white),),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                loginController.selectedCategories.clear();
                loginController.selectedArea = null;
                loginController.selectedUserType = null;
                loginController.selectedState = null;
                loginController.selectedDistrict = null;
                loginController.selectedDistance = null;
                loginController.selectedTaluka = null;
                loginController.selectedJobType = null;
                loginController.selectedSalary = null;
                loginController.selectedDistance1=0;
                loginController.update();
              },
              child:  Text("Reset",style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
            ),
          ),
        ],
      ),
    );
  }
}