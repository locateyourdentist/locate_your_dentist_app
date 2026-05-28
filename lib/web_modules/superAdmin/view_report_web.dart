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
import 'package:locate_your_dentist/web_modules/superAdmin/expense_income_bar_chart.dart';
import 'package:locate_your_dentist/web_modules/superAdmin/income_chart.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await loginController.fetchStates();
    await controller.getIncomeDetailsByPlan(context: context);
    await controller.getExpense(month: "", year: "");
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case "Salary": return Colors.green.shade200;
      case "Transport": return Colors.orange.shade200;
      case "Recharge": return Colors.blue.shade200;
      case "Others":
      default: return Colors.grey.shade300;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case "Salary": return Icons.attach_money;
      case "Transport": return Icons.directions_car;
      case "Recharge": return Icons.phone_android;
      case "Others":
      default: return Icons.category;
    }
  }

  String buildFileName({required String state, String? fromDate, String? toDate}) {
    final safeState = (state.isEmpty) ? "AllStates" : state.replaceAll(" ", "_");
    final from = (fromDate == null || fromDate.isEmpty) ? "AllTime" : fromDate;
    final to = (toDate == null || toDate.isEmpty) ? "AllTime" : toDate;
    return "Finance_${safeState}_${from}_to_${to}.xlsx";
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

    final titleStyle = CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center, fontSize: 14);
    final headerStyle = CellStyle(
      bold: true, horizontalAlign: HorizontalAlign.Center,
      leftBorder: Border(borderStyle: BorderStyle.Thin), rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin), bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );
    final cellStyle = CellStyle(
      leftBorder: Border(borderStyle: BorderStyle.Thin), rightBorder: Border(borderStyle: BorderStyle.Thin),
      topBorder: Border(borderStyle: BorderStyle.Thin), bottomBorder: Border(borderStyle: BorderStyle.Thin),
    );

    final fileName = "report_${state}_${fromDate ?? ''}_${toDate ?? ''}";
    final incomeSheet = excel['Income'];
    incomeSheet.appendRow([TextCellValue("Income Report")]);
    incomeSheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("B1"));
    incomeSheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;
    incomeSheet.appendRow([TextCellValue("Category"), TextCellValue("Income")]);
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
      final row = i + 2;
      incomeSheet.appendRow([TextCellValue(incomeData[i][0].toString()), TextCellValue(incomeData[i][1].toString())]);
      incomeSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).cellStyle = cellStyle;
      incomeSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).cellStyle = cellStyle;
    }

    final expenseSheet = excel['Expenses'];
    expenseSheet.appendRow([TextCellValue("Expense Report")]);
    expenseSheet.appendRow([TextCellValue("Title"), TextCellValue("Category"), TextCellValue("Amount"), TextCellValue("State"), TextCellValue("Date")]);
    for (int i = 0; i < 5; i++) {
      expenseSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1)).cellStyle = headerStyle;
    }

    for (int i = 0; i < expenses.length; i++) {
      final e = expenses[i];
      final row = i + 2;
      expenseSheet.appendRow([
        TextCellValue(e.title ?? ""), TextCellValue(e.category ?? ""), TextCellValue((e.amount ?? 0).toString()),
        TextCellValue((e.state?.isEmpty ?? true) ? "Others" : e.state!), TextCellValue(e.createdDate.toString().split('T')[0]),
      ]);
      for (int c = 0; c < 5; c++) {
        expenseSheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row)).cellStyle = cellStyle;
      }
    }

    final stateSheet = excel['StateWise'];
    stateSheet.appendRow([TextCellValue("State Wise Expense")]);
    stateSheet.appendRow([TextCellValue("State"), TextCellValue("Total Expense")]);
    stateSheet.cell(CellIndex.indexByString("A2")).cellStyle = headerStyle;
    stateSheet.cell(CellIndex.indexByString("B2")).cellStyle = headerStyle;

    for (int i = 0; i < stateWiseExpense.length; i++) {
      final s = stateWiseExpense[i];
      final row = i + 2;
      stateSheet.appendRow([TextCellValue((s['state'] == null || s['state'] == "") ? "Others" : s['state'].toString()), TextCellValue((s['totalExpense'] ?? 0).toString())]);
      stateSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).cellStyle = cellStyle;
      stateSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).cellStyle = cellStyle;
    }

    final summary = excel['Summary'];
    final totalIncome = incomeModel.posterIncome + incomeModel.basePlanIncome + incomeModel.addOnsIncome + incomeModel.jobIncome + incomeModel.webinarIncome;
    summary.appendRow([TextCellValue("Total Income"), TextCellValue(totalIncome.toString())]);
    summary.appendRow([TextCellValue("Total Expense"), TextCellValue(totalExpense.toString())]);
    summary.appendRow([TextCellValue("Profit/Loss"), TextCellValue((totalIncome - totalExpense).toString())]);

    final bytes = excel.encode();
    if (bytes == null) return;
    await FileSaver.instance.saveFile(name: fileName, bytes: Uint8List.fromList(bytes), mimeType: MimeType.microsoftExcel);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final userType = Api.userInfo.read('userType');

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xfff4f6fa),
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LYD",
        onLogout: () {},
        onNotification: () {},
      ),
      drawer: !isDesktop ? const Drawer(width: 250, child: AdminSideBar()) : null,
      body: GetBuilder<PlanController>(
        builder: (controller) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop) const AdminSideBar(),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(isMobile ? 15.0 : 30.0, isDesktop ? 30.0 : 70.0, isMobile ? 15.0 : 30.0, 30.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Finance Dashboard", style: AppTextStyles.subtitle(context)),
                              const SizedBox(height: 20),
                              if (userType == 'superAdmin') _buildFilterSection(width, isMobile),
                              const SizedBox(height: 30),
                              _buildSummaryCards(isMobile, controller),
                              const SizedBox(height: 30),
                              _buildSearchAndActionRow(width, isMobile, controller),
                              const SizedBox(height: 30),
                              _buildDetailsGrid(width, isMobile, controller),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isDesktop)
                      Positioned(
                        top: 15,
                        left: 15,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: AppColors.primary),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(double width, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Wrap(
        spacing: 20, runSpacing: 20, crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? double.infinity : 250,
            child: GetBuilder<LoginController>(
              builder: (loginCtrl) {
                return CustomDropdown<String>.search(
                  hintText: "Select State",
                  decoration: CustomDropdownDecoration(
                    closedFillColor: Colors.white, expandedFillColor: Colors.white,
                   // closedBorder: Border.all(color: Colors.grey.shade300),
                    closedBorderRadius: BorderRadius.circular(10),
                    hintStyle: AppTextStyles.caption(context, color: AppColors.grey),
                  ),
                  items: loginCtrl.states.map((s) => s.toString()).toList(),
                  onChanged: (val) async {
                    if (val != null) {
                      loginCtrl.selectedState = val;
                      await planController.getExpense(month: "", year: "", state: val);
                      await planController.getIncomeDetailsByPlan(state: val, fromDate: fromDateController.text, toDate: toDateController.text, context: context);
                      loginCtrl.update();
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: isMobile ? double.infinity : 200,
            child: CustomTextField(
              hint: "From Date", controller: fromDateController, readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2025), lastDate: DateTime.now());
                if (picked != null) {
                  fromDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  toDateController.clear();
                  planController.getExpense(state: loginController.selectedState, month: picked.month.toString(), year: picked.year.toString());
                }
              },
            ),
          ),
          SizedBox(
            width: isMobile ? double.infinity : 200,
            child: CustomTextField(
              hint: "To Date", controller: toDateController, readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2025), lastDate: DateTime.now());
                if (picked != null) {
                  toDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  await controller.getIncomeDetailsByPlan(state: loginController.selectedState, fromDate: fromDateController.text, toDate: toDateController.text, context: context);
                  await planController.getExpense(state: loginController.selectedState, month: picked.month.toString(), year: picked.year.toString());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(bool isMobile, PlanController controller) {
    final income = controller.income?.total ?? 0.0;
    final expense = controller.total ?? 0.0;
    final balance = income - expense;

    if (isMobile) {
      return Column(
        children: [
          _summaryCardWidget("Income", "₹ ${income.toStringAsFixed(2)}", Colors.green),
          const SizedBox(height: 15),
          _summaryCardWidget("Expense", "₹ ${expense.toStringAsFixed(2)}", Colors.red),
          const SizedBox(height: 15),
          _summaryCardWidget("Balance", "₹ ${balance.toStringAsFixed(2)}", Colors.blue),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _summaryCardWidget("Income", "₹ ${income.toStringAsFixed(2)}", Colors.green)),
        const SizedBox(width: 20),
        Expanded(child: _summaryCardWidget("Expense", "₹ ${expense.toStringAsFixed(2)}", Colors.red)),
        const SizedBox(width: 20),
        Expanded(child: _summaryCardWidget("Balance", "₹ ${balance.toStringAsFixed(2)}", Colors.blue)),
      ],
    );
  }

  Widget _summaryCardWidget(String title, String amount, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(.8), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchAndActionRow(double width, bool isMobile, PlanController controller) {
    return Wrap(
      spacing: 20, runSpacing: 20, alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isMobile ? double.infinity : 300,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search transaction...", prefixIcon: const Icon(Icons.search),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => exportExcelWeb(
                incomeModel: controller.income!, expenses: controller.expenses,
                stateWiseExpense: controller.stateWiseExpense, totalExpense: controller.total.toDouble(),
                state: loginController.selectedState ?? "All", fromDate: fromDateController.text, toDate: toDateController.text,
              ),
              icon: const Icon(Icons.download), label: const Text("Export"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
            ),
            const SizedBox(width: 15),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/addExpenseWeb', arguments: {'selectedString': "BasePlan"}),
              icon: const Icon(Icons.add), label: const Text("Add Expense"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDetailsGrid(double width, bool isMobile, PlanController controller) {
    if (isMobile) {
      return Column(
        children: [
          _buildExpenseList(controller),
          const SizedBox(height: 30),
          _buildChartsSection(width, isMobile, controller),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildExpenseList(controller)),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _buildChartsSection(width, isMobile, controller)),
      ],
    );
  }

  Widget _buildExpenseList(PlanController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Text("Expense Details", style: AppTextStyles.subtitle(context, color: AppColors.black))),
          const SizedBox(height: 20),
          if (controller.expenses.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("No expenses found")))
          else
            ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.expenses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final expense = controller.expenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(expense.category).withOpacity(0.2),
                    child: Icon(_getCategoryIcon(expense.category), color: _getCategoryColor(expense.category), size: 20),
                  ),
                  title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.createdDate)}"),
                  trailing: Text("₹ ${expense.amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                );
              },
            ),
          const SizedBox(height: 30),
          _buildIncomeDetails(controller),
        ],
      ),
    );
  }

  Widget _buildIncomeDetails(PlanController controller) {
    final income = controller.income;
    if (income == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        Center(child: Text("Income Details", style: AppTextStyles.subtitle(context))),
        const SizedBox(height: 20),
        _incomeTile("Poster Income", income.posterIncome, income.posterActiveUsers, context),
        _incomeTile("Base Plan Income", income.basePlanIncome, income.basePlanActiveUsers, context),
        _incomeTile("Add Ons Income", income.addOnsIncome, income.addOnsActiveUsers, context),
        _incomeTile("Job Income", income.jobIncome, income.jobActiveUsers, context),
        _incomeTile("Webinar Income", income.webinarIncome, income.webinarActiveUsers, context),
      ],
    );
  }

  Widget _buildChartsSection(double width, bool isMobile, PlanController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text("Income Overview", style: AppTextStyles.subtitle(context)),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: controller.income == null 
              ? const Center(child: CircularProgressIndicator()) 
              : IncomeBarChart(data: controller.income!),
          ),
          const Divider(height: 60),
          Text("Expense Overview", style: AppTextStyles.subtitle(context)),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: ExpensePieChart(stateWiseExpense: controller.stateWiseExpense),
          ),
        ],
      ),
    );
  }
}

Widget _incomeTile(String title, int amount, int users, dynamic context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        //border: Border.all(color: Colors.grey.shade200)
    ),
    child: Row(
      children: [
        const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.monetization_on_outlined, color: Colors.white, size: 20)),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Active Users: $users", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Text("₹ $amount", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    ),
  );
}
