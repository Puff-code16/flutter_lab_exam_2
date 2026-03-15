import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ocr_service.dart';

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  String result = "";

  Future scanReceipt() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final ocr = OCRService();

    final text = await ocr.scanText(File(image.path));

    setState(() {
      result = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Receipt Scanner"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: scanReceipt,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Receipt"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
