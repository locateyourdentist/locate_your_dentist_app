import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/expense_model.dart';
import 'package:locate_your_dentist/model/income_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:get/get.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/expense_income_bar_chart.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/income_chart.dart';
import 'package:excel/excel.dart';
// import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  final loginController = Get.put(LoginController());
  final PlanController controller = Get.put(PlanController());
  final PlanController planController = Get.put(PlanController());
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  List<Map<String, dynamic>> transactions = [
    {"title": "Clinic Payment", "date": "12 Mar", "amount": 5000, "type": "Income"},
    {"title": "Equipment Purchase", "date": "10 Mar", "amount": 2000, "type": "Expense"},
    {"title": "Consultation Fee", "date": "8 Mar", "amount": 3000, "type": "Income"},
  ];
  String selectedMonthName = DateFormat.MMMM().format(DateTime.now());
  String selectedYear = DateTime.now().year.toString();
  String? monthNumber = DateTime.now().month.toString();
  @override
  void initState(){
    _refresh();
    super.initState();
  }
  Future<void> _refresh() async {
   await loginController.fetchStates();
   await controller.getIncomeDetailsByPlan(context: context);
   await controller.getExpense(month: "", year: "");
  }
  Color _getCategoryColor(String? category) {
    switch (category) {
      case "Salary":
        return Colors.green.shade200;
      case "Transport":
        return Colors.orange.shade200;
      case "Recharge":
        return Colors.blue.shade200;
      case "Others":
      default:
        return Colors.grey.shade300;
    }
  }
  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case "Salary":
        return Icons.attach_money;
      case "Transport":
        return Icons.directions_car;
      case "Recharge":
        return Icons.phone_android;
      case "Others":
      default:
        return Icons.category;
    }
  }
  Widget incomeExpenseBarChart(PlanController controller) {
    final income = controller.income?.total ?? 0;
    final expense = controller.total ?? 0;

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(toY: income.toDouble(), color: Colors.green)
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: expense.toDouble(), color: Colors.red)
            ]),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value == 0 ? "Income" : "Expense");
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget expensePieChart(data) {
    final stateData = data["stateWiseExpense"];

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: stateData.map<PieChartSectionData>((e) {
            final value = (e["totalExpense"] ?? 0).toDouble();
            final state = e["state"] ?? "Unknown";

            return PieChartSectionData(
              value: value,
              title: "$state\n$value",
              radius: 80,
            );
          }).toList(),
        ),
      ),
    );
  }
  Widget incomeBarChart(data) {
    final incomeData = data;

    final items = [
      {"name": "Poster", "value": incomeData["posterIncome"]["income"]},
      {"name": "Base", "value": incomeData["basePlanIncome"]["income"]},
      {"name": "AddOns", "value": incomeData["addOnsIncome"]["income"]},
      {"name": "Job", "value": incomeData["jobIncome"]["income"]},
      {"name": "Webinar", "value": incomeData["webinarIncome"]["income"]},
    ];

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(items.length, (index) {
            final value = (items[index]["value"] ?? 0).toDouble();

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: 20,
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(items[value.toInt()]["name"]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  String buildFileName({
    required String state,
    String? fromDate,
    String? toDate,
  }) {
    final safeState = (state.isEmpty) ? "AllStates" : state.replaceAll(" ", "_");

    final from = (fromDate == null || fromDate.isEmpty) ? "AllTime" : fromDate;
    final to = (toDate == null || toDate.isEmpty) ? "AllTime" : toDate;

    return "Finance_${safeState}_${from}_to_${to}.xlsx";
  }
  void addSheetTitle({
    required Sheet sheet,
    required String title,
    required CellStyle style,
  }) {
    sheet.merge(
      CellIndex.indexByString("A1"),
      CellIndex.indexByString("E1"),
    );

    sheet.cell(CellIndex.indexByString("A1"))
      ..value = TextCellValue(title)
      ..cellStyle = style;
  }
  Future<void> exportExcelWeb({
    required IncomeDashboardModel incomeModel,
    required List<ExpenseModel> expenses,
    required List<Map<String, dynamic>> stateWiseExpense,
    required double totalExpense,
    required String state,
    String? fromDate,
    String? toDate,
  }) async {
    final excel = Excel.createExcel();

    excel.rename('Sheet1', 'Income');
    excel.setDefaultSheet('Income');

    final titleStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      fontSize: 14,
    );

    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );

    final cellStyle = CellStyle(
      leftBorder: Border(borderStyle: BorderStyle.Thin),
      rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin),
      bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );

    final fileName = "report_${state}_${fromDate ?? ''}_${toDate ?? ''}";

    final incomeSheet = excel['Income'];

    incomeSheet.appendRow([
      TextCellValue("Income Report"),
    ]);

    incomeSheet.merge(
      CellIndex.indexByString("A1"),
      CellIndex.indexByString("B1"),
    );

    incomeSheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;

    incomeSheet.appendRow([
      TextCellValue("Category"),
      TextCellValue("Income"),
    ]);

    incomeSheet.cell(CellIndex.indexByString("A2")).cellStyle = headerStyle;
    incomeSheet.cell(CellIndex.indexByString("B2")).cellStyle = headerStyle;

    final incomeData = [
      ["Poster", incomeModel.posterIncome],
      ["Base Plan", incomeModel.basePlanIncome],
      ["AddOns", incomeModel.addOnsIncome],
      ["Job", incomeModel.jobIncome],
      ["Webinar", incomeModel.webinarIncome],
    ];

    for (int i = 0; i < incomeData.length; i++) {
      final row = i + 3;

      incomeSheet.appendRow([
        TextCellValue(incomeData[i][0].toString()),
        TextCellValue(incomeData[i][1].toString()),
      ]);

      incomeSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).cellStyle =
          cellStyle;
      incomeSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).cellStyle =
          cellStyle;
    }

    final expenseSheet = excel['Expenses'];

    expenseSheet.appendRow([
      TextCellValue("Expense Report"),
    ]);

    expenseSheet.appendRow([
      TextCellValue("Title"),
      TextCellValue("Category"),
      TextCellValue("Amount"),
      TextCellValue("State"),
      TextCellValue("Date"),
    ]);

    for (int i = 0; i < 5; i++) {
      expenseSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
          .cellStyle = headerStyle;
    }

    for (int i = 0; i < expenses.length; i++) {
      final e = expenses[i];
      final row = i + 2;

      expenseSheet.appendRow([
        TextCellValue(e.title ?? ""),
        TextCellValue(e.category ?? ""),
        TextCellValue((e.amount ?? 0).toString()),
        TextCellValue((e.state?.isEmpty ?? true) ? "Others" : e.state!),
        TextCellValue(e.createdDate.toString().split('T')[0]),
      ]);

      for (int c = 0; c < 5; c++) {
        expenseSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
            .cellStyle = cellStyle;
      }
    }
    final stateSheet = excel['StateWise'];

    stateSheet.appendRow([
      TextCellValue("State Wise Expense"),
    ]);

    stateSheet.appendRow([
      TextCellValue("State"),
      TextCellValue("Total Expense"),
    ]);

    stateSheet.cell(CellIndex.indexByString("A2")).cellStyle = headerStyle;
    stateSheet.cell(CellIndex.indexByString("B2")).cellStyle = headerStyle;

    for (int i = 0; i < stateWiseExpense.length; i++) {
      final s = stateWiseExpense[i];
      final row = i + 3;

      stateSheet.appendRow([
        TextCellValue((s['state'] == null || s['state'] == "")
            ? "Others"
            : s['state'].toString()),
        TextCellValue((s['totalExpense'] ?? 0).toString()),
      ]);

      stateSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .cellStyle = cellStyle;

      stateSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .cellStyle = cellStyle;
    }
    final summary = excel['Summary'];

    final totalIncome = incomeModel.posterIncome +
        incomeModel.basePlanIncome +
        incomeModel.addOnsIncome +
        incomeModel.jobIncome +
        incomeModel.webinarIncome;

    summary.appendRow([
      TextCellValue("Total Income"),
      TextCellValue(totalIncome.toString()),
    ]);

    summary.appendRow([
      TextCellValue("Total Expense"),
      TextCellValue(totalExpense.toString()),
    ]);

    summary.appendRow([
      TextCellValue("Profit/Loss"),
      TextCellValue((totalIncome - totalExpense).toString()),
    ]);

    final bytes = excel.encode();
    if (bytes == null) return;
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(bytes),
      mimeType: MimeType.microsoftExcel,
    );
  }
  @override
  Widget build(BuildContext context) {
    double income = transactions.where((e) => e["type"] == "Income").fold(0, (sum, e) => sum + e["amount"]);
    double expense = transactions.where((e) => e["type"] == "Expense").fold(0, (sum, e) => sum + e["amount"]);
    double balance = income - expense;
    final size = MediaQuery.of(context).size.width;
    final userType=Api.userInfo.read('userType');
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.primary,
      //   child:  Icon(Icons.add,size: size*0.014,color: AppColors.white,),
      //   onPressed: () {
      //     Get.toNamed('/addExpenseWeb');
      //   },
      // ),
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LYD",
        onLogout: () {
        },
        onNotification: () {
        },
      ),
      body:  GetBuilder<PlanController>(
          builder: (controller) {
            return Row(
            children: [
              const AdminSideBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                            "Finance Dashboard",
                            style:AppTextStyles.subtitle(context,)),
                         ],
                       ),
                       SizedBox(height: size*0.01,),
                     if( userType=='superAdmin')
                       Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Text('Select State',style: AppTextStyles.caption(context,fontWeight: FontWeight.bold),),
                           SizedBox(width: size*0.05,),
                           Expanded(
                            //width: size*0.3,
                              child:  GetBuilder<LoginController>(
                               builder: (controller) {
                                 return Center(
                                   child: CustomDropdown<String>.search(
                                     hintText: "Select State",
                                     decoration: CustomDropdownDecoration(
                                       closedFillColor: Colors.white,
                                       expandedFillColor: Colors.white,
                                       closedBorderRadius: BorderRadius.circular(10),
                                       expandedBorderRadius: BorderRadius.circular(10),
                                       hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                                       headerStyle: AppTextStyles.caption(context, color: Colors.black),
                                       listItemStyle: AppTextStyles.caption(context, color: Colors.black),),
                                     items: controller.states.map((s) => s.toString()).toList(),
                                     //initialItem: controller.selectedState,
                                     onChanged: (val) async{
                                       if (val != null) {
                                         controller.selectedState = val;
                                         controller.districts.clear();
                                         controller.selectedDistrict = null;
                                         controller.selectedTaluka = null;
                                         controller.selectedVillage = null;
                                         final state = controller.states.firstWhere((s) => s == val);
                                         print('state  selected$state');
                                         //controller.fetchDistricts(state.toString());
                                       await  planController.getExpense(
                                           month: "",
                                           year: "",
                                           state: controller.selectedState,
                                         );
                                         await  planController.getIncomeDetailsByPlan(state:controller.selectedState,fromDate: fromDateController.text,toDate: toDateController.text, context: context);
                                         planController.getExpense(
                                           state: controller.selectedState,
                                           month: monthNumber,
                                           year: selectedYear,
                                         );

                                         controller.update();
                                         planController.update();
                                       }
                                     },
                                   ),
                                 );
                               },
                             ),
                           ),
                           SizedBox(width: size*0.05,),

                           Expanded(
                             child: CustomTextField(
                               hint: "From Date",
                               controller: fromDateController,
                               fillColor: Colors.white,
                               borderColor: AppColors.white,
                               readOnly: true,
                               onTap: () async {
                                 DateTime? pickedDate = await showDatePicker(
                                   context: context,
                                   initialDate: DateTime.now(),
                                   firstDate: DateTime(2025),
                                   lastDate: DateTime.now(),
                                 );

                                 if (pickedDate != null) {
                                   fromDateController.text =
                                   "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                   toDateController.clear();
                                   planController.getExpense(
                                     state: controller.selectedState,
                                     month: pickedDate.month.toString(),
                                     year: pickedDate.year.toString(),
                                   );

                                 }
                               },
                             ),
                           ),
                           SizedBox(width: size*0.03,),
                           Expanded(
                             child: CustomTextField(
                               hint: "To Date",
                               controller: toDateController,
                               fillColor:Colors.white,
                               borderColor: AppColors.white,
                               readOnly: true,
                               onTap: () async {
                                 DateTime? pickedDate = await showDatePicker(
                                   context: context,
                                   initialDate: DateTime.now(),
                                   firstDate: DateTime(2025),
                                   lastDate: DateTime.now(),
                                 );

                                 if (pickedDate != null) {
                                   toDateController.text =
                                   "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                   print('pick date${pickedDate.month.toString()}pick year${pickedDate.year.toString()}');
                                   await  controller.getIncomeDetailsByPlan(fromDate: fromDateController.text,toDate: toDateController.text, context: context);
                                   await planController.getExpense(
                                     state: controller.selectedState,
                                     month: pickedDate.month.toString(),
                                     year: pickedDate.year.toString(),
                                   );
                                 }
                               },
                             ),
                           ),
                         ],
                       ),
                      SizedBox(height: size*0.01,),

                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            gradientButton(
                              text: 'Export Excel',
                              icon: Icons.download,
                              height: size * 0.013,
                              width: size * 0.07,
                              onTap: () async {
                                await Future.delayed(const Duration(milliseconds: 300));
                                await exportExcelWeb(
                                  incomeModel: controller.income!,
                                  expenses: controller.expenses,
                                  stateWiseExpense: controller.stateWiseExpense,
                                  totalExpense: controller.total.toDouble(),
                                  state: controller.selectedState ?? "All",
                                  fromDate: fromDateController.text.toString(),
                                  toDate: toDateController.text.toString(),
                                );
                              },
                              context: context,
                            ),

                            SizedBox(width: size * 0.01),

                            gradientButton(
                              text: 'Add Expense Details',
                              icon: Icons.add,
                              height: size * 0.013,
                              width: size * 0.095,
                              onTap: () {
                                Get.toNamed('/addExpenseWeb', arguments: {
                                  'selectedString': "BasePlan",
                                });
                              },
                              context: context,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      GetBuilder<PlanController>(
                          builder: (controller) {
                            return Row(
                            children: [

                              _summaryCard(
                                  "Income",
                                  "\₹ ${controller.income?.total.toStringAsFixed(2)}",
                                  // "₹$income",
                                  Colors.green
                              ),

                              const SizedBox(width: 20),

                              _summaryCard(
                                  "Expense",
                                  //"₹$expense",
                                  "\₹ ${controller.total.toStringAsFixed(2)}",
                                  Colors.red
                              ),

                              const SizedBox(width: 20),

                              _summaryCard(
                                  "Balance",
                                  "₹ ${( (controller.income?.total ?? 0) - (controller.total ?? 0) ).toStringAsFixed(2)}",
                                  Colors.blue
                              ),

                            ],
                          );
                        }
                      ),

                      const SizedBox(height: 30),


                      Row(
                        children: [

                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search transaction...",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: DropdownButton(
                              underline: const SizedBox(),
                              value: "All",
                              items: const [
                                DropdownMenuItem(value: "All", child: Text("All")),
                                DropdownMenuItem(value: "Income", child: Text("Income")),
                                DropdownMenuItem(value: "Expense", child: Text("Expense")),
                              ],
                              onChanged: (value) {},
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: 30),

                      Expanded(
                        child: Row(
                          children: [

                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                       Center(
                                         child: Text(
                                          "Expense Details",
                                          style:AppTextStyles.subtitle(context,color: AppColors.black)
                                                                               ),
                                       ),


                                      // Expanded(
                                      //   child: ListView.builder(
                                      //     itemCount: transactions.length,
                                      //     itemBuilder: (context,index){
                                      //
                                      //       final t = transactions[index];
                                      //
                                      //       return Container(
                                      //         margin: const EdgeInsets.only(bottom: 12),
                                      //         padding: const EdgeInsets.all(15),
                                      //         decoration: BoxDecoration(
                                      //             color: const Color(0xfff7f8fc),
                                      //             borderRadius: BorderRadius.circular(10)
                                      //         ),
                                      //         child: Row(
                                      //           children: [
                                      //
                                      //             CircleAvatar(
                                      //               backgroundColor:
                                      //               t["type"] == "Income"
                                      //                   ? Colors.green.withOpacity(.2)
                                      //                   : Colors.red.withOpacity(.2),
                                      //               child: Icon(
                                      //                 t["type"] == "Income"
                                      //                     ? Icons.arrow_downward
                                      //                     : Icons.arrow_upward,
                                      //                 color: t["type"] == "Income"
                                      //                     ? Colors.green
                                      //                     : Colors.red,
                                      //               ),
                                      //             ),
                                      //
                                      //             const SizedBox(width: 15),
                                      //
                                      //             Expanded(
                                      //               child: Column(
                                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                                      //                 children: [
                                      //
                                      //                   Text(
                                      //                     t["title"],
                                      //                     style: const TextStyle(
                                      //                         fontWeight: FontWeight.bold
                                      //                     ),
                                      //                   ),
                                      //
                                      //                   Text(
                                      //                     t["date"],
                                      //                     style: TextStyle(
                                      //                         color: Colors.grey.shade600
                                      //                     ),
                                      //                   ),
                                      //
                                      //                 ],
                                      //               ),
                                      //             ),
                                      //
                                      //             Text(
                                      //               "₹${t["amount"]}",
                                      //               style: TextStyle(
                                      //                   fontWeight: FontWeight.bold,
                                      //                   color: t["type"] == "Income"
                                      //                       ? Colors.green
                                      //                       : Colors.red
                                      //               ),
                                      //             )
                                      //
                                      //           ],
                                      //         ),
                                      //       );
                                      //     },
                                      //   ),
                                      //
                                      // ),

                                        Column(
                                          children: [
                                            SizedBox(height: size*0.01,),
                                            if(controller.expenses.isEmpty)

                                              Center(child: Text('No data found',style: AppTextStyles.caption(context),)),
                                            if(controller.expenses.isNotEmpty)
                                              ListView.builder(
                                                shrinkWrap: true,
                                                // physics: const NeverScrollableScrollPhysics(),
                                                itemCount: controller.expenses.length,
                                                itemBuilder: (context, index) {
                                                  final expense =
                                                  controller.expenses[index];

                                                  return Container(
                                                    margin:
                                                    const EdgeInsets.symmetric(vertical: 8),
                                                    padding: const EdgeInsets.all(14),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.grey.shade50,
                                                          Colors.grey.shade50,
                                                        ],
                                                      ),
                                                      borderRadius:
                                                      BorderRadius.circular(16),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: size*0.013,
                                                          backgroundColor: _getCategoryColor(expense.category),
                                                          child: Icon(
                                                            _getCategoryIcon(expense.category),
                                                            color: Colors.white,
                                                            size: size*0.012,
                                                          ),
                                                        ),
                                                         SizedBox(width: size*0.01),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(expense.title, style:AppTextStyles.caption(context,fontWeight: FontWeight.bold)
                                                                  ),
                                                                  const SizedBox(width: 6),
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.blue.shade50,
                                                                      borderRadius: BorderRadius.circular(6),
                                                                    ),
                                                                    child:Text(
                                                                      (expense.state ?? "").isEmpty ? "Others" : expense.state ?? "Others",
                                                                        style:AppTextStyles.caption(context,fontWeight: FontWeight.normal,color: AppColors.grey)
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // Text(
                                                              //   expense.title,
                                                              //     style:AppTextStyles.caption(context)
                                                              //
                                                              // ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                "${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.createdDate)}",
                                                                  style:AppTextStyles.caption(context,color: AppColors.grey)
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                          "₹ ${expense.amount.toStringAsFixed(2)}",
                                                          style: AppTextStyles.body(context,color: Colors.green,fontWeight: FontWeight.bold)
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),



                                            // _incomeTile(
                                            //     "Poster Income", income.posterIncome, income.activeUsers.poster,context),
                                            // _incomeTile(
                                            //     "Base Plan Income", income.basePlanIncome, income.activeUsers.basePlan,context),
                                            // _incomeTile(
                                            //     "Add Ons Income", income.addOnsIncome, income.activeUsers.addOns,context),
                                            // _incomeTile(
                                            //     "Job Income", income.jobIncome, income.activeUsers.job,context),
                                            // _incomeTile(
                                            //     "Webinar Income", income.webinarIncome, income.activeUsers.webinar,context),
                                            GetBuilder<PlanController>(
                                                builder: (controller) {
                                                  final income = controller.income;
                                                  if (income == null) {
                                                    return  Center(child: Text("No Data Found",  style:AppTextStyles.caption(context)
                                                    ));
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.all(15.0),
                                                    child: Column(
                                                        children:[
                                                          Text('Income Details',style: AppTextStyles.subtitle(context),),
                                                        SizedBox(height: size*0.01,),
                                                         _incomeTile(
                                                              "Poster Income",
                                                              income.posterIncome,
                                                              income.posterActiveUsers,
                                                              context
                                                          ),

                                                          _incomeTile(
                                                              "Base Plan Income",
                                                              income.basePlanIncome,
                                                              income.basePlanActiveUsers,
                                                              context
                                                          ),

                                                        _incomeTile(
                                                            "Add Ons Income",
                                                            income.addOnsIncome,
                                                            income.addOnsActiveUsers,
                                                            context
                                                        ),

                                                        _incomeTile(
                                                            "Job Income",
                                                            income.jobIncome,
                                                            income.jobActiveUsers,
                                                            context
                                                        ),

                                                        _incomeTile(
                                                            "Webinar Income",
                                                            income.webinarIncome,
                                                            income.webinarActiveUsers,
                                                            context
                                                        )

                                                        ]
                                                    ),
                                                  );
                                                }
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        "Income Overview",
                                        style: AppTextStyles.subtitle(context),
                                      ),
                                    ),

                                    SizedBox(height: size*0.01),

                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: size*0.2,
                                                      child: planController.income == null
                                                          ? const Center(child: CircularProgressIndicator())
                                                          : IncomeBarChart(
                                                        data: planController.income!,
                                                      ),
                                                    ),

                                                    Center(
                                                      child: Text(
                                                        "Expense Overview",
                                                        style: AppTextStyles.subtitle(context),
                                                      ),
                                                    ),

                                                     SizedBox(height: size*0.01),

                                                    SizedBox(
                                                      height: size*0.15,
                                                      child: ExpensePieChart(
                                                        stateWiseExpense:
                                                        planController.stateWiseExpense,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 20),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _summaryCard(String title,String amount,Color color){

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  color.withOpacity(.9),
                  color
                ]
            ),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title,
                style: AppTextStyles.subtitle(context,color: AppColors.white)
            ),

            const SizedBox(height: 10),

            Text(
              amount,
              style: AppTextStyles.subtitle(context,color: AppColors.white)
            )

          ],
        ),
      ),
    );
  }
}

Widget _incomeTile(String title, int amount, int users,dynamic context) {
  final size = MediaQuery.of(context).size.width;
  return AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    margin:
    const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.grey.shade50,
          Colors.grey.shade50,
        ],
      ),
      borderRadius:
      BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: size*0.013,
          backgroundColor:AppColors.primary,
          child: Icon(
            Icons.monetization_on_outlined,
            color: Colors.white,
            size: size*0.012,
          ),
        ),
        SizedBox(width: size*0.01),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
          
              Text(title,
                  style:  AppTextStyles.body(context,fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Active Users: $users",
                  style:  AppTextStyles.caption(context,)),
            ],
          ),
        ),
        Text(
          "₹ $amount",
            style: AppTextStyles.body(context,color: Colors.green,fontWeight: FontWeight.bold)

        ),
      ],
    ),
  );
}
Widget incomeBarChart(IncomeDashboardModel data) {
  final items = [
    {"name": "Poster", "value": data.posterIncome.toDouble()},
    {"name": "Base", "value": data.basePlanIncome.toDouble()},
    {"name": "AddOns", "value": data.addOnsIncome.toDouble()},
    {"name": "Job", "value": data.jobIncome.toDouble()},
    {"name": "Webinar", "value": data.webinarIncome.toDouble()},
  ];

  return SizedBox(
    height: 300,
    child: BarChart(
      BarChartData(
        barGroups: List.generate(items.length, (index) {
          final value = items[index]["value"] as double;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 18,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),

        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(items[value.toInt()]["name"].toString()),
                );
              },
            ),
          ),

          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),

        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    ),
  );
}
Widget expensePieChart(Map<String, dynamic> data,dynamic context) {
  final List stateData = data["stateWiseExpense"] ?? [];
  double size=MediaQuery.of(context).size.width;

  return SizedBox(
    height: size*0.05,
    child: PieChart(
      PieChartData(
        sections: List.generate(stateData.length, (i) {
          final item = stateData[i];

          final value = (item["totalExpense"] ?? 0).toDouble();
          final state = item["state"]?.toString().isEmpty == true
              ? "Unknown"
              : item["state"];

          return PieChartSectionData(
            value: value,
            title: "$state\n₹$value",
            radius: 70,
            color: Colors.primaries[i % Colors.primaries.length],
            titleStyle:AppTextStyles.caption(context,color: AppColors.white,fontWeight: FontWeight.bold)
          );
        }),
      ),
    ),
  );
}