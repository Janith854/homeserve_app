import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─── COLORS ────────────────────────────────────────────────────────────────
/// Maps every CSS :root variable from the HTML prototype.
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF0F6B5C);
  static const Color primaryDark = Color(0xFF0B5347);
  static const Color primaryLight = Color(0xFFE4F2EF);

  // Accent
  static const Color accent = Color(0xFFF2A93B);

  // Backgrounds & surfaces
  static const Color bg = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color text = Color(0xFF1F2937);
  static const Color muted = Color(0xFF6B7280);
  static const Color textLight = muted;

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFD64545);

  // Border
  static const Color border = Color(0xFFE7E5DF);

  // Hard-coded extras from prototype
  static const Color warningBannerBg = Color(0xFFFBEAEA);
  static const Color warningBannerText = Color(0xFF8A2F2F);
  static const Color severityMedBg = Color(0xFFFBF3E4);
  static const Color severityMedText = Color(0xFF8A5A10);

  // Onboarding illustration backgrounds
  static const Color onboard1Bg = Color(0xFFF6E9DC);
  static const Color onboard2Bg = Color(0xFFFBF3E4);
  static const Color onboard3Bg = Color(0xFFE4F0F6);

  // Photo placeholder gradient
  static const Color photoGradientEnd = Color(0xFFCFE6E0);
}

/// ─── TEXT STYLES ────────────────────────────────────────────────────────────
/// Poppins for headings/buttons, Inter for body — exact sizes/weights from CSS.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get body => fieldFilled;
  static TextStyle get small => meta;
  static TextStyle get btn => button;
  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryDark,
  );

  // ── Poppins styles ──

  /// h1: 26px, bold (browser default for h1)
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  /// .member-title: 20px, w400 (normal — no font-weight override in CSS)
  static TextStyle memberTitle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryDark,
  );

  /// .onboard-title: 18px, w700
  static TextStyle onboardTitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  /// .appbar .title: 15px, w600
  static TextStyle appBarTitle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  /// .totalrow: 14px, w700
  static TextStyle totalRow = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  /// .statbox .num: 18px, w700
  static TextStyle statNumber = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  /// .btn: 13px, w600
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// .btn.small: 11.5px, w600
  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // ── Inter styles ──

  /// .name: 13px, w700
  static TextStyle name = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  /// .searchbar: 13px, w400
  static TextStyle searchBar = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// .chip: 12px, w500
  static TextStyle chip = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  /// .field: 12.5px, w400
  static TextStyle field = GoogleFonts.inter(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// .field.filled: same size but text color
  static TextStyle fieldFilled = GoogleFonts.inter(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  /// .tab: 11.5px, w600
  static TextStyle tab = GoogleFonts.inter(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  /// .link: 12px, w600
  static TextStyle link = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  /// .meta: 11px, w400
  static TextStyle meta = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// .notiftitle: 12px, w700
  static TextStyle notifTitle = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  /// .notifsub: 10.5px, w400
  static TextStyle notifSub = GoogleFonts.inter(
    fontSize: 10.5,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// .notiftime: 9px, w400
  static TextStyle notifTime = GoogleFonts.inter(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// .onboard-sub: 12px, w400
  static TextStyle onboardSub = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.5,
  );

  /// .navitem: 9.5px, w400 (active = w700)
  static TextStyle navItem = GoogleFonts.inter(
    fontSize: 9.5,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static TextStyle navItemActive = GoogleFonts.inter(
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  /// .statusbar: 11px, w600
  static TextStyle statusBar = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  /// .price: 12px, w700
  static TextStyle price = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  /// .steplabels: 9px, w400
  static TextStyle stepLabel = GoogleFonts.inter(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// .step (number): 11px, w700
  static TextStyle stepNumber = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.muted,
  );

  /// .statbox .lbl: 10px, w400
  static TextStyle statLabel = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// .sevtag: 9.5px, w700
  static TextStyle severityTag = GoogleFonts.inter(
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
  );

  /// .rowsplit: 12px, w400
  static TextStyle rowSplit = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  /// .warnbanner: 11.5px, w600
  static TextStyle warnBanner = GoogleFonts.inter(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.warningBannerText,
  );

  /// .checklist div: 12px, w400
  static TextStyle checklist = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  /// .badge-verified: 11px, w700
  static TextStyle badgeVerified = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );
}

/// ─── SPACING ───────────────────────────────────────────────────────────────
/// Common spacing values extracted from CSS paddings and gaps.
class AppSpacing {
  AppSpacing._();

  static const double xs = 2;
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 10;
  static const double xxl = 12;
  static const double xxxl = 14;
  static const double x4l = 16;
  static const double x5l = 20;
  static const double x6l = 24;
  static const double x7l = 32;
}

/// ─── RADIUS ────────────────────────────────────────────────────────────────
/// Border-radius values from CSS classes.
class AppRadius {
  AppRadius._();

  static const double checkbox = 4;        // .checkbox
  static const double severityTag = 8;     // .sevtag, .calendargrid .day
  static const double btnSmall = 10;       // .btn.small, .tab, .photo
  static const double btn = 12;            // .btn, .field, .statbox, .warnbanner
  static const double card = 14;           // .card, .searchbar, .mapbox
  static const double onboardPhoto = 18;   // .onboard-photo
  static const double pill = 20;           // .chip, .badge-verified, .toggle, .screen-tag
  static const double screen = 24;         // .screen
}

/// ─── ICON SIZES ────────────────────────────────────────────────────────────
class AppIconSize {
  AppIconSize._();

  static const double badgeVerified = 12;
  static const double star = 13;
  static const double standard = 18;
  static const double nav = 19;
  static const double starLarge = 26;
  static const double onboard = 64;
}

/// ─── SHADOWS ───────────────────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  /// Phone frame shadow — usable for elevated cards
  static const List<BoxShadow> cardElevated = [
    BoxShadow(
      color: Color(0x2E000000), // rgba(0,0,0,0.18)
      blurRadius: 30,
      offset: Offset(0, 14),
    ),
  ];

  /// Toggle knob shadow
  static const List<BoxShadow> toggleKnob = [
    BoxShadow(
      color: Color(0x4D000000), // rgba(0,0,0,0.3)
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];
}
