class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String addedBy;
  final DateTime createdDate;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.addedBy,
    required this.createdDate,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json["_id"],
      title: json["title"] ?? "",
      amount: double.tryParse(json["amount"].toString()) ?? 0,
      category: json["category"] ?? "General",
      addedBy: json["addedBy"] ?? "",
      createdDate: DateTime.parse(json["createdDate"]),
    );
  }
}
