import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ocr_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;
  String result = "";
  bool loading = false;

  Future scanReceipt() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    final file = File(image.path);

    setState(() {
      imageFile = file;
      loading = true;
      result = "";
    });

    try {
      final ocr = OCRService();

      final text = await ocr.scanText(file);

      setState(() {
        result = text;
        loading = false;
      });
    } catch (e) {
      setState(() {
        result = "OCR Error: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Receipt Scanner"),
        centerTitle: true,
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
            if (imageFile != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Image.file(
                  imageFile!,
                  height: 220,
                ),
              ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
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
                  child: Text(
                    result.isEmpty ? "OCR result will appear here" : result,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
