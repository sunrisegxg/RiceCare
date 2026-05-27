import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/guidemodel.dart';

class GuideService {
  static const String diseaseUrl =
      "https://33c0-14-236-23-128.ngrok-free.app/api/v1/diseases";

  static const String plantingUrl =
      "https://33c0-14-236-23-128.ngrok-free.app/api/v1/plantings";

  static const String nutrientUrl =
      "https://33c0-14-236-23-128.ngrok-free.app/api/v1/nutrient";

  static Future<List<GuideModel>> fetchGuides() async {
    try {
      /// CALL 2 APIs
      final responses = await Future.wait([
        http.get(Uri.parse(diseaseUrl)),
        http.get(Uri.parse(plantingUrl)),
        http.get(Uri.parse(nutrientUrl)),
      ]);

      final diseaseResponse = responses[0];
      final plantingResponse = responses[1];
      final nutrientResponse = responses[2];

      List<GuideModel> allGuides = [];

      /// DISEASES
      if (diseaseResponse.statusCode == 200) {
        final diseaseData = jsonDecode(diseaseResponse.body);

        final List diseaseList = diseaseData['result'];

        allGuides.addAll(
          diseaseList.map((e) => GuideModel.fromJson(e)).toList(),
        );
      }

      /// PLANTINGS
      if (plantingResponse.statusCode == 200) {
        final plantingData = jsonDecode(plantingResponse.body);

        final List plantingList = plantingData['result'];

        allGuides.addAll(
          plantingList.map((e) => GuideModel.fromJson(e)).toList(),
        );
      }

      /// NUTRIENTS
      if (nutrientResponse.statusCode == 200) {
        final nutrientData = jsonDecode(nutrientResponse.body);

        final List nutrientList = nutrientData['result'];

        allGuides.addAll(
          nutrientList.map((e) => GuideModel.fromJson(e)).toList(),
        );
      }
      allGuides.shuffle();
      return allGuides;
    } catch (e) {
      throw Exception("Failed to load guides: $e");
    }
  }
}
