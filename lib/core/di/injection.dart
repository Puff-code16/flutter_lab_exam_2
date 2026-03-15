import 'package:get_it/get_it.dart';

import '../services/ocr_service.dart';

import '../../features/receipt/domain/usecases/save_receipt_usecase.dart';
import '../../features/receipt/domain/usecases/scan_receipt_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// SERVICE
  sl.registerLazySingleton<OCRService>(() => OCRService());

  /// USECASE
  sl.registerLazySingleton<ScanReceiptUseCase>(
    () => ScanReceiptUseCase(sl()),
  );

  sl.registerLazySingleton<SaveReceiptUseCase>(
    () => SaveReceiptUseCase(),
  );
}
