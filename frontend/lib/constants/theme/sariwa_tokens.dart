import 'package:material_ui/material_ui.dart';
import 'app_colors.dart';

/// Strict 4 px spacing scale tokens for SariwaBa.
abstract final class SariwaSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Unified corner radius family (8 / 12 / 20 + pill).
abstract final class SariwaRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double pill = 999;

  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius pillAll = BorderRadius.circular(pill);
}

/// ThemeExtension carrying product-specific surface, border, and semantic tokens
/// that Material's ColorScheme has no dedicated slot for.
@immutable
class SariwaTokens extends ThemeExtension<SariwaTokens> {
  final Color workspaceBg;
  final Color subtleSurface;
  final Color border;
  final Color borderSubtle;
  final Color mutedInk;
  final Color fresh;
  final Color freshBg;
  final Color freshBorder;
  final Color moderate;
  final Color moderateBg;
  final Color moderateBorder;
  final Color spoiled;
  final Color spoiledBg;
  final Color spoiledBorder;
  final Color info;

  const SariwaTokens({
    required this.workspaceBg,
    required this.subtleSurface,
    required this.border,
    required this.borderSubtle,
    required this.mutedInk,
    required this.fresh,
    required this.freshBg,
    required this.freshBorder,
    required this.moderate,
    required this.moderateBg,
    required this.moderateBorder,
    required this.spoiled,
    required this.spoiledBg,
    required this.spoiledBorder,
    required this.info,
  });

  static const SariwaTokens light = SariwaTokens(
    workspaceBg: SariwaColors.colorWorkspace,
    subtleSurface: SariwaColors.colorSurface,
    border: SariwaColors.colorLine,
    borderSubtle: SariwaColors.colorLineSubtle,
    mutedInk: SariwaColors.colorMutedInk,
    fresh: SariwaColors.freshText,
    freshBg: SariwaColors.freshIconBg,
    freshBorder: SariwaColors.freshBorder,
    moderate: SariwaColors.warningText,
    moderateBg: SariwaColors.warningBg,
    moderateBorder: SariwaColors.warningBorder,
    spoiled: SariwaColors.notFreshText,
    spoiledBg: SariwaColors.notFreshIconBg,
    spoiledBorder: SariwaColors.notFreshBorder,
    info: SariwaColors.statusInfo,
  );

  static const SariwaTokens dark = SariwaTokens(
    workspaceBg: SariwaColors.bgAbyssDark,
    subtleSurface: SariwaColors.bgLagoonMid,
    border: SariwaColors.borderGlass,
    borderSubtle: SariwaColors.surfaceElevated,
    mutedInk: SariwaColors.textSecondaryLight,
    fresh: SariwaColors.statusFresh,
    freshBg: SariwaColors.freshIconBgDark,
    freshBorder: SariwaColors.freshBorderDark,
    moderate: SariwaColors.statusModerate,
    moderateBg: SariwaColors.moderateIconBgDark,
    moderateBorder: SariwaColors.moderateBorderDark,
    spoiled: SariwaColors.notFreshPrimaryDark,
    spoiledBg: SariwaColors.notFreshIconBgDark,
    spoiledBorder: SariwaColors.notFreshBorderDark,
    info: SariwaColors.statusInfo,
  );

  static SariwaTokens of(BuildContext context) {
    return Theme.of(context).extension<SariwaTokens>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  SariwaTokens copyWith({
    Color? workspaceBg,
    Color? subtleSurface,
    Color? border,
    Color? borderSubtle,
    Color? mutedInk,
    Color? fresh,
    Color? freshBg,
    Color? freshBorder,
    Color? moderate,
    Color? moderateBg,
    Color? moderateBorder,
    Color? spoiled,
    Color? spoiledBg,
    Color? spoiledBorder,
    Color? info,
  }) {
    return SariwaTokens(
      workspaceBg: workspaceBg ?? this.workspaceBg,
      subtleSurface: subtleSurface ?? this.subtleSurface,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      mutedInk: mutedInk ?? this.mutedInk,
      fresh: fresh ?? this.fresh,
      freshBg: freshBg ?? this.freshBg,
      freshBorder: freshBorder ?? this.freshBorder,
      moderate: moderate ?? this.moderate,
      moderateBg: moderateBg ?? this.moderateBg,
      moderateBorder: moderateBorder ?? this.moderateBorder,
      spoiled: spoiled ?? this.spoiled,
      spoiledBg: spoiledBg ?? this.spoiledBg,
      spoiledBorder: spoiledBorder ?? this.spoiledBorder,
      info: info ?? this.info,
    );
  }

  @override
  SariwaTokens lerp(ThemeExtension<SariwaTokens>? other, double t) {
    if (other is! SariwaTokens) return this;
    return SariwaTokens(
      workspaceBg: Color.lerp(workspaceBg, other.workspaceBg, t)!,
      subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      mutedInk: Color.lerp(mutedInk, other.mutedInk, t)!,
      fresh: Color.lerp(fresh, other.fresh, t)!,
      freshBg: Color.lerp(freshBg, other.freshBg, t)!,
      freshBorder: Color.lerp(freshBorder, other.freshBorder, t)!,
      moderate: Color.lerp(moderate, other.moderate, t)!,
      moderateBg: Color.lerp(moderateBg, other.moderateBg, t)!,
      moderateBorder: Color.lerp(moderateBorder, other.moderateBorder, t)!,
      spoiled: Color.lerp(spoiled, other.spoiled, t)!,
      spoiledBg: Color.lerp(spoiledBg, other.spoiledBg, t)!,
      spoiledBorder: Color.lerp(spoiledBorder, other.spoiledBorder, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
