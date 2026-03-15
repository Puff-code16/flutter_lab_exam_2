import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ocr_service.dart';
import 'receipt_parser.dart';

class UploadReceiptPage extends StatefulWidget {
  const UploadReceiptPage({super.key});

  @override
  State<UploadReceiptPage> createState() => _UploadReceiptPageState();
}

class _UploadReceiptPageState extends State<UploadReceiptPage> {
  final ImagePicker picker = ImagePicker();
  final OCRService ocrService = OCRService();

  File? image;

  String store = "";
  double total = 0;
  double vat = 0;
  String date = "";

  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    image = File(picked.path);

    final text = await ocrService.scanText(image!);

    final receipt = ReceiptParser.parse(text);

    setState(() {
      store = receipt.store;
      total = receipt.total;
      vat = receipt.vat ?? 0;
      date = receipt.date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Receipt Scanner"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Upload Receipt"),
            ),
            const SizedBox(height: 20),
            if (image != null)
              Image.file(
                image!,
                height: 200,
              ),
            const SizedBox(height: 20),
            Text("Store : $store"),
            Text("Total : $total"),
            Text("VAT : $vat"),
            Text("Date : $date"),
          ],
        ),
      ),
    );
  }
}
