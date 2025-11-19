import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MentionTextHelper {
  static TextSpan buildMentionText(
    String text,
    BuildContext context, {
    TextStyle? baseStyle,
    TextStyle? mentionStyle,
  }) {
    final List<TextSpan> spans = [];
    final pattern = RegExp(r'@(\w+)');
    int lastMatchEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      spans.add(TextSpan(
        text: match.group(0),
        style: mentionStyle ??
            TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            final username = match.group(1);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Clicked on @$username'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}
