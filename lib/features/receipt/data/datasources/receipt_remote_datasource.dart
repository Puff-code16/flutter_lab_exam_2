import 'dart:io';
import '../../../../core/services/ocr_service.dart';

class ReceiptRemoteDatasource {
  final OCRService ocrService;

  ReceiptRemoteDatasource(this.ocrService);

  Future<String> scanReceipt(File image) async {
    return await ocrService.scanText(image);
  }
}
