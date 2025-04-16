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

  final String query = "?";
  final String conversationList = "conversation-list";
  final String conversation = "conversation";

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
  String? _meldRxAccessToken = "dWJ1bnR1OmFkbWlu";
  String? get meldRxAccessToken => _meldRxAccessToken;
  void setMeldRxAccessToken(String? token, [bool? setSharedPreferencesAlso]) {
    _meldRxAccessToken = token;
    if (setSharedPreferencesAlso != null && setSharedPreferencesAlso) {
      _sharedPreferences?.setString(keyMeldRxAccessToken, token ?? "");
    }
  }

  final String keyMeldRxIdToken = "meldRxIdToken";
  String? _meldRxIdToken;
  String? get meldRxIdToken => _meldRxIdToken;
  void setmeldRxIdToken(String? s, [bool? setSharedPreferencesAlso]) {
    _meldRxIdToken = s;
    if (setSharedPreferencesAlso != null && setSharedPreferencesAlso) {
      _sharedPreferences?.setString(keyMeldRxIdToken, s ?? "");
    }
    // if (isSharedPreferencesInitialized) {
    //
    // }
  }

  final String keyMeldRxRefreshToken = "meldRxrefreshToken";
  String? _meldRxRefreshToken;
  String? get meldRxRefreshToken => _meldRxRefreshToken;
  void setmeldRxRefreshToken(String? s, [bool? setSharedPreferencesAlso]) {
    _meldRxRefreshToken = s;
    if (setSharedPreferencesAlso != null && setSharedPreferencesAlso) {
      _sharedPreferences?.setString(keyMeldRxRefreshToken, s ?? "");
    }
  }

  final String keyMeldRxAccessTokenExpiry = "meldRxAccessTokenExpiry";
  DateTime? _meldRxAccessTokenExpiry;
  DateTime? get meldRxAccessTokenExpiry => _meldRxAccessTokenExpiry;
  void setMeldRxAccessTokenExpiry(
    DateTime? expiry, [
    bool? setSharedPreferencesAlso,
  ]) {
    _meldRxAccessTokenExpiry = expiry;

    // DateTime.now().add(Duration(seconds: seconds));

    if (setSharedPreferencesAlso != null && setSharedPreferencesAlso) {
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
    //TODO: remove
    return;

    // _sharedPreferences = await SharedPreferences.getInstance();

    // if (_sharedPreferences?.containsKey(keyMeldRxAccessToken) ?? false) {
    //   setMeldRxAccessToken(_sharedPreferences?.getString(keyMeldRxAccessToken));
    // }

    // if (_sharedPreferences?.containsKey(keyMeldRxIdToken) ?? false) {
    //   setmeldRxIdToken(_sharedPreferences?.getString(keyMeldRxIdToken));
    // }

    // if (_sharedPreferences?.containsKey(keyMeldRxRefreshToken) ?? false) {
    //   setmeldRxRefreshToken(
    //     _sharedPreferences?.getString(keyMeldRxRefreshToken),
    //   );
    // }

    // if (_sharedPreferences?.containsKey(keyMeldRxAccessTokenExpiry) ?? false) {
    //   setMeldRxAccessTokenExpiry(
    //     DateTime.tryParse(
    //       _sharedPreferences!.getString(keyMeldRxAccessTokenExpiry) ?? "",
    //     ),
    //   );
    // }
  }

  show() {
    print("abcd");
    print(_sharedPreferences?.getString(keyMeldRxAccessToken));
    print(_sharedPreferences?.getString(keyMeldRxRefreshToken));
    print(_sharedPreferences?.getString(keyMeldRxIdToken));
    print(_sharedPreferences?.getString(keyMeldRxAccessTokenExpiry));
  }
}
