import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_svg/svg.dart";
import "package:mary/models/conversation.dart";
import "package:mary/routing/router.dart";
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

chatBubble(ConversationPiece statement) {
  final br = Radius.circular(16.w);
  return Align(
    alignment:
        statement.role == ConversationRole.user
            ? Alignment.centerRight
            : Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.only(bottom: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(navKey.currentContext!).size.width * 0.8,
      ),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: MaryStyle().cadetGray, width: 1),
        borderRadius: BorderRadius.all(br),
      ),
      child: Text(
        statement.content,
        style: MaryStyle().white14w400.copyWith(fontWeight: FontWeight.w500),
        textAlign:
            statement.role == ConversationRole.user
                ? TextAlign.end
                : TextAlign.start,
      ),
    ),
  );
}
