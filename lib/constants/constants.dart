import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  static final AppConstants _instance = AppConstants._internal();

  factory AppConstants() {
    return _instance;
  }

  AppConstants._internal();

  final String meldRxGetToken = "connect/token";

  final String clientID = "5067edab24f8434a864d6cc3ead1a154";
  final String meldRxWorkspaceURL =
      "https://app.meldrx.com/api/fhir/1e1c103d-2d8a-4eb0-a76c-582f77b17986";
  final String meldRxScopes =
      "openid profile launch offline_access user/*.read user/*.* patient/*.* patient/*.read patient/ServiceRequest.read patient/Device.write patient/DiagnosticReport.write patient/Observation.write patient/Patient.read";

  final String redirectUri = "https://mary.seecole.app/callback";

  final String query = "query?";

  String? _meldRxCodeVerifier;
  String? get meldRxCodeVerifier => _meldRxCodeVerifier;
  void setmeldRxCodeVerifier(String? s) => _meldRxCodeVerifier = s;

  String? _meldRxCodeVerifierSHA256Encoded;
  String? get meldRxCodeVerifierSHA256Encoded =>
      _meldRxCodeVerifierSHA256Encoded;
  void setmeldRxCodeVerifierSHA256Encoded(String? s) =>
      _meldRxCodeVerifierSHA256Encoded = s;

  String? _meldRxCode;
  String? get meldRxCode => _meldRxCode;
  void setmeldRxCode(String? s) => _meldRxCode = s;

  final String keyMeldRxAccessToken = "meldRxAccessToken";
  String? _meldRxAccessToken;
  String? get meldRxAccessToken => _meldRxAccessToken;
  void setMeldRxAccessToken(String? token) {
    _meldRxAccessToken = token;
    // if (isSharedPreferencesInitialized) {
    //   _sharedPreferences?.setString(keyMeldRxAccessToken, token ?? "");
    // }
  }

  final String keyMeldRxIdToken = "meldRxIdToken";
  String? _meldRxIdToken;
  String? get meldRxIdToken => _meldRxIdToken;
  void setmeldRxIdToken(String? s) {
    _meldRxIdToken = s;
    // if (isSharedPreferencesInitialized) {
    //   _sharedPreferences?.setString(keyMeldRxIdToken, s ?? "");
    // }
  }

  final String keyMeldRxRefreshToken = "meldRxrefreshToken";
  String? _meldRxRefreshToken;
  String? get meldRxRefreshToken => _meldRxRefreshToken;
  void setmeldRxRefreshToken(String? s) {
    _meldRxRefreshToken = s;
    // if (isSharedPreferencesInitialized) {
    //   _sharedPreferences?.setString(keyMeldRxRefreshToken, s ?? "");
    // }
  }

  final String keyMeldRxAccessTokenExpiry = "meldRxAccessTokenExpiry";
  DateTime? _meldRxAccessTokenExpiry;
  DateTime? get meldRxAccessTokenExpiry => _meldRxAccessTokenExpiry;
  void setMeldRxAccessTokenExpiry(DateTime? expiry) {
    _meldRxAccessTokenExpiry = expiry;

    // DateTime.now().add(Duration(seconds: seconds));

    if (isSharedPreferencesInitialized) {
      _sharedPreferences?.setString(
        keyMeldRxAccessTokenExpiry,
        meldRxAccessTokenExpiry.toString(),
      );
    }
  }

  bool get isMeldRxAccessTokenExpired {
    if (meldRxAccessTokenExpiry == null) {
      return true;
    }
    if (meldRxAccessTokenExpiry!.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  String? authURL;

  bool get isSharedPreferencesInitialized => _sharedPreferences != null;

  SharedPreferences? _sharedPreferences;

  initializeSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    // setMeldRxAccessToken(_sharedPreferences?.getString(keyMeldRxAccessToken));
    // setmeldRxIdToken(_sharedPreferences?.getString(keyMeldRxIdToken));
    // setmeldRxRefreshToken(_sharedPreferences?.getString(keyMeldRxRefreshToken));
    // setMeldRxAccessTokenExpiry(
    //   DateTime.tryParse(
    //     _sharedPreferences!.getString(keyMeldRxAccessTokenExpiry) ?? "",
    //   ),
    // );
  }
}
