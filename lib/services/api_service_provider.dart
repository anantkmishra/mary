import 'dart:convert';

import 'package:http/http.dart';
import 'dart:developer' as dev;

class ApiService {
  static final ApiService _instance = ApiService._();

  ApiService._();

  factory ApiService() {
    return _instance;
  }

  final baseURL = 'https://mary.seecole.app';

  // final meldRxApiBaseURL = "https://app.meldrx.com/api/fhir";
  final meldRxBaseURL = "https://app.meldrx.com";

  String? _meldRxToken;
  String? get meldRxToken => _meldRxToken;
  void setMeldRxToken(String? token) {
    _meldRxToken = token;
  }

  Future<Map<String, dynamic>> getRequest(
    String url, {
    bool isMeldRxRequest = false,
  }) async {
    try {
      url = isMeldRxRequest ? "$meldRxBaseURL/$url" : "$baseURL/$url";
      final Response response = await get(Uri.parse(url));
      return jsonDecode(response.body);
    } catch (e) {
      dev.log(url, name: "GET API REQ ERROR", time: DateTime.now(), error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postRequest(
    String url, {
    Map<String, dynamic>? body,
    bool isMeldRxRequest = false,
  }) async {
    try {
      url = isMeldRxRequest ? "$meldRxBaseURL/$url" : "$baseURL/$url";

      final Response response = await post(
        Uri.parse(url),
        body: body,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      );
      dev.log(
        "$url ${body} ${response.statusCode} ${response.body.length} ${response.body}",
        name: "response body",
      );
      return jsonDecode(response.body);
    } catch (e) {
      dev.log(
        "$url\nBODY: $body",
        name: "POST API REQ ERROR",
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }
}
