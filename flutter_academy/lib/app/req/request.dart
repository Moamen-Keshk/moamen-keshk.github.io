import 'dart:convert';
import 'package:http/http.dart' as http;

const baseURL = "http://127.0.0.1:5000";
List<Object> resData = [];

Future<bool> sendPostRequest(
    Map<String, dynamic> body, String? idToken, String apiURL) async {
  try {
    final response = await http.post(
      Uri.parse('$baseURL$apiURL'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken"
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 201;
  } catch (e) {
    return false;
  }
}

Future<dynamic> sendGetRequest(idToken, String apiURL) async {
  try {
    final query = await http.get(
      Uri.parse(baseURL + apiURL),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
    );

    if (query.statusCode == 201) {
      var data = jsonDecode(query.body);
      return data;
    } else {
      return null;
    }
  } on Exception {
    return null;
  }
}

Future<dynamic> sendGetWithParamsRequest(
    idToken, String apiURL, Map<String, String?> queryParams) async {
  try {
    final url = Uri.parse(baseURL + apiURL);
    final uriWithParams = url.replace(queryParameters: queryParams);
    final query = await http.get(
      uriWithParams,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken"
      },
    );

    if (query.statusCode == 201) {
      var data = jsonDecode(query.body);
      return data;
    } else {
      return null;
    }
  } on Exception {
    return null;
  }
}

Future<bool> sendPutRequest(
    Map<String, dynamic> body, String? idToken, String apiURL) async {
  try {
    final response = await http.put(
      Uri.parse('$baseURL$apiURL'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 201 || response.statusCode == 204;
  } catch (e) {
    return false;
  }
}
