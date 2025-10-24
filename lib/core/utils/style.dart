import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

// TextStyle
TextStyle primaryRegularTextStyle = GoogleFonts.poppins(
  color: AppColors.primary,
  fontWeight: FontWeight.w400,
);

TextStyle primarySemiBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.primary,
  fontWeight: FontWeight.w600,
);

TextStyle primaryBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.primary,
  fontWeight: FontWeight.w700,
);

TextStyle mainRegularTextStyle = GoogleFonts.poppins(
  color: AppColors.main,
  fontWeight: FontWeight.w400,
);

TextStyle mainSemiBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.main,
  fontWeight: FontWeight.w600,
);

TextStyle mainBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.main,
  fontWeight: FontWeight.w700,
);

TextStyle blackRegularTextStyle = GoogleFonts.poppins(
  color: AppColors.black,
  fontWeight: FontWeight.w400,
);

TextStyle blackSemiBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.black,
  fontWeight: FontWeight.w600,
);

TextStyle blackBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.black,
  fontWeight: FontWeight.w700,
);

TextStyle whiteRegularTextStyle = GoogleFonts.poppins(
  color: Colors.white,
  fontWeight: FontWeight.w400,
);

TextStyle whiteSemiBoldTextStyle = GoogleFonts.poppins(
  color: Colors.white,
  fontWeight: FontWeight.w600,
);

TextStyle whiteBoldTextStyle = GoogleFonts.poppins(
  color: Colors.white,
  fontWeight: FontWeight.w700,
);

TextStyle greyRegularTextStyle = GoogleFonts.poppins(
  color: AppColors.grey,
  fontWeight: FontWeight.w400,
);

TextStyle greySemiBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.grey,
  fontWeight: FontWeight.w600,
);

TextStyle greyBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.grey,
  fontWeight: FontWeight.w700,
);

TextStyle hintRegularTextStyle = GoogleFonts.poppins(
  color: AppColors.hint,
  fontWeight: FontWeight.w400,
);

TextStyle hintSemiBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.hint,
  fontWeight: FontWeight.w600,
);

TextStyle hintBoldTextStyle = GoogleFonts.poppins(
  color: AppColors.hint,
  fontWeight: FontWeight.w700,
);

TextStyle montserratRegularTextStyle = GoogleFonts.montserrat(
  color: AppColors.black,
  fontWeight: FontWeight.w400,
);

TextStyle montserratSemiBoldTextStyle = GoogleFonts.montserrat(
  color: AppColors.black,
  fontWeight: FontWeight.w600,
);

TextStyle montserratBoldTextStyle = GoogleFonts.montserrat(
  color: AppColors.black,
  fontWeight: FontWeight.w700,
);

BoxShadow shadow = const BoxShadow(
  color: Colors.black12,
  blurRadius: 3,
  offset: Offset(0, 5),
);

BoxShadow textShadowWhite = const BoxShadow(
  color: Colors.white,
  blurRadius: 5,
  offset: Offset(0, 2),
);

BoxShadow textShadowMain = const BoxShadow(
  color: AppColors.main,
  blurRadius: 5,
  offset: Offset(0, 2),
);

const loadingSpinBlue = CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
  strokeWidth: 4.0,
);

const loadingSpinWhite = CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
  strokeWidth: 4.0,
);
