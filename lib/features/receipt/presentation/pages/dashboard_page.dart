import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../core/utils/receipt_parser.dart';
import '../../data/datasources/receipt_local_datasource.dart';
import '../../data/models/receipt_model.dart';
import '../widgets/receipt_card.dart';

class DashboardPage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const DashboardPage({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  final ReceiptLocalDatasource _datasource = ReceiptLocalDatasource();

  File? _image;
  String? _imagePath;
  List<String> _barcodes = [];
  int _faceCount = 0;
  bool _loading = false;

  // ข้อมูลใบเสร็จที่สแกนล่าสุด
  String _store = 'Unknown';
  double _total = 0;
  double _vat = 0;
  double _tax = 0;
  String _date = '';
  String _category = 'Expense';

  List<ReceiptModel> _receipts = [];

  @override
  void initState() {
    super.initState();
    _refreshReceipts();
  }

  Future<void> _refreshReceipts() async {
    final rows = await _datasource.getReceipts();
    setState(() {
      _receipts = rows
          .map((e) => ReceiptModel.fromMap(e))
          .where((r) => r.id != null)
          .toList()
        ..sort((a, b) => a.id!.compareTo(b.id!));
    });
  }

  double get _totalIncome => _receipts
      .where((r) => r.category.toLowerCase() == 'income')
      .fold(0.0, (sum, r) => sum + r.total);

  double get _totalExpense => _receipts
      .where((r) => r.category.toLowerCase() != 'income')
      .fold(0.0, (sum, r) => sum + r.total);

  Future<void> _deleteReceipt(int id) async {
    await _datasource.deleteReceipt(id);
    await _refreshReceipts();
  }

  Future<void> _confirmDeleteReceipt(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจว่าจะลบสลิปนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteReceipt(id);
    }
  }

  Future<void> _scanReceipt() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _loading = true;
      _image = File(picked.path);
      _barcodes = [];
      _faceCount = 0;
    });

    try {
      final text = await _ocrService.scanText(_image!);
      final barcodeData = await _ocrService.scanBarcode(_image!);
      final faces = await _ocrService.detectFaces(_image!);

      final receipt = ReceiptParser.parse(text);

      setState(() {
        _imagePath = _image?.path;
        _barcodes = barcodeData;
        _faceCount = faces;
        _store = receipt.store;
        _total = receipt.total;
        _vat = receipt.vat ?? 0;
        _tax = receipt.tax ?? 0;
        _date = receipt.date;
        _category = receipt.category;
      });

      await _datasource.insertReceipt({
        'store': receipt.store,
        'total': receipt.total,
        'vat': receipt.vat,
        'tax': receipt.tax,
        'imagePath': _imagePath,
        'date': receipt.date,
        'category': receipt.category,
      });

      await _refreshReceipts();
    } catch (e) {
      debugPrint('Scan Error: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Receipt Tracker'),
        actions: [
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: widget.onThemeToggle,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload and Scan Receipt'),
              onPressed: _loading ? null : _scanReceipt,
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            if (_image != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preview รูปล่าสุด:'),
                  const SizedBox(height: 8),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            const SizedBox(height: 12),
            Text('Store: $_store',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Total: ${_total.toStringAsFixed(2)} THB'),
            if (_vat > 0) Text('VAT: ${_vat.toStringAsFixed(2)} THB'),
            if (_tax > 0) Text('Service Tax: ${_tax.toStringAsFixed(2)} THB'),
            Text('Date: ${_date.isEmpty ? 'Unknown' : _date}'),
            Text('Category: $_category'),
            const SizedBox(height: 8),
            if (_receipts.length > 1) ...[
              const Divider(),
              const Text('ข้อมูลของสลิปที่ 2 (จากฐานข้อมูล):',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Store: ${_receipts[1].store}'),
              Text('Total: ${_receipts[1].total.toStringAsFixed(2)} THB'),
              if ((_receipts[1].vat ?? 0) > 0)
                Text('VAT: ${(_receipts[1].vat ?? 0).toStringAsFixed(2)} THB'),
              if ((_receipts[1].tax ?? 0) > 0)
                Text('TAX: ${(_receipts[1].tax ?? 0).toStringAsFixed(2)} THB'),
              Text(
                  'Date: ${_receipts[1].date.isEmpty ? 'Unknown' : _receipts[1].date}'),
              Text('Category: ${_receipts[1].category}'),
              const SizedBox(height: 8),
            ],
            if (_barcodes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Barcodes:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._barcodes.map((e) => Text('• $e')),
                ],
              ),
            if (_faceCount > 0) Text('Faces detected: $_faceCount'),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Summary',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.black87)),
                    Text('รายการทั้งหมด: ${_receipts.length}',
                        style: const TextStyle(color: Colors.black87)),
                    Text(
                        'รายรับทั้งหมด: ${_totalIncome.toStringAsFixed(2)} THB',
                        style: const TextStyle(color: Colors.green)),
                    Text(
                        'รายจ่ายทั้งหมด: ${_totalExpense.toStringAsFixed(2)} THB',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Receipt history',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (_receipts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('ยังไม่มีบันทึกสลิป')),
              )
            else
              // แก้ Error: missing title และ onDelete
              ..._receipts.asMap().entries.map((entry) {
                final index = entry.key;
                final receipt = entry.value;
                return ReceiptCard(
                  receipt: receipt,
                  title: 'บิลที่ ${index + 1}',
                  onDelete: _confirmDeleteReceipt,
                );
              }),
          ],
        ),
      ),
    );
  }
}
