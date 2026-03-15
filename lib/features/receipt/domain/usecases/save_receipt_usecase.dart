import '../entities/receipt.dart';

class SaveReceiptUseCase {
  Future<void> call(Receipt receipt) async {
    // SaveReceiptUseCase should be connected to repository layer.
    // For now this is a placeholder to avoid print in production code.
    // Implement persistence in data/repository as needed.
  }
}
