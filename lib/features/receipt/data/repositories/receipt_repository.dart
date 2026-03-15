import 'dart:io';

abstract class ReceiptRepository {
  Future<String> scanReceipt(File image);
}
