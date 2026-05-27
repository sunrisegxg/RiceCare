import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../services/google_auth_service.dart';
import '../services/token_service.dart';

class AuthRepository {
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(
        "https://33c0-14-236-23-128.ngrok-free.app/authen",
      ), //nhớ đổi IP nếu cần
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data["result"] != null &&
        data["result"]["authenticated"] == true) {
      final token = data["result"]["token"];
      final userId = data["result"]["idFE"];

      await TokenService.save(token);
      await TokenService.saveUserId(userId);
      return true;
    }

    return false;
  }

  Future<bool> register({
    required String username,
    required String password,
    required String dob,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://33c0-14-236-23-128.ngrok-free.app/api/v1/users/signup",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "dob": dob,
          "role": ["USER"],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["code"] == 1000) {
        final idFE = data["result"]["idFE"];

        log("ID FE: $idFE");

        await TokenService.saveUserId(idFE);

        return true;
      }

      return false;
    } catch (e) {
      log("REGISTER ERROR: $e");
      return false;
    }
  }

  Future<void> logoutFlow(String token) async {
    await GoogleAuthService().signOutGoogle(); // nếu có login Google

    await http.post(
      Uri.parse("https://33c0-14-236-23-128.ngrok-free.app/authen/logout"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"token": token}),
    );

    await TokenService.clear();
  }

  Future<bool> loginWithGoogle(String idToken) async {
    try {
      final url =
          "https://33c0-14-236-23-128.ngrok-free.app/autheng/api/v1/auth/google";

      log("========== GOOGLE LOGIN ==========");
      log("URL: $url");

      log("ID TOKEN: $idToken");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );

      log("STATUS: ${response.statusCode}");
      log("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      log("PARSED DATA: $data");

      if (response.statusCode == 200) {
        final result = data["result"];

        log("RESULT: $result");

        if (result != null && result["authenticated"] == true) {
          final token = result["token"];
          final userId = result["idFE"];

          log("TOKEN: $token");
          log("USER ID: $userId");

          await TokenService.save(token);
          await TokenService.saveUserId(userId);

          log("GOOGLE LOGIN SUCCESS");

          return true;
        } else {
          log("AUTHENTICATED FALSE");
        }
      } else {
        log("REQUEST FAILED");
      }

      return false;
    } catch (e, stackTrace) {
      log("GOOGLE LOGIN ERROR: $e");
      log("STACK TRACE: $stackTrace");

      return false;
    }
  }
}
