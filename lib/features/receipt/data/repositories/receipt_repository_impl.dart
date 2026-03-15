import 'dart:io';

import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_local_datasource.dart';
import '../datasources/receipt_remote_datasource.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptLocalDatasource local;
  final ReceiptRemoteDatasource remote;

  ReceiptRepositoryImpl({
    required this.local,
    required this.remote,
  });

  @override
  Future<List<Map<String, dynamic>>> getReceipts() async {
    return await local.getReceipts();
  }

  @override
  Future<void> saveReceipt(Map<String, dynamic> data) async {
    await local.insertReceipt(data);
  }

  @override
  Future<String> scanReceipt(File image) async {
    return await remote.scanReceipt(image);
  }
}
