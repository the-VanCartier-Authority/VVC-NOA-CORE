import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownMessageWidget extends StatelessWidget {
  final String text;
  final bool isUser;

  const MarkdownMessageWidget({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: MarkdownBody(
        data: text,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14),
          code: const TextStyle(
            backgroundColor: Color(0xFF1E1E1E),
            color: Color(0xFF38BDF8),
            fontFamily: 'monospace',
          ),
        ),
        builders: {
          'code': CodeElementBuilder(),
        },
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class']!;
      language = lg.replaceFirst('language-', '');
    }
    return HighlightView(
      element.textContent,
      language: language.isEmpty ? 'plaintext' : language,
      theme: atomOneDarkTheme,
      padding: const EdgeInsets.all(8),
      textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 12),
    );
  }
}
0
