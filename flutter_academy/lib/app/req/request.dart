import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseURL = "http://127.0.0.1:5000";
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

    return response.statusCode == 201;
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
    final Uri url = Uri.parse(baseURL + apiURL);
    final Uri uriWithParams = url.replace(queryParameters: queryParams);

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

    return response.statusCode == 201 || response.statusCode == 204;
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  } catch (_) {
    return null;
  }
}
