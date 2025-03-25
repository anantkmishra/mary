import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:mary/style/style.dart";

Widget svgAssetImageWidget(
  String image, {
  double? height,
  double? width,
  Color? color,
}) {
  return SvgPicture.asset(
    image,
    height: height,
    width: width,
    colorFilter:
        color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
  );
}

Widget roundIconButton({
  required GestureTapCallback onTap,
  required String icon,
}) {
  return ClipOval(
    child: InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MaryStyle().lightSilver.withAlpha(0x1A),
          border: Border.all(color: MaryStyle().jetBlack, width: 1),
        ),
        alignment: Alignment.center,
        child: svgAssetImageWidget(
          icon,
          height: 24,
          width: 24,
          color: MaryStyle().white,
        ),
      ),
    ),
  );
}
