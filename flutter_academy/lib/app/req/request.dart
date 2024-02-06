import 'dart:convert';
import 'package:http/http.dart' as http;

const baseURL = "http://127.0.0.1:5000";

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
