import 'dart:math';
import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================================
  // VKU Brand Colors - Primary Palette
  // ============================================================================
  
  // VKU Red - Primary color for CTAs and important actions
  static const Color vkuRed = Color(0xFFE31E24);
  static const Color vkuRed50 = Color(0xFFFCE4E5);
  static const Color vkuRed100 = Color(0xFFF9BCBE);
  static const Color vkuRed200 = Color(0xFFF59093);
  static const Color vkuRed300 = Color(0xFFF16368);
  static const Color vkuRed400 = Color(0xFFEE4147);
  static const Color vkuRed500 = Color(0xFFE31E24); // Base
  static const Color vkuRed600 = Color(0xFFD01B20);
  static const Color vkuRed700 = Color(0xFFB8171B);
  static const Color vkuRed800 = Color(0xFFA01317);
  static const Color vkuRed900 = Color(0xFF7A0C0F);
  
  // VKU Yellow - Secondary color for highlights and success states
  static const Color vkuYellow = Color(0xFFFFD100);
  static const Color vkuYellow50 = Color(0xFFFFFBE6);
  static const Color vkuYellow100 = Color(0xFFFFF4BF);
  static const Color vkuYellow200 = Color(0xFFFFED95);
  static const Color vkuYellow300 = Color(0xFFFFE66B);
  static const Color vkuYellow400 = Color(0xFFFFE04B);
  static const Color vkuYellow500 = Color(0xFFFFD100); // Base
  static const Color vkuYellow600 = Color(0xFFFFC700);
  static const Color vkuYellow700 = Color(0xFFFFBA00);
  static const Color vkuYellow800 = Color(0xFFFFAD00);
  static const Color vkuYellow900 = Color(0xFFFF9500);
  
  // VKU Navy - Tertiary color for headers and navigation
  static const Color vkuNavy = Color(0xFF2B3990);
  static const Color vkuNavy50 = Color(0xFFE5E7F3);
  static const Color vkuNavy100 = Color(0xFFBFC3E1);
  static const Color vkuNavy200 = Color(0xFF949BCD);
  static const Color vkuNavy300 = Color(0xFF6973B9);
  static const Color vkuNavy400 = Color(0xFF4856AA);
  static const Color vkuNavy500 = Color(0xFF2B3990); // Base
  static const Color vkuNavy600 = Color(0xFF263388);
  static const Color vkuNavy700 = Color(0xFF1F2C7D);
  static const Color vkuNavy800 = Color(0xFF192573);
  static const Color vkuNavy900 = Color(0xFF0F1861);
  
  // ============================================================================
  // Gradient Combinations
  // ============================================================================
  
  static const LinearGradient gradientRedToYellow = LinearGradient(
    colors: [vkuRed, vkuYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientYellowToNavy = LinearGradient(
    colors: [vkuYellow, vkuNavy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientRedToNavy = LinearGradient(
    colors: [vkuRed, vkuNavy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientNavyToRed = LinearGradient(
    colors: [vkuNavy, vkuRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Subtle gradients for backgrounds
  static const LinearGradient gradientRedSubtle = LinearGradient(
    colors: [vkuRed50, vkuRed100],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient gradientYellowSubtle = LinearGradient(
    colors: [vkuYellow50, vkuYellow100],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient gradientNavySubtle = LinearGradient(
    colors: [vkuNavy50, vkuNavy100],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ============================================================================
  // Semantic Colors (derived from VKU palette)
  // ============================================================================
  
  static const Color success = vkuYellow; // Success uses yellow
  static const Color successDark = vkuYellow700;
  static const Color successLight = vkuYellow100;
  
  static const Color warning = Color(0xFFFF9800); // Orange warning
  static const Color warningDark = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFE0B2);
  
  static const Color error = vkuRed; // Error uses red
  static const Color errorDark = vkuRed700;
  static const Color errorLight = vkuRed100;
  
  static const Color info = vkuNavy; // Info uses navy
  static const Color infoDark = vkuNavy700;
  static const Color infoLight = vkuNavy100;
  
  // ============================================================================
  // Neutral Colors
  // ============================================================================
  
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF616161);
  static const Color textLight = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  
  // ============================================================================
  // Subject Colors for Timetable (using VKU palette)
  // ============================================================================
  
  static const Color subjectRed = vkuRed50;
  static const Color subjectYellow = vkuYellow50;
  static const Color subjectNavy = vkuNavy50;
  static const Color subjectOrange = Color(0xFFFFF3E0);
  static const Color subjectPurple = Color(0xFFF3E5F5);
  static const Color subjectPink = Color(0xFFFCE4EC);
  
  // Spacing System (8dp base unit)
  static const double spaceXs = 4.0;   // 0.5x
  static const double spaceSm = 8.0;   // 1x
  static const double spaceMd = 16.0;  // 2x
  static const double spaceLg = 24.0;  // 3x
  static const double spaceXl = 32.0;  // 4x
  static const double space2xl = 40.0; // 5x
  static const double space3xl = 48.0; // 6x
  
  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  
  // Elevation
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: vkuRed,
        secondary: vkuYellow,
        tertiary: vkuNavy,
        error: error,
        onPrimary: Colors.white,
        onSecondary: textDark,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: textDark,
        surface: backgroundWhite,
        surfaceContainerHighest: backgroundGrey,
      ),
      scaffoldBackgroundColor: backgroundGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: vkuNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(
          size: 24,
        ),
      ),
      textTheme: const TextTheme(
        // Display styles - for large headings (optimized for Vietnamese)
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.25, // Better for Vietnamese diacritics
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.3,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.35,
          letterSpacing: 0,
        ),
        // Headline styles - for section headers
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.4,
          letterSpacing: 0.15,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.45,
          letterSpacing: 0.15,
        ),
        // Title styles - for card titles and list items
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.45,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.5,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.5,
          letterSpacing: 0.1,
        ),
        // Body styles - for main content (optimized for Vietnamese readability)
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.6, // Better line spacing for Vietnamese
          letterSpacing: 0.3,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.6,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textLight,
          fontFamily: 'Roboto',
          height: 1.55,
          letterSpacing: 0.3,
        ),
        // Label styles - for buttons and small text
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.45,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.45,
          letterSpacing: 0.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textLight,
          fontFamily: 'Roboto',
          height: 1.45,
          letterSpacing: 0.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vkuRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          elevation: elevationSm,
          shadowColor: Colors.black26,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vkuRed,
          side: const BorderSide(color: vkuRed, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: vkuRed,
          padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: vkuYellow,
          foregroundColor: textDark,
          padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          elevation: elevationSm,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: vkuRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceMd),
        hintStyle: const TextStyle(
          color: textLight,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: const TextStyle(
          color: textLight,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        floatingLabelStyle: const TextStyle(
          color: vkuRed,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: elevationSm,
        shadowColor: Colors.black12,
        color: backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundGrey,
        deleteIconColor: textLight,
        disabledColor: dividerColor,
        selectedColor: vkuRed.withValues(alpha: 0.1),
        secondarySelectedColor: vkuYellow.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundWhite,
        selectedItemColor: vkuRed,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: elevationMd,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: vkuYellow,
        foregroundColor: textDark,
        elevation: elevationMd,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: elevationMd,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundWhite,
        elevation: elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
          fontFamily: 'Roboto',
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: backgroundWhite,
        elevation: elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLg),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: vkuRed,
        circularTrackColor: dividerColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return vkuRed;
          }
          return Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return vkuRed.withValues(alpha: 0.5);
          }
          return Colors.grey[300];
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return vkuRed;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return vkuRed;
          }
          return textLight;
        }),
      ),
    );
  }
  
  // ============================================================================
  // Visual Effects
  // ============================================================================
  
  // Glassmorphism effect for cards
  static BoxDecoration glassmorphism({
    Color? color,
    double blur = 10.0,
    double borderRadius = 16.0,
    Border? border,
  }) {
    return BoxDecoration(
      color: (color ?? backgroundWhite).withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  // Gradient overlay for headers and hero sections
  static BoxDecoration gradientOverlay({
    required Gradient gradient,
    double borderRadius = 0,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows,
    );
  }
  
  // Multi-layer subtle shadows
  static List<BoxShadow> get subtleShadows => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get mediumShadows => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get strongShadows => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Animated grid pattern inspired by VKU logo
  static BoxDecoration gridPattern({
    Color? backgroundColor,
    Color? gridColor,
    double gridSize = 20.0,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? vkuNavy,
      image: DecorationImage(
        image: const AssetImage('assets/images/grid_pattern.png'),
        repeat: ImageRepeat.repeat,
        opacity: 0.05,
        fit: BoxFit.none,
      ),
    );
  }
  
  // Card decoration with glassmorphism
  static BoxDecoration cardDecoration({
    Color? color,
    double borderRadius = 12.0,
    bool useGlass = false,
    List<BoxShadow>? shadows,
  }) {
    if (useGlass) {
      return glassmorphism(
        color: color,
        borderRadius: borderRadius,
      );
    }
    return BoxDecoration(
      color: color ?? backgroundWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows ?? subtleShadows,
    );
  }
  
  // Gradient border decoration
  static BoxDecoration gradientBorder({
    required Gradient gradient,
    double borderRadius = 12.0,
    double borderWidth = 2.0,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? backgroundWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        width: 0,
        color: Colors.transparent,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  // ============================================================================
  // Typography Helpers
  // ============================================================================
  
  // Gradient text styles (use with ShaderMask)
  static TextStyle gradientTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      foreground: Paint()
        ..shader = gradientRedToYellow.createShader(
          const Rect.fromLTWH(0, 0, 200, 70),
        ),
    );
  }
  
  static TextStyle redGradientText(TextStyle baseStyle) {
    return baseStyle.copyWith(
      foreground: Paint()
        ..shader = LinearGradient(
          colors: [vkuRed, vkuRed700],
        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
    );
  }
  
  static TextStyle yellowGradientText(TextStyle baseStyle) {
    return baseStyle.copyWith(
      foreground: Paint()
        ..shader = LinearGradient(
          colors: [vkuYellow, vkuYellow800],
        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
    );
  }
  
  static TextStyle navyGradientText(TextStyle baseStyle) {
    return baseStyle.copyWith(
      foreground: Paint()
        ..shader = LinearGradient(
          colors: [vkuNavy, vkuNavy700],
        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
    );
  }
  
  // Check WCAG AA contrast ratio (4.5:1 for normal text, 3:1 for large text)
  static bool hasGoodContrast(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = _calculateContrastRatio(foreground, background);
    return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
  }
  
  static double _calculateContrastRatio(Color color1, Color color2) {
    final l1 = _relativeLuminance(color1);
    final l2 = _relativeLuminance(color2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  static double _relativeLuminance(Color color) {
    final r = _linearize(color.red / 255);
    final g = _linearize(color.green / 255);
    final b = _linearize(color.blue / 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  static double _linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }
  
  // ============================================================================
  // Helper Methods
  // ============================================================================
  
  // Get subject colors for timetable (using VKU palette)
  static Color getSubjectColor(int index) {
    final colors = [
      subjectRed,
      subjectYellow,
      subjectNavy,
      subjectOrange,
      subjectPurple,
      subjectPink,
    ];
    return colors[index % colors.length];
  }
  
  // Get accent color based on subject (using VKU palette)
  static Color getSubjectAccentColor(int index) {
    final colors = [
      vkuRed,
      vkuYellow800,
      vkuNavy,
      warning,
      const Color(0xFF7B1FA2), // Purple
      const Color(0xFFC2185B), // Pink
    ];
    return colors[index % colors.length];
  }
  
  // Create a gradient from two VKU colors
  static LinearGradient createGradient(
    Color startColor,
    Color endColor, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: [startColor, endColor],
      begin: begin,
      end: end,
    );
  }
  
  // Get lighter shade of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  // Get darker shade of a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}


