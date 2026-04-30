import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../common_widgets/color_code.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class AddExpenseWeb extends StatefulWidget {
  const AddExpenseWeb({super.key});
  @override
  State<AddExpenseWeb> createState() => _AddExpenseWebState();
}
class _AddExpenseWebState extends State<AddExpenseWeb> {
  final planController=Get.put(PlanController());
  final _formKeyAddExpenseWeb = GlobalKey<FormState>();
  String? selectedMonthName;
  String?  monthNumber;
  String? selectState;
  String selectedYear = DateTime.now().year.toString();
  final loginController = Get.put(LoginController());

  //String selectedYear = DateTime.now().year.toString();
  //= DateFormat.MMMM().format(DateTime.now());
  @override
  void initState() {
    super.initState();
    selectedMonthName = DateFormat.MMMM().format(DateTime.now());
    planController.selectedYear = DateTime.now().year.toString();
     loginController.fetchStates();

  }
  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LYD",
        onLogout: () {
        },
        onNotification: () {
        },
      ),
      body: GetBuilder<PlanController>(
          builder: (controller) {
            return Row(
              children: [
                const AdminSideBar(),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 35.0,right: 35),
                      child:ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Container(
                          width: double.infinity,
                          //color: Colors.grey[100],
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                            ],
                          ),
                          child: Form(
                            key: _formKeyAddExpenseWeb,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  children: [
                                    Text('Add Expenses',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                                    SizedBox(height: size*0.02,),

                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Select State',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                                        //SizedBox(width: size*0.05,),

                                       if(Api.userInfo.read('userType')=='superAdmin')
                                        Expanded(
                                          child:  GetBuilder<LoginController>(
                                            builder: (controller) {
                                              return CustomDropdown<String>.search(
                                                hintText: "Select State",
                                                decoration: CustomDropdownDecoration(
                                                  closedFillColor: Colors.grey.shade100,
                                                  expandedFillColor: Colors.white,
                                                  closedBorder: Border.all(
                                                    color: AppColors.white,
                                                    width: 1.5,
                                                  ),
                                                  expandedBorder: Border.all(
                                                    color: AppColors.primary,
                                                    width: 1.5,
                                                  ),
                                                  closedBorderRadius: BorderRadius.circular(10),
                                                  expandedBorderRadius: BorderRadius.circular(10),
                                                  hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                                  headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                                  listItemStyle: AppTextStyles.caption(context, color: Colors.black),),
                                                items: controller.states.map((s) => s.toString()).toList(),
                                                //initialItem: controller.selectedState,
                                                onChanged: (val) {
                                                  if (val != null) {
                                                    planController.selectedState = val;
                                                    controller.districts.clear();
                                                    controller.selectedDistrict = null;
                                                    controller.selectedTaluka = null;
                                                    controller.selectedVillage = null;
                                                    final state = controller.states.firstWhere((s) => s == val);
                                                    print('state  selected$state');
                                                    controller.update();
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size*0.01,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: _modernFilterBox(
                                            icon: Icons.calendar_month,
                                            label: selectedMonthName!,
                                            onTap: _showMonthPickerDialog,
                                          ),
                                        ),
                                         SizedBox(width: size*0.01,),
                                        Expanded(
                                          child:  Expanded(
                                            child: _modernFilterBox(
                                              icon: Icons.date_range,
                                              label: selectedYear,
                                              onTap: _showYearPickerRadioDialog,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size*0.01,),

                                    CustomTextField(
                                      hint: "Title",
                                      icon: Icons.location_city,
                                      controller: planController.titleController,
                                      // fillColor: AppColors.white,
                                      // borderColor: AppColors.grey,
                                    ),
                                    SizedBox(height: size * 0.01),
                                    CustomTextField(
                                      hint: "Amount",
                                      icon: Icons.location_city,keyboardType: TextInputType.number,
                                      controller: planController.amountController,
                                      //fillColor: AppColors.white,
                                      maxLength: 5,
                                      //borderColor: AppColors.grey,
                                    ),
                                    SizedBox(height: size * 0.01),
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
                                      Column(
                                        children: [
                                          SizedBox(height: size * 0.01),

                                          CustomTextField(
                                            hint: "Category",
                                            icon: Icons.pin,
                                            controller: planController.categoryController,
                                            // keyboardType: TextInputType.number,
                                            //fillColor: AppColors.white,
                                            //borderColor: AppColors.grey,
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: size * 0.02),
                                    Center(
                                        child:  Container(
                                            width: size*0.4,
                                            height: size*0.016,
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
                                                if (_formKeyAddExpenseWeb.currentState!.validate())
                                                  if (planController.selectedCategory == "Others") {
                                                    if (selectedMonthName == "All") {
                                                      monthNumber = "";
                                                    } else {
                                                      monthNumber = DateFormat.MMMM().parse(selectedMonthName!).month.toString();
                                                    }
                                                    print('dff${planController.selectedState!}');
                                                    planController.addExpenseDetail(
                                                        Api.userInfo.read('userType')=='superAdmin'? planController.selectedState??"":Api.userInfo.read('state'),
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
                                                        Api.userInfo.read('userType')=='superAdmin'? planController.selectedState??"":Api.userInfo.read('state'),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
      ),
     // bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
  void _showMonthPickerDialog() {
    final months = List.generate(12, (index) => DateFormat.MMMM().format(DateTime(0, index + 1)));
    String? tempSelectedMonth = selectedMonthName;
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
            width: 200,
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
                Navigator.pop(context);
              },
              child:  Text("Cancel",style: AppTextStyles.caption(context),),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedMonthName = tempSelectedMonth!;
                  monthNumber = tempMonthNumber;
                });
                Navigator.pop(context);
              },
              child:  Text("OK",style: AppTextStyles.caption(context),),
            ),
          ],
        );
      },
    );
  }
  void _showYearPickerRadioDialog() {
    final years = List.generate(10, (i) => DateTime.now().year - i);
    String? tempSelectedYear = selectedYear;

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
                Navigator.pop(context);
              },
              child:  Text("Cancel",style: AppTextStyles.caption(context),),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedYear = tempSelectedYear!;
                });

                Navigator.pop(context);
              },
              child:  Text("OK",style: AppTextStyles.caption(context),),
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
             Icon(Icons.keyboard_arrow_down, size:14,color: Colors.grey),
          ],
        ),
      ),
    );
  }
}