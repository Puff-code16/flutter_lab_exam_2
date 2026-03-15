import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final Dio _dio = Dio();

  // ฟังก์ชันส่งข้อความจาก ML Kit ไปให้ Gemini สรุป
  Future<String> getReceiptSummary(String rawText) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";

    try {
      final response = await _dio.post(url, data: {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "สวมบทบาทเป็นผู้ช่วยบัญชี สรุปข้อมูลจากข้อความใบเสร็จนี้: $rawText โดยให้คืนค่าเป็นภาษาไทยในรูปแบบ ชื่อร้าน, ราคาสุทธิ, และวันที่"
              }
            ]
          }
        ]
      });

      // ดึงคำตอบจาก AI
      return response.data['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      return "เชื่อมต่อ AI ไม่สำเร็จ: $e";
    }
  }
}
