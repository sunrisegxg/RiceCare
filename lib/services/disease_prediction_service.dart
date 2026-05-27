import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../models/predictionresultmode.dart';

class DiseasePredictionService {
  static const String baseUrl = 'http://143.198.199.41:8000';

  static Future<PredictionResult> predict(File imageFile) async {
    final uri = Uri.parse('$baseUrl/predict');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PredictionResult.fromJson(json);
    } else {
      throw Exception('Server Error');
    }
  }
}
