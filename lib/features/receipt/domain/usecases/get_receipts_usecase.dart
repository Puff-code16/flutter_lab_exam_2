import '../repositories/receipt_repository.dart';

class GetReceiptsUseCase {

  final ReceiptRepository repository;

  GetReceiptsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getReceipts();
  }

}