import '../../features/receipt/domain/entities/receipt.dart';

class ReceiptParser {
  /// จับตัวเลขเงิน
  static final RegExp moneyRegex = RegExp(r'\d{1,3}(?:,\d{3})*(?:\.\d{2})?');

  /// เงินรับสุทธิ
  static final RegExp netIncomeRegex =
      RegExp(r'เงินรับสุทธิ|net pay', caseSensitive: false);

  /// รวมรายได้
  static final RegExp totalIncomeRegex =
      RegExp(r'รวมรายได้|grand total|total income', caseSensitive: false);

  /// จำนวนเงิน
  static final RegExp amountRegex =
      RegExp(r'จำนวน|amount', caseSensitive: false);

  /// โอนเงิน
  static final RegExp transferRegex =
      RegExp(r'โอนเงินสำเร็จ|transfer|payment', caseSensitive: false);

  /// รายได้
  static final RegExp incomeRegex =
      RegExp(r'payslip|salary|เงินเดือน', caseSensitive: false);

  /// วันที่
  static final List<RegExp> dateRegex = [
    /// 25/08/2565
    RegExp(r'\d{2}/\d{2}/\d{4}'),

    /// 25/08/65
    RegExp(r'\d{2}/\d{2}/\d{2}'),

    /// 2024-03-12
    RegExp(r'\d{4}-\d{2}-\d{2}'),

    /// 15 ก.ย. 62
    RegExp(r'\d{1,2}\s*[ก-ฮA-Za-z\.]{2,6}\s*\d{2,4}'),

    /// 15 ก.ย. 62 20:23
    RegExp(r'\d{1,2}\s*[ก-ฮA-Za-z\.]{2,6}\s*\d{2,4}\s*\d{2}:\d{2}')
  ];

  static Receipt parse(String text) {
    text = text.replaceAll('฿', '').replaceAll('บาท', '');

    final lines = text.split('\n');

    String store = "Unknown";
    String date = "Unknown";
    String category = "Expense";

    double netIncome = 0;
    double totalIncome = 0;
    double amount = 0;
    double biggest = 0;

    for (var raw in lines) {
      final line = raw.trim();

      if (line.isEmpty) continue;

      final lower = line.toLowerCase();

      /// ---------- STORE ----------
      if (store == "Unknown") {
        if (!RegExp(r'\d').hasMatch(line) && line.length < 50) {
          store = line;
        }
      }

      /// ---------- DATE ----------
      if (date == "Unknown") {
        for (final reg in dateRegex) {
          final match = reg.firstMatch(line);

          if (match != null) {
            date = match
                .group(0)!
                .replaceAll("น.", "")
                .replaceAll(RegExp(r'\d{2}:\d{2}'), '')
                .trim();

            break;
          }
        }
      }

      /// ---------- CATEGORY ----------
      if (transferRegex.hasMatch(lower)) {
        category = "Expense";
      }

      if (incomeRegex.hasMatch(lower)) {
        category = "Income";
      }

      /// ---------- MONEY ----------
      final matches = moneyRegex.allMatches(line);

      for (final m in matches) {
        final rawNumber = m.group(0)!;

        /// กัน Transaction ID
        if (rawNumber.length > 12) continue;

        final clean = rawNumber.replaceAll(',', '');

        final value = double.tryParse(clean) ?? 0;

        /// เก็บค่าที่มากที่สุด
        if (value > biggest) {
          biggest = value;
        }

        /// เงินสุทธิ
        if (netIncomeRegex.hasMatch(lower)) {
          netIncome = value;
        }

        /// รวมรายได้
        if (totalIncomeRegex.hasMatch(lower)) {
          totalIncome = value;
        }

        /// จำนวนเงิน
        if (amountRegex.hasMatch(lower)) {
          amount = value;
        }
      }
    }

    /// ---------- PRIORITY ----------
    double total = 0;

    if (netIncome > 0) {
      total = netIncome;
      category = "Income";
    } else if (totalIncome > 0) {
      total = totalIncome;
      category = "Income";
    } else if (amount > 0) {
      total = amount;
    } else {
      total = biggest;
    }

    return Receipt(
      store: store,
      total: total,
      vat: 0,
      tax: 0,
      date: date,
      category: category,
    );
  }
}
