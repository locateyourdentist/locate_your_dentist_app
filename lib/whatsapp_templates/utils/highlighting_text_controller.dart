import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';

/// A TextEditingController that colors `{{n}}` variable placeholders inline,
/// while keeping a real caret/selection (unlike a Stack-based overlay hack).
class HighlightingTextEditingController extends TextEditingController {
  static final RegExp _variablePattern = RegExp(r'\{\{\d+\}\}');

  HighlightingTextEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final matches = _variablePattern.allMatches(text);
    if (matches.isEmpty) {
      return TextSpan(style: style, text: text);
    }

    final children = <TextSpan>[];
    int cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        children.add(TextSpan(text: text.substring(cursor, match.start), style: style));
      }
      children.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: style?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
            backgroundColor: AppColors.primaryLight,
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor), style: style));
    }
    return TextSpan(style: style, children: children);
  }
}
