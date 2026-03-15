class ReceiptModel {
  final int? id;
  final String store;
  final double total;
  final double? vat;
  final double? tax;
  final String? imagePath;
  final String date;
  final String category;

  ReceiptModel({
    this.id,
    required this.store,
    required this.total,
    this.vat,
    this.tax,
    this.imagePath,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'store': store,
      'total': total,
      'vat': vat,
      'tax': tax,
      'imagePath': imagePath,
      'date': date,
      'category': category,
    };
  }

  factory ReceiptModel.fromMap(Map<String, dynamic> map) {
    return ReceiptModel(
      id: map['id'] as int?,
      store: map['store'] ?? 'Unknown',
      total: (map['total'] is num)
          ? map['total'].toDouble()
          : double.tryParse('${map['total']}') ?? 0,
      vat: (map['vat'] is num)
          ? map['vat'].toDouble()
          : (map['vat'] != null ? double.tryParse('${map['vat']}') : null),
      tax: (map['tax'] is num)
          ? map['tax'].toDouble()
          : (map['tax'] != null ? double.tryParse('${map['tax']}') : null),
      imagePath: map['imagePath']?.toString(),
      date: map['date'] ?? '',
      category: map['category'] ?? 'Expense',
    );
  }
}
