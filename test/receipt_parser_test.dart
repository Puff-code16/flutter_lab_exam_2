import 'package:flutter_test/flutter_test.dart';
import 'package:ai_receipt_tracker/core/utils/receipt_parser.dart';

void main() {
  test('ReceiptParser should parse total from text with 4-digit amount', () {
    const text = 'Some store\nTotal 1234.56\nVAT 92.32';
    final receipt = ReceiptParser.parse(text);

    expect(receipt.total, 1234.56);
    expect(receipt.vat, 92.32);
  });

  test('ReceiptParser should fallback to items sum when total line missing',
      () {
    const text = '''
Item A 100.00
Item B 200.00
VAT 9.00
''';
    final receipt = ReceiptParser.parse(text);

    expect(receipt.total, 300.00);
    expect(receipt.vat, 9.00);
  });
}
