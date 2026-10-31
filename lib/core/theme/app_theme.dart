import 'package:flutter/material.dart';

/// News Bucket theme: Literata (headlines) + Public Sans (UI, metadata),
/// "paper on a desk": text-only white cards on a page one step darker,
/// lifted by tone only (no shadows). One ink-blue accent. Built from explicit
/// ColorSchemes (not fromSeed) so no generated tint leaks in.
abstract final class AppTheme {
  static const serif = 'Literata';
  static const sans = 'PublicSans';

  static ThemeData get light => _build(_light, NbColors.light);
  static ThemeData get dark => _build(_dark, NbColors.dark);

  static const _light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2B4C8C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCE4F3),
    onPrimaryContainer: Color(0xFF142F5E),
    secondary: Color(0xFF57534B),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDCE4F3),
    onSecondaryContainer: Color(0xFF142F5E),
    tertiary: Color(0xFF57534B),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFAF9F6),
    onSurface: Color(0xFF1C1B19),
    onSurfaceVariant: Color(0xFF57534B),
    surfaceDim: Color(0xFFDCD8D0),
    surfaceBright: Color(0xFFFAF9F6),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF3F1EC),
    surfaceContainer: Color(0xFFEDEBE5),
    surfaceContainerHigh: Color(0xFFE5E2DB),
    surfaceContainerHighest: Color(0xFFDCD8D0),
    outline: Color(0xFF857F75),
    outlineVariant: Color(0xFFE3DFD7),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF141311),
    inverseSurface: Color(0xFF2F2D2A),
    onInverseSurface: Color(0xFFF3F0EA),
    inversePrimary: Color(0xFFAFC4EE),
    surfaceTint: Colors.transparent,
  );

  static const _dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA3BBEB),
    onPrimary: Color(0xFF0F2650),
    primaryContainer: Color(0xFF2A3F66),
    onPrimaryContainer: Color(0xFFDCE4F7),
    secondary: Color(0xFFB5B0A6),
    onSecondary: Color(0xFF2A2825),
    secondaryContainer: Color(0xFF2A3F66),
    onSecondaryContainer: Color(0xFFDCE4F7),
    tertiary: Color(0xFFB5B0A6),
    onTertiary: Color(0xFF2A2825),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: Color(0xFF161513),
    onSurface: Color(0xFFECE8E1),
    onSurfaceVariant: Color(0xFFB5B0A6),
    surfaceDim: Color(0xFF161513),
    surfaceBright: Color(0xFF353330),
    surfaceContainerLowest: Color(0xFF100F0E),
    surfaceContainerLow: Color(0xFF1D1C19),
    surfaceContainer: Color(0xFF22211E),
    surfaceContainerHigh: Color(0xFF2B2926),
    surfaceContainerHighest: Color(0xFF353330),
    outline: Color(0xFF8F8A80),
    outlineVariant: Color(0xFF2C2A27),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E2DA),
    onInverseSurface: Color(0xFF2A2825),
    inversePrimary: Color(0xFF2B4C8C),
    surfaceTint: Colors.transparent,
  );

  // Both families are bundled as variable fonts, so weight (and Literata's
  // optical size) are set explicitly as font variations. Change weights
  // with TextStyle.withWeight(), not copyWith(fontWeight:).
  static TextStyle _serif(double size, double line, FontWeight w, double ls) =>
      TextStyle(
        fontFamily: serif,
        fontSize: size,
        height: line / size,
        fontWeight: w,
        letterSpacing: ls,
        fontVariations: [
          FontVariation('wght', w.value.toDouble()),
          FontVariation('opsz', size.clamp(7, 72).toDouble()),
        ],
      );

  static TextStyle _sans(double size, double line, FontWeight w, double ls) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size,
        height: line / size,
        fontWeight: w,
        letterSpacing: ls,
        fontVariations: [FontVariation('wght', w.value.toDouble())],
      );

  static TextTheme _textTheme(ColorScheme s) => TextTheme(
    displayLarge: _serif(40, 48, FontWeight.w500, -0.6),
    displayMedium: _serif(36, 44, FontWeight.w500, -0.5),
    displaySmall: _serif(32, 40, FontWeight.w500, -0.4),
    headlineLarge: _serif(26, 32, FontWeight.w600, -0.3),
    headlineMedium: _serif(22, 28, FontWeight.w600, -0.2),
    headlineSmall: _serif(20, 26, FontWeight.w500, 0),
    titleLarge: _serif(18, 24, FontWeight.w500, -0.1),
    titleMedium: _serif(17, 22, FontWeight.w600, 0),
    titleSmall: _sans(14, 20, FontWeight.w600, 0.1),
    bodyLarge: _sans(15, 21, FontWeight.w500, 0),
    bodyMedium: _sans(14, 20, FontWeight.w400, 0),
    bodySmall: _sans(13, 18, FontWeight.w400, 0),
    labelLarge: _sans(14, 20, FontWeight.w500, 0.1),
    labelMedium: _sans(12, 16, FontWeight.w500, 0.3),
    labelSmall: _sans(11, 16, FontWeight.w600, 0.8),
  ).apply(bodyColor: s.onSurface, displayColor: s.onSurface);

  static ThemeData _build(ColorScheme s, NbColors nb) {
    final text = _textTheme(s);
    final nbText = NbText(
      meta: _sans(12, 16, FontWeight.w500, 0.2).copyWith(
        color: s.onSurfaceVariant,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      sectionLabel: text.labelSmall!.copyWith(color: s.onSurfaceVariant),
    );
    final r6 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));

    return ThemeData(
      useMaterial3: true,
      colorScheme: s,
      fontFamily: sans,
      textTheme: text,
      scaffoldBackgroundColor: nb.page,
      canvasColor: nb.page,
      splashFactory: InkRipple.splashFactory,
      splashColor: nb.pressed,
      highlightColor: nb.pressed,
      extensions: [nb, nbText],
      appBarTheme: AppBarTheme(
        backgroundColor: nb.page,
        foregroundColor: s.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        toolbarHeight: 64,
        titleSpacing: 16,
        titleTextStyle: text.headlineMedium,
        actionsIconTheme: IconThemeData(color: s.onSurfaceVariant, size: 24),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: nb.page,
        surfaceTintColor: Colors.transparent,
        indicatorColor: s.surfaceContainerHigh,
        indicatorShape: r6,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return text.labelMedium!
              .withWeight(sel ? FontWeight.w600 : FontWeight.w500)
              .copyWith(color: sel ? s.onSurface : s.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: sel ? s.onSurface : s.onSurfaceVariant,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        shape: r6,
        side: WidgetStateBorderSide.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? BorderSide(color: s.primaryContainer)
              : BorderSide(color: nb.border),
        ),
        backgroundColor: Colors.transparent,
        selectedColor: s.primaryContainer,
        disabledColor: Colors.transparent,
        checkmarkColor: s.onPrimaryContainer,
        showCheckmark: true,
        labelStyle: text.labelLarge!.copyWith(color: s.onSurface),
        secondaryLabelStyle: text.labelLarge!.copyWith(
          color: s.onPrimaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        elevation: 0,
        pressElevation: 0,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(r6),
          side: WidgetStatePropertyAll(BorderSide(color: nb.border)),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.selected)
                ? s.primaryContainer
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.selected)
                ? s.onPrimaryContainer
                : s.onSurface,
          ),
          overlayColor: WidgetStatePropertyAll(nb.pressed),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: s.primary,
          textStyle: text.labelLarge,
          shape: r6,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: r6,
          highlightColor: nb.pressed,
        ),
      ),
      cardTheme: CardThemeData(
        color: nb.card,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: s.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.surfaceContainerLow,
        modalBackgroundColor: s.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: nb.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        showDragHandle: true,
        dragHandleColor: s.outline,
        dragHandleSize: const Size(32, 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: s.inverseSurface,
        contentTextStyle: text.bodyMedium!.copyWith(color: s.onInverseSurface),
        actionTextColor: s.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        insetPadding: const EdgeInsets.all(8),
        elevation: 3,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: s.primary,
        textColor: s.onPrimary,
        largeSize: 16,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        textStyle: const TextStyle(
          fontFamily: sans,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontVariations: [FontVariation('wght', 600)],
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: s.primary,
        linearTrackColor: s.primaryContainer,
        linearMinHeight: 2,
        refreshBackgroundColor: s.surfaceContainerLow,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall!.copyWith(color: s.onSurfaceVariant),
        iconColor: s.onSurfaceVariant,
      ),
      switchTheme: const SwitchThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

/// Extra colours that have no ColorScheme role.
@immutable
class NbColors extends ThemeExtension<NbColors> {
  const NbColors({
    required this.page,
    required this.card,
    required this.read,
    required this.border,
    required this.success,
    required this.pressed,
    required this.scrim,
    required this.categories,
  });

  /// Scaffold, app bar and navigation bar background (the "desk").
  final Color page;

  /// Article card fill (the "paper").
  final Color card;

  /// Read article title and its metadata.
  final Color read;

  /// Unselected chip and segmented-button border (stronger than outlineVariant).
  final Color border;
  final Color success;

  /// Pressed state overlay.
  final Color pressed;

  /// Behind the bottom sheet.
  final Color scrim;

  /// Category marker colours keyed by NewsCategory.id.
  final Map<String, Color> categories;

  Color category(String id) => categories[id] ?? border;

  static const light = NbColors(
    page: Color(0xFFECE9E2),
    card: Color(0xFFFFFFFF),
    read: Color(0xFF6A655B),
    border: Color(0xFFCBC6BC),
    success: Color(0xFF2E6B3F),
    pressed: Color(0x141C1B19), // onSurface 8%
    scrim: Color(0x66141311), // 40%
    categories: {
      'ai': Color(0xFF3E7A80),
      'programming': Color(0xFF69793A),
      'security': Color(0xFFA34747),
      'markets': Color(0xFF8A6A28),
      'crypto': Color(0xFF75598C),
    },
  );

  static const dark = NbColors(
    page: Color(0xFF121110),
    card: Color(0xFF272623),
    read: Color(0xFF99948A),
    border: Color(0xFF4A4741),
    success: Color(0xFF94CFA3),
    pressed: Color(0x1AECE8E1), // onSurface 10%
    scrim: Color(0x80000000), // 50%
    categories: {
      'ai': Color(0xFF7FB5BA),
      'programming': Color(0xFFA9B874),
      'security': Color(0xFFDA8A85),
      'markets': Color(0xFFCFAE6A),
      'crypto': Color(0xFFB49AC8),
    },
  );

  @override
  NbColors copyWith({
    Color? page,
    Color? card,
    Color? read,
    Color? border,
    Color? success,
    Color? pressed,
    Color? scrim,
    Map<String, Color>? categories,
  }) => NbColors(
    page: page ?? this.page,
    card: card ?? this.card,
    read: read ?? this.read,
    border: border ?? this.border,
    success: success ?? this.success,
    pressed: pressed ?? this.pressed,
    scrim: scrim ?? this.scrim,
    categories: categories ?? this.categories,
  );

  @override
  NbColors lerp(ThemeExtension<NbColors>? other, double t) {
    if (other is! NbColors) return this;
    return NbColors(
      page: Color.lerp(page, other.page, t)!,
      card: Color.lerp(card, other.card, t)!,
      read: Color.lerp(read, other.read, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      pressed: Color.lerp(pressed, other.pressed, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      categories: t < 0.5 ? categories : other.categories,
    );
  }
}

/// Text styles with no TextTheme slot.
@immutable
class NbText extends ThemeExtension<NbText> {
  const NbText({required this.meta, required this.sectionLabel});

  /// Source · time · score line and comment count. Tabular figures.
  final TextStyle meta;

  /// Uppercase section label ("THEME", "NOTIFICATIONS"). Apply
  /// `.toUpperCase()` to the string; Flutter has no text-transform.
  final TextStyle sectionLabel;

  @override
  NbText copyWith({TextStyle? meta, TextStyle? sectionLabel}) => NbText(
    meta: meta ?? this.meta,
    sectionLabel: sectionLabel ?? this.sectionLabel,
  );

  @override
  NbText lerp(ThemeExtension<NbText>? other, double t) {
    if (other is! NbText) return this;
    return NbText(
      meta: TextStyle.lerp(meta, other.meta, t)!,
      sectionLabel: TextStyle.lerp(sectionLabel, other.sectionLabel, t)!,
    );
  }
}

extension NbWeight on TextStyle {
  /// copyWith(fontWeight:) that also updates the variable-font wght axis.
  TextStyle withWeight(FontWeight w) => copyWith(
    fontWeight: w,
    fontVariations: [
      for (final v in fontVariations ?? const <FontVariation>[])
        if (v.axis != 'wght') v,
      FontVariation('wght', w.value.toDouble()),
    ],
  );
}

extension NbThemeX on BuildContext {
  NbColors get nb => Theme.of(this).extension<NbColors>()!;
  NbText get nbText => Theme.of(this).extension<NbText>()!;
}
