import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
}
