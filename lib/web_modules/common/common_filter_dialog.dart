import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import '../../common_widgets/color_code.dart';


class FilterDialogContent extends StatefulWidget {
  final VoidCallback onApply;
  final VoidCallback onReset;

  const FilterDialogContent({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterDialogContent> createState() => _FilterDialogContentState();
}

class _FilterDialogContentState extends State<FilterDialogContent> {
  final loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    loginController.fetchStates();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filter Jobs",
                    style: AppTextStyles.subtitle(
                      context,
                      color: AppColors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              const Divider(),
              const SizedBox(height: 10),

              /// BODY
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// Distance
                        _sectionTitle("Distance"),

                        Wrap(
                          spacing: 10,
                          children: ["5 Km", "10 Km", "15 Km", "20 Km"]
                              .map((e) => _distanceChip(e))
                              .toList(),
                        ),

                        const SizedBox(height: 20),


                        _sectionTitle("State"),

                        GetBuilder<LoginController>(
                            builder: (controller) {
                              return DropdownButtonFormField<String>(
                              value: loginController.selectedState,
                              items: loginController.states
                                  .map<DropdownMenuItem<String>>(
                                    (s) => DropdownMenuItem(
                                  value: s.toString(),
                                  child: Text(s.toString()),
                                ),
                              )
                                  .toList(),
                              onChanged: (val) {
                                loginController.selectedState = val;
                                loginController.districts.clear();
                                loginController.selectedDistrict = null;
                                loginController.selectedTaluka = null;
                                loginController.selectedVillage = null;
                                final state = controller.states.firstWhere((s) => s == val);
                                print('state  selected$state');
                                controller.fetchDistricts(state.toString());
                                loginController.update();
                              },
                              decoration: _dropdownDecoration(),
                            );
                          }
                        ),

                        const SizedBox(height: 20),

                        /// DISTRICT
                        _sectionTitle("District"),

                        GetBuilder<LoginController>(
                            builder: (controller) {
                              return DropdownButtonFormField<String>(
                              value: loginController.selectedDistrict,
                              items: loginController.districts
                                  .map<DropdownMenuItem<String>>(
                                    (d) => DropdownMenuItem(
                                  value: d.toString(),
                                  child: Text(d.toString(),style: AppTextStyles.caption(context),),
                                ),
                              )
                                  .toList(),
                              onChanged: (val) {
                                loginController.selectedDistrict = val;
                                print('hghdist${loginController.selectedDistrict}');
                                loginController.talukas.clear();
                                loginController.selectedTaluka = null;
                                loginController.selectedVillage = null;
                                final districts = controller.districts.firstWhere((s) => s == val);
                                print('state  selected$districts');
                                controller.fetchTalukas(districts.toString());
                                loginController.update();
                              },
                              decoration: _dropdownDecoration(),
                            );
                          }
                        ),

                        const SizedBox(height: 20),

                        /// TALUKA
                        _sectionTitle("Taluka"),

                        GetBuilder<LoginController>(
                            builder: (controller) {
                              return DropdownButtonFormField<String>(
                              value: loginController.selectedTaluka,
                              items: loginController.talukas
                                  .map<DropdownMenuItem<String>>(
                                    (t) => DropdownMenuItem(
                                  value: t.toString(),
                                  child: Text(t.toString(),style: AppTextStyles.caption(context),),
                                ),
                              )
                                  .toList(),
                              onChanged: (val) {
                                loginController.selectedTaluka = val;
                                loginController.update();
                              },
                              decoration: _dropdownDecoration(),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: widget.onApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:  Text(
                          "Apply",
                          style:AppTextStyles.caption(context,color: AppColors.black)
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child:  Text(
                        "Reset",
                          style:AppTextStyles.caption(context,color: AppColors.black)

                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: AppTextStyles.caption(
          context,
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// DISTANCE CHIP
  Widget _distanceChip(String value) {
    final selected = loginController.selectedDistance == value;

    return ChoiceChip(
      label: Text(value),
      selected: selected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
      onSelected: (_) {
        setState(() {
          loginController.selectedDistance = value;
        });
      },
    );
  }

  /// DROPDOWN DECORATION
  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}