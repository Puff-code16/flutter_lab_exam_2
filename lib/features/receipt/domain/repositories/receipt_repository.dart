import 'dart:io';

abstract class ReceiptRepository {
  Future<List<Map<String, dynamic>>> getReceipts();

  Future<void> saveReceipt(Map<String, dynamic> data);

  Future<String> scanReceipt(File image);
}
