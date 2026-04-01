import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

// 1. DYNAMIC BASE URL FIX
// Automatically uses the correct localhost IP depending on the device running the app
String getBaseUrl() {
  if (kIsWeb) {
    return "http://127.0.0.1:5000";
  } else if (Platform.isAndroid) {
    return "http://10.0.2.2:5000"; // Android Emulator host IP
  } else {
    return "http://127.0.0.1:5000"; // iOS Simulator or Desktop
  }
}

final String baseURL = getBaseUrl();
final List<Object> resData = <Object>[];

Future<bool> sendPostRequest(
  Map<String, dynamic> body,
  String? idToken,
  String apiURL,
) async {
  try {
    final http.Response response = await http.post(
      Uri.parse('$baseURL$apiURL'),
      headers: <String, String>{
        "Content-Type": "application/json",
        if (idToken != null) "Authorization": "Bearer $idToken",
      },
      body: jsonEncode(body),
    );

    // 2. STATUS CODE FIX: Accept 200 (OK) and 201 (Created)
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (_) {
    return false;
  }
}

Future<dynamic> sendGetRequest(String? idToken, String apiURL) async {
  try {
    final http.Response query = await http.get(
      Uri.parse(baseURL + apiURL),
      headers: <String, String>{
        "Content-Type": "application/json",
        if (idToken != null) "Authorization": "Bearer $idToken",
      },
    );

    if (query.statusCode == 200 || query.statusCode == 201) {
      final dynamic data = jsonDecode(query.body);
      return data;
    }
    return null;
  } on Exception {
    return null;
  }
}

Future<dynamic> sendGetWithParamsRequest(
  String? idToken,
  String apiURL,
  Map<String, String?> queryParams,
) async {
  try {
    // Clean out null values from queryParams, as Uri.replace doesn't like null strings
    final Map<String, dynamic> cleanParams = {}..addAll(queryParams);
    cleanParams.removeWhere((key, value) => value == null);

    final Uri url = Uri.parse(baseURL + apiURL);
    final Uri uriWithParams = url.replace(queryParameters: cleanParams);

    final http.Response query = await http.get(
      uriWithParams,
      headers: <String, String>{
        "Content-Type": "application/json",
        if (idToken != null) "Authorization": "Bearer $idToken",
      },
    );

    if (query.statusCode == 200 || query.statusCode == 201) {
      final dynamic data = jsonDecode(query.body);
      return data;
    }
    return null;
  } on Exception {
    return null;
  }
}

Future<bool> sendPutRequest(
  Map<String, dynamic> body,
  String? idToken,
  String apiURL,
) async {
  try {
    final http.Response response = await http.put(
      Uri.parse('$baseURL$apiURL'),
      headers: <String, String>{
        "Content-Type": "application/json",
        if (idToken != null) "Authorization": "Bearer $idToken",
      },
      body: jsonEncode(body),
    );

    // 2. STATUS CODE FIX: Added 200, as our backend returns 200 for successful PUTs
    return response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204;
  } catch (_) {
    return false;
  }
}

Future<dynamic> sendDeleteRequest(String? idToken, String apiURL) async {
  try {
    final http.Response response = await http.delete(
      Uri.parse('$baseURL$apiURL'),
      headers: <String, String>{
        "Content-Type": "application/json",
        if (idToken != null) "Authorization": "Bearer $idToken",
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      // Normalize successful DELETE responses so callers can safely read
      // the same shape even when the backend returns 204 No Content.
      if (response.body.isEmpty) {
        return {'status': 'success'};
      }
      return jsonDecode(response.body);
    }
    return null;
  } catch (_) {
    return null;
  }
}
