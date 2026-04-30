class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String state;
  final DateTime createdDate;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.state,
    required this.createdDate,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json["_id"] ?? "",
      title: json["title"] ?? "",
      amount: double.tryParse(json["amount"].toString()) ?? 0,
      category: json["category"] ?? "General",
      state: (json["state"] ?? "").toString(),
      createdDate: DateTime.tryParse(json["createdDate"] ?? "") ??
          DateTime.now(),
    );
  }
}