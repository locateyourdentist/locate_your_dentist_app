import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import '../../common_widgets/color_code.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

  class AddExpense extends StatefulWidget {
   const AddExpense({super.key});
  @override
  State<AddExpense> createState() => _AddExpenseState();
  }
  class _AddExpenseState extends State<AddExpense> {
  final planController=Get.put(PlanController());
  final _formKeyAddExpense = GlobalKey<FormState>();
  String? selectedMonthName;
  String?  monthNumber;
  String? selectState;
  String selectedYear = DateTime.now().year.toString();
  //String selectedYear = DateTime.now().year.toString();
  //= DateFormat.MMMM().format(DateTime.now());
  @override
  void initState() {
    super.initState();
    selectedMonthName = DateFormat.MMMM().format(DateTime.now());
    planController.selectedYear = DateTime.now().year.toString();
    }

  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(centerTitle: true,backgroundColor: AppColors.white,
        automaticallyImplyLeading: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Get.back();
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
        iconTheme: const IconThemeData(color: AppColors.black),
        title: Text('Add Expense Details',style: AppTextStyles.subtitle(context,color: AppColors.black),),
      ),
      body: GetBuilder<PlanController>(
          builder: (controller) {
            return Form(
              key: _formKeyAddExpense,
              child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    CustomDropdownField(
                      hint: "Select State",
                      // icon: Icons.place,
                      fillColor: Colors.grey[100],borderColor: AppColors.white,
                      items: const ["Tamilnadu","karnataka","Andhra"],
                      selectedValue: (selectState != null &&
                          ["Tamilnadu","karnataka","Andhra"]
                              .contains(selectState))
                          ? selectState
                          : null,
                      onChanged: (value) {
                        setState(() {
                          selectState = value;
                          print('se state$selectState');
                          planController.selectedState = value;
                        });
                        controller.getExpense(
                            month: monthNumber,
                            year: selectedYear,state: selectState
                        );
                      },
                    ),
                    SizedBox(height: size*0.01,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: size*0.44,
                          child:   Expanded(
                    child: _modernFilterBox(
                    icon: Icons.calendar_month,
                      label: selectedMonthName!,
                      onTap: _showMonthPickerDialog,
                    ),
              ),
                          // CustomDropdownField(
                          //   hint: "Select Month",
                          //   // fillColor: AppColors.white,
                          //   // borderColor: AppColors.grey,
                          //   items: List.generate(
                          //       12,
                          //           (i) => DateFormat.MMMM().format(DateTime(0, i + 1)),
                          //     ),
                          //   selectedValue: selectedMonthName,
                          //   onChanged: (val) {
                          //     setState(() {
                          //       selectedMonthName = val!;
                          //     });
                          //
                          //     String? monthNumber;
                          //
                          //     if (selectedMonthName == "All") {
                          //       monthNumber = "";
                          //
                          //     } else {
                          //       monthNumber = DateFormat.MMMM().parse(selectedMonthName!).month.toString();
                          //     }
                          //     print('dff$monthNumber');
                          //   },
                          // ),
                        ),

                        SizedBox(
                          width: size*0.45,
                          child:  Expanded(
                            child: _modernFilterBox(
                              icon: Icons.date_range,
                              label: selectedYear,
                              onTap: _showYearPickerRadioDialog,
                            ),
                          ),

                          // CustomDropdownField(
                          //   hint: "Select Year",
                          //   // fillColor: AppColors.grey,
                          //   // borderColor: AppColors.grey,
                          //   items: List.generate(
                          //     5,
                          //         (i) => "${DateTime.now().year - i}",
                          //   ),
                          //   selectedValue: planController.selectedYear != null &&
                          //       List.generate(5, (i) => "${DateTime.now().year - i}")
                          //           .contains(planController.selectedYear)
                          //       ? planController.selectedYear
                          //       : null,
                          //   onChanged: (val) {
                          //     setState(() {
                          //       planController.selectedYear = val;
                          //     });
                          //   },
                          // ),
                        ),
                      ],
                    ),
                    SizedBox(height: size*0.03,),

                    CustomTextField(
                      hint: "Title",
                      icon: Icons.location_city,
                      controller: planController.titleController,
                      // fillColor: AppColors.white,
                      // borderColor: AppColors.grey,
                    ),
                    SizedBox(height: size * 0.03),
                    CustomTextField(
                      hint: "Amount",
                      icon: Icons.location_city,keyboardType: TextInputType.number,
                      controller: planController.amountController,
                      //fillColor: AppColors.white,
                      maxLength: 5,
                      //borderColor: AppColors.grey,
                    ),
                    SizedBox(height: size * 0.03),
                    CustomDropdownField(
                      hint: "Select Category",
                      //icon: Icons.person_outline,
                      //borderColor: AppColors.grey,
                      //fillColor: AppColors.white,
                      items: const [
                        "Salary",
                        "Transport",
                        "Recharge",
                        "Others",
                      ],
                      selectedValue: planController.selectedCategory?.isEmpty == true
                          ? null
                          : planController.selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          planController.selectedCategory = value;
                          // _updateFields();
                        });
                      },
                    ),
                    if(planController.selectedCategory=="Others")
                    CustomTextField(
                      hint: "Category",
                      icon: Icons.pin,
                      controller: planController.categoryController,
                      // keyboardType: TextInputType.number,
                      //fillColor: AppColors.white,
                      //borderColor: AppColors.grey,
                    ),
                    SizedBox(height: size * 0.06),
                  Center(
                    child:  Container(
                        width: size,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Colors.transparent,shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      onPressed: () {
                        if (_formKeyAddExpense.currentState!.validate())
                          if (planController.selectedCategory == "Others") {
                            if (selectedMonthName == "All") {
                              monthNumber = "";
                            } else {
                              monthNumber = DateFormat.MMMM().parse(selectedMonthName!).month.toString();
                            }
                            print('dff${planController.selectedState!}');
                            planController.addExpenseDetail(
                                planController.selectedState??"",
                                planController.titleController.text,
                                planController.amountController.text,
                                planController.categoryController.text,
                                monthNumber!,  planController.selectedYear.toString(), context);
                          }
                        else {
                            if (selectedMonthName == "All") {
                              monthNumber = "";
                            } else {
                              monthNumber = DateFormat.MMMM().parse(selectedMonthName!).month.toString();
                            }
                            print('dff${planController.selectedState}');

                            planController.addExpenseDetail(
                              planController.selectedState??"",
                                planController.titleController.text,
                                planController.amountController.text,
                                planController.selectedCategory!,
                                monthNumber!,  planController.selectedYear.toString(), context);
                          }
                      },child: Text('Add',style: AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold),),)))
                  ],
                ),
              ),
                        ),
            );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
  void _showMonthPickerDialog() {
    final months = List.generate(12, (index) => DateFormat.MMMM().format(DateTime(0, index + 1)));
    String? tempSelectedMonth = selectedMonthName; // temp selection
    String? tempMonthNumber = monthNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title:  Text(
              "Select Month",
              style: AppTextStyles.caption(context,fontWeight: FontWeight.bold)
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return ListView(
                  children: months.asMap().entries.map((entry) {
                    int index = entry.key;
                    String monthName = entry.value;
                    return RadioListTile<String>(
                      title: Text(
                        monthName,
                        style: AppTextStyles.caption(
                            fontWeight: tempSelectedMonth == monthName
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: tempSelectedMonth == monthName
                                ? AppColors.primary
                                : Colors.black,context
                        ),
                      ),
                      value: monthName,
                      groupValue: tempSelectedMonth,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setStateDialog(() {
                          tempSelectedMonth = value;
                          tempMonthNumber = (index + 1).toString();
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedMonthName = tempSelectedMonth!;
                  monthNumber = tempMonthNumber;
                });
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
  void _showYearPickerRadioDialog() {
    final years = List.generate(10, (i) => DateTime.now().year - i); // last 10 years
    String? tempSelectedYear = selectedYear; // temporary selection

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title:  Text(
            "Select Year",
            style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.minPositive,
            height: 250,
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return ListView(
                  children: years.map((year) {
                    final yearStr = year.toString();
                    return RadioListTile<String>(
                      title: Text(
                        yearStr,
                        style: AppTextStyles.caption(
                            fontWeight: tempSelectedYear == yearStr
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: tempSelectedYear == yearStr
                                ? AppColors.primary
                                : Colors.black,context
                        ),
                      ),
                      value: yearStr,
                      groupValue: tempSelectedYear,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setStateDialog(() {
                          tempSelectedYear = value;
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedYear = tempSelectedYear!;
                });

                Navigator.pop(context); // Confirm
              },
              child: const Text("OK"),
            ),
          ],
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
        color: Colors.grey[100], // light background
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