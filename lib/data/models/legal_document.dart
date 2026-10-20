enum LegalDocument { terms, privacy }

enum LegalLanguage { en, id }

sealed class LegalBlock {
  const LegalBlock();
}

class LegalTitle extends LegalBlock {
  final String text;
  const LegalTitle(this.text);
}

class LegalHeading extends LegalBlock {
  final String text;
  const LegalHeading(this.text);
}

class LegalParagraph extends LegalBlock {
  final String text;
  const LegalParagraph(this.text);
}

class LegalBullet extends LegalBlock {
  final String text;
  const LegalBullet(this.text);
}

class LegalTextParser {
  LegalTextParser._();

  static List<LegalBlock> parse(String raw) {
    final blocks = <LegalBlock>[];
    for (final line in raw.replaceAll('\r\n', '\n').split('\n')) {
      final text = line.trim();
      if (text.isEmpty) continue;
      if (text.startsWith('## ')) {
        blocks.add(LegalHeading(text.substring(3).trim()));
      } else if (text.startsWith('# ')) {
        blocks.add(LegalTitle(text.substring(2).trim()));
      } else if (text.startsWith('- ')) {
        blocks.add(LegalBullet(text.substring(2).trim()));
      } else {
        blocks.add(LegalParagraph(text));
      }
    }
    return blocks;
  }
}
