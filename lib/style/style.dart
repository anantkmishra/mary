import 'package:flutter/material.dart';

class MaryStyle {
  static final MaryStyle _instance = MaryStyle._();

  MaryStyle._();

  factory MaryStyle() {
    return _instance;
  }

  //colors
  final Color darkBg = Color(0xFF0E1520);
  final Color persianBlue = Color(0xFF2D26B2);
  final Color vividCrulian = Color(0xFF00A7FF);
  final Color palatinateBlue = Color(0xFF0D45DF);
  final Color white = Color(0xFFFFFFFF);
  final Color black = Color(0xFF000000);
  final Color cadetGray = Color(0xFF94A3B8);
  final Color jetBlack = Color(0xFF363636);
  final Color lightSilver = Color(0xFFD9D9D9);
  final Color cardBG = Color(0x4D434343);
  final Color gunmetal = Color(0xFF272C35);

  //textStyles
  TextStyle get grey16w500 => TextStyle(
    color: Color(0xFF999999),
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  TextStyle get white20w500 => TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  TextStyle get white14w400 =>
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: white);

  TextStyle get white12w400 =>
      TextStyle(color: white, fontSize: 12, fontWeight: FontWeight.w400);

  TextStyle get white16w500 => TextStyle(color: white, fontSize: 16);

  //buttonStyle

  //iconButtoStyle
  ButtonStyle get jetBlackRoundIconButtonStyle => IconButton.styleFrom(
    shape: CircleBorder(side: BorderSide(color: jetBlack, width: 1)),
    backgroundColor: lightSilver.withAlpha(0x1A),
  );
}
