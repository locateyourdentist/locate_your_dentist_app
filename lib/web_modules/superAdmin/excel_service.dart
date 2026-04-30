import 'package:excel/excel.dart';
import 'package:locate_your_dentist/model/expense_model.dart';
import 'package:locate_your_dentist/model/income_model.dart';

class ExcelService {
  static Excel buildExcel({
    required IncomeDashboardModel incomeModel,
    required List<ExpenseModel> expenses,
    required List<Map<String, dynamic>> stateWiseExpense,
    required double totalExpense,
  }) {
    final excel = Excel.createExcel();

    // Income, Expense, StateWise, Summary

    return excel;
  }
}