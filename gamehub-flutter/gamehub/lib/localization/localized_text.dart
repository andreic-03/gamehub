import 'package:flutter/material.dart';
import 'localization_service.dart';

class LocalizedText extends StatelessWidget {
  final String textKey;
  final String? fallback;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const LocalizedText(
    this.textKey, {
    Key? key,
    this.fallback,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, child) {
        return Text(
          fallback != null 
              ? LocalizationService.instance.getStringWithFallback(textKey, fallback!)
              : LocalizationService.instance.getString(textKey),
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Extension to easily get localized strings
extension LocalizationExtension on String {
  String get localized => LocalizationService.instance.getString(this);
  
  String localizedWithFallback(String fallback) => 
      LocalizationService.instance.getStringWithFallback(this, fallback);
}

/// Widget for reactive localized text using extension methods
class ReactiveLocalizedText extends StatelessWidget {
  final String textKey;
  final String? fallback;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ReactiveLocalizedText(
    this.textKey, {
    Key? key,
    this.fallback,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocalizationService.instance,
      builder: (context, child) {
        return Text(
          fallback != null 
              ? textKey.localizedWithFallback(fallback!)
              : textKey.localized,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
