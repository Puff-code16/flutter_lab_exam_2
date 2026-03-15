class Receipt {
  final String store;
  final double total;
  final double vat;
  final double tax;
  final String date;
  final String category;

  Receipt({
    required this.store,
    required this.total,
    required this.vat,
    required this.tax,
    required this.date,
    required this.category,
  });

  factory Receipt.empty() {
    return Receipt(
      store: "Unknown",
      total: 0,
      vat: 0,
      tax: 0,
      date: "Unknown",
      category: "Expense",
    );
  }
}
