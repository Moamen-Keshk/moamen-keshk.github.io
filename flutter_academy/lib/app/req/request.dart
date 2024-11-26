import 'dart:convert';
import 'package:http/http.dart' as http;

const baseURL = "http://127.0.0.1:5000";
List<Object> resData = [];

Future<bool> sendPostRequest(body, String? idToken, String apiURL) async {
  try {
    var response = await http.post(Uri.parse(baseURL + apiURL),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken"
        },
        body: jsonEncode(body));

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } on Exception {
    return false;
  }
}

Future<dynamic> sendGetRequest(idToken, String apiURL) async {
  try {
    final query = await http.get(
      Uri.parse(baseURL + apiURL),
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
