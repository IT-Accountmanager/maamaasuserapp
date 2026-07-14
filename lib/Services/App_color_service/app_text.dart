import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colours.dart';

class AppText {
  AppText._();

  /// Large display — app name / hero headings
  static TextStyle get display1 => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    height: 1.15,
    color: Colors.black,
  );

  /// Section headings
  static TextStyle get heading => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.25,
    color: Colors.black,
  );

  /// Sub-headings / card titles
  static TextStyle get subheading => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: Colors.black87,
  );

  /// Body copy
  static TextStyle get body => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Colors.black87,
  );

  /// Small labels / captions
  static TextStyle get caption => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: Colors.black54,
  );

  /// Bold label (buttons, tags)
  static TextStyle get label => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: Colors.black87,
  );

  static TextStyle h1({Color? color}) => TextStyle(
    fontFamily: 'serif',
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    color: color ?? AppColors.textH,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle h2({Color? color}) => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.textH,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle menubody({Color? color, double? size}) => TextStyle(
    fontSize: size ?? 14.sp,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.textB,
    height: 1.5,
  );

  static TextStyle menulabel({Color? color, double? size}) => TextStyle(
    fontSize: size ?? 12.sp,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.textS,
    letterSpacing: 0.2,
  );

  static TextStyle price({Color? color}) => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w800,
    color: color ?? AppColors.green,
    letterSpacing: -0.3,
  );
}
