import 'package:flutter/material.dart';

/// Which version of the CILMI Foundation logo to show.
enum AppLogoVariant {
  /// Crown mark above "CILMI FOUNDATION" + Somali tagline (login, splash).
  stacked,

  /// Same, light colours for dark/teal backgrounds.
  stackedReversed,

  /// Mark beside the wordmark, for bars and headers.
  horizontal,

  /// Horizontal, light colours for dark/teal backgrounds (app bar).
  horizontalReversed,

  /// Crown mark only.
  mark,

  /// Crown mark only, light colours.
  markReversed,
}

/// Brand logo (Family Crown, teal & gold) from [assets/brand/].
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 120,
    this.width,
    this.variant = AppLogoVariant.stacked,
  });

  final double height;
  final double? width;
  final AppLogoVariant variant;

  static String assetFor(AppLogoVariant v) => switch (v) {
        AppLogoVariant.stacked => 'assets/brand/cilmi-logo-stacked.png',
        AppLogoVariant.stackedReversed =>
          'assets/brand/cilmi-logo-stacked-reversed.png',
        AppLogoVariant.horizontal => 'assets/brand/cilmi-logo-horizontal.png',
        AppLogoVariant.horizontalReversed =>
          'assets/brand/cilmi-logo-horizontal-reversed.png',
        AppLogoVariant.mark => 'assets/brand/cilmi-mark.png',
        AppLogoVariant.markReversed => 'assets/brand/cilmi-mark-reversed.png',
      };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetFor(variant),
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'CILMI FOUNDATION',
    );
  }
}
