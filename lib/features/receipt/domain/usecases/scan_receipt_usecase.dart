import 'dart:io';
import '../../../../core/services/ocr_service.dart';

class ScanReceiptUseCase {
  final OCRService ocrService;

  ScanReceiptUseCase(this.ocrService);

  Future<String> call(File image) async {
    return await ocrService.scanText(image);
  }
}
