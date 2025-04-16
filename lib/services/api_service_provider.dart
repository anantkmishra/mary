import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:developer' as dev;
import 'package:mary/routing/router.dart';
import 'package:mary/style/style.dart';

class ApiService {
  static final ApiService _instance = ApiService._();

  ApiService._();

  final Connectivity _connectivity = Connectivity();

  factory ApiService() {
    return _instance;
  }

  // final String baseURL = 'https://mary.seecole.app/query';
  final String baseURL = "https://maryintersystem.appzlogic.in/query";

  // final meldRxApiBaseURL = "https://app.meldrx.com/api/fhir";
  final meldRxBaseURL = "https://app.meldrx.com";

  String? _meldRxToken;
  String? get meldRxToken => _meldRxToken;
  void setMeldRxToken(String? token) {
    _meldRxToken = token;
  }

  Future getRequest(
    String url, {
    bool isMeldRxRequest = false,
    bool checkConnectivity = false,
  }) async {
    try {
      if (checkConnectivity) {
        if (!(await _checkFullConnectivity())) {
          urOfflineSnackBar();
          throw Exception("Could not fetch data !!!");
        }
      }

      url = isMeldRxRequest ? "$meldRxBaseURL/$url" : "$baseURL/$url";
      final Response response = await get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json",
        },
      );
      dev.log(
        "$url ${response.statusCode} ${response.body.length}\nResponse Body : ${response.body}",
        name: "getRequest",
      );
      return jsonDecode(response.body);
    } catch (e) {
      dev.log(url, name: "GET API REQ ERROR", time: DateTime.now(), error: e);
      rethrow;
    }
  }

  Future postRequest(
    String url, {
    Map<String, dynamic>? body,
    bool isMeldRxRequest = false,
    bool checkConnectivity = false,
  }) async {
    try {
      if (checkConnectivity) {
        if (!(await _checkFullConnectivity())) {
          urOfflineSnackBar();
          throw Exception("Could not fetch data !!!");
        }
      }
      url = isMeldRxRequest ? "$meldRxBaseURL/$url" : "$baseURL$url";

      final Response response = await post(
        Uri.parse(url),
        body: body,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json",
        },
      );
      dev.log(
        "$url ${response.statusCode} ${response.body.length}\nRequest Body : $body \nResponse Body : ${response.body}",
        name: "postRequest",
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

  Future<bool> _checkNetworkConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return true;
      } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return true;
      } else if (connectivityResult.contains(ConnectivityResult.other)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      dev.log(e.toString(), name: "ApiService > _checkConnectivity() > Error");
      return false;
    }
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        return true; // Internet is available
      }
    } catch (e) {
      dev.log("Offline", name: "checkInternetConnectivity Error", error: e);
    }
    return false; // No internet access
  }

  Future<bool> _checkFullConnectivity() async {
    bool isNetworkConnected = await _checkNetworkConnectivity();
    if (!isNetworkConnected) {
      return false; // No network connection
    }
    bool isInternetAvailable = await _checkInternetConnectivity();
    return isInternetAvailable;
  }

  urOfflineSnackBar() {
    ScaffoldMessenger.of(navKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text("You are offline!", style: MaryStyle().white16w500),
        backgroundColor: Colors.red,
      ),
    );
  }
}
