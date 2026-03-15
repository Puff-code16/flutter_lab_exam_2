import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OCRService {
  final Dio _dio = Dio();

  Future<String> scanText(File image) async {
    // ถ้าเป็น Windows/macOS/Linux ให้ใช้ OCR API จากคลาวด์
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return _recognizeTextViaCloudVision(image);
    }

    // บน Android/iOS อาจใช้ API เดียวกันเพื่อความสเถียร
    return _recognizeTextViaCloudVision(image);
  }

  Future<String> _recognizeTextViaCloudVision(File image) async {
    final apiKey = dotenv.env['GOOGLE_VISION_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      final fromOcrSpace = await _recognizeTextViaOcrSpace(image);
      if (fromOcrSpace.isNotEmpty) {
        return fromOcrSpace;
      }
      throw Exception(
          'GOOGLE_VISION_API_KEY และ OCR_SPACE_API_KEY ไม่ได้นำเข้าจาก .env');
    }

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

    try {
      final resp = await _dio.post(url, data: {
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'TEXT_DETECTION', 'maxResults': 1},
            ],
            'imageContext': {
              'languageHints': ['th', 'en'],
            },
          }
        ]
      });

      final annotations = resp.data['responses']?[0]?['textAnnotations'];
      if (annotations is List && annotations.isNotEmpty) {
        return annotations[0]['description'] ?? '';
      }
      return '';
    } catch (e) {
      debugPrint('OCR CloudVision failed: $e');
      return await _recognizeTextViaOcrSpace(image);
    }
  }

  Future<List<String>> scanBarcode(File image) async {
    // เป็น placeholder เพื่อให้โค้ดสามารถรันได้ในทุก platform
    // ถ้าต้องการ ให้เพิ่ม OCR API สำหรับ Barcode หรือใช้ local ML Kit ใน mobile
    return [];
  }

  Future<int> detectFaces(File image) async {
    // เป็น placeholder เพื่อให้โค้ดสามารถรันได้ในทุก platform
    // ถ้าต้องการ ให้เพิ่ม OCR API สำหรับ Face Detection หรือใช้ local ML Kit ใน mobile
    return 0;
  }

  Future<String> _recognizeTextViaOcrSpace(File image) async {
    var apiKey = dotenv.env['OCR_SPACE_API_KEY']?.trim();
    // ใช้คีย์ตัวอย่าง (demo) ถ้าไม่มีคีย์ใน .env
    apiKey = apiKey == null || apiKey.isEmpty ? 'helloworld' : apiKey;

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final resp = await _dio.post(
        'https://api.ocr.space/parse/image',
        data: FormData.fromMap({
          'apikey': apiKey,
          'base64Image': 'data:image/jpeg;base64,$base64Image',
          'OCREngine': 2,
          'language': 'tha',
        }),
      );

      if (resp.statusCode != 200) {
        debugPrint('OCR Space HTTP error: ${resp.statusCode}');
        return '';
      }

      final parsedRes = resp.data['ParsedResults'];
      if (parsedRes is List && parsedRes.isNotEmpty) {
        return parsedRes[0]['ParsedText'] ?? '';
      }

      debugPrint('OCR Space no parsed text in response');
      return '';
    } catch (e) {
      debugPrint('OCR Space failed: $e');
      return '';
    }
  }
}
