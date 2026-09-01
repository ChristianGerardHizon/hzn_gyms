import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/utils/search_tokens.dart';

void main() {
  group('splitSearchTokens', () {
    test('returns empty for blank input', () {
      expect(splitSearchTokens(''), isEmpty);
      expect(splitSearchTokens('   '), isEmpty);
      expect(splitSearchTokens('\t\n'), isEmpty);
    });

    test('splits on whitespace and trims', () {
      expect(splitSearchTokens('chloe sy'), ['chloe', 'sy']);
      expect(splitSearchTokens('  chloe   sy  '), ['chloe', 'sy']);
      expect(splitSearchTokens('chloe\tsy'), ['chloe', 'sy']);
    });

    test('keeps a single token', () {
      expect(splitSearchTokens('chloe'), ['chloe']);
    });
  });

  group('isMemberSearchQueryReady', () {
    test('returns false for blank or single non-digit character', () {
      expect(isMemberSearchQueryReady(''), isFalse);
      expect(isMemberSearchQueryReady('   '), isFalse);
      expect(isMemberSearchQueryReady('a'), isFalse);
    });

    test('returns true for two or more characters', () {
      expect(isMemberSearchQueryReady('jo'), isTrue);
      expect(isMemberSearchQueryReady('  jo  '), isTrue);
    });

    test('returns true for numeric phone prefixes', () {
      expect(isMemberSearchQueryReady('9'), isTrue);
      expect(isMemberSearchQueryReady('0917'), isTrue);
    });
  });

  group('normalizeWhitespace', () {
    test('trims and collapses internal whitespace', () {
      expect(normalizeWhitespace('CHLOE  SY'), 'CHLOE SY');
      expect(normalizeWhitespace('  Adrian   Granada  '), 'Adrian Granada');
      expect(normalizeWhitespace('ok'), 'ok');
    });
  });

  group('formatPersonName', () {
    test('title-cases and collapses whitespace', () {
      expect(formatPersonName('CHLOE  SY'), 'Chloe Sy');
      expect(formatPersonName('jason adores'), 'Jason Adores');
      expect(formatPersonName('  MARY ANN  BILBAO '), 'Mary Ann Bilbao');
    });

    test('capitalizes segments after dots and hyphens', () {
      expect(formatPersonName('MA.HOPE  KABBARA'), 'Ma.Hope Kabbara');
      expect(formatPersonName('BONG  NASILO-AN'), 'Bong Nasilo-An');
      expect(formatPersonName('CHARLES LEBRON  STA.ANA'), 'Charles Lebron Sta.Ana');
    });

    test('preserves common suffixes', () {
      expect(formatPersonName('ROMULO  TAN III'), 'Romulo Tan III');
      expect(formatPersonName('rolando  paro jr'), 'Rolando Paro Jr');
      expect(formatPersonName('john smith sr.'), 'John Smith Sr.');
    });

    test('returns empty for blank input', () {
      expect(formatPersonName(''), '');
      expect(formatPersonName('   '), '');
    });
  });
}
