import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/expense_model.dart';
import 'package:locate_your_dentist/model/income_model.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/excel_service.dart';
import '../../common_widgets/color_code.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

class ReportsDashboardPage extends StatefulWidget {
  const ReportsDashboardPage({super.key});

  @override
  State<ReportsDashboardPage> createState() => _ReportsDashboardPageState();
}
class _ReportsDashboardPageState extends State<ReportsDashboardPage> {
  final PlanController controller = Get.put(PlanController());
  String selectedYear = DateTime.now().year.toString();
  // Future<void> exportExcel({
  //   required IncomeDashboardModel incomeModel,
  //   required List<ExpenseModel> expenses,
  //   required List<Map<String, dynamic>> stateWiseExpense,
  //   required double totalExpense,
  //   required String state,
  //   String? fromDate,
  //   String? toDate,
  // }) async {
  //
  //   final excel = ExcelService.buildExcel(
  //     incomeModel: incomeModel,
  //     expenses: expenses,
  //     stateWiseExpense: stateWiseExpense,
  //     totalExpense: totalExpense,
  //   );
  //
  //   final bytes = excel.encode();
  //   if (bytes == null) return;
  //
  //   final fileName = buildFileName(
  //     state: state,
  //     fromDate: fromDate,
  //     toDate: toDate,
  //   );
  //
  //   downloadExcel(bytes, fileName);
  // }
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
  @override
  void initState() {
    super.initState();
    _refresh();
  }
  Future<void> _refresh() async {
   await controller.getIncomeDetailsByPlan(context: context);
   await controller.getExpense(month: "", year: selectedYear);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          'Report Details',
          style: AppTextStyles.subtitle(context, color: AppColors.black),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
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
      body: GetBuilder<PlanController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total Income",
                          style: AppTextStyles.body(
                              context,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\₹ ${controller.income?.total.toStringAsFixed(2) ?? 0}",
                          style: AppTextStyles.body(
                              context,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Total Expenses",
                          style: AppTextStyles.subtitle(
                              context,
                              color: AppColors.white,
                            ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\₹ ${controller.total.toStringAsFixed(2)}",
                          style: AppTextStyles.caption(
                              context,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    children: [
                      _metricCard(
                        title: "Income",
                        value:
                        "\₹ ${controller.income?.total.toStringAsFixed(2)}",
                        color: Colors.green,
                        onTap: () => Get.toNamed('/viewIncomePage'),
                      ),
                      _metricCard(
                        title: "Expenses",
                        value: "\₹ ${controller.total.toStringAsFixed(2)}",
                        color: Colors.red,
                        onTap: () => Get.toNamed('/viewExpensePage'),
                      ),
                      _metricCard(
                        title: "New Users",
                        value: "30",
                         //controller.newUsers,
                        color: Colors.blue,
                        onTap: () => Get.toNamed('/usersPage'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }

  Widget _metricCard(
      {required String title,
        required String value,
        required Color color,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyles.caption(
                  Get.context!, color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.caption(
                  Get.context!, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}