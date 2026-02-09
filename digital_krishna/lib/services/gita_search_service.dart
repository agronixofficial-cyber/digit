import '../models/verse.dart';
import '../data/gita_data.dart';

class GitaSearchService {
  static List<Verse> findRelevantVerses(String query) {
    final normalizedQuery = query.toLowerCase();

    // Multilingual keyword mapping (English, Hindi, Marathi)
    final Map<String, List<String>> themeKeywords = {
      'karma': ['karma', 'action', 'duty', 'work', 'result', 'fruit', 'deed', 'कर्म', 'काम', 'कर्तव्य'],
      'death': ['death', 'soul', 'birth', 'die', 'eternal', 'body', 'मृत्यु', 'मरण', 'आत्मा', 'जन्म', 'देह'],
      'peace': ['peace', 'mind', 'control', 'calm', 'meditation', 'शान्ति', 'मन', 'संयम', 'शांत'],
      'god': ['god', 'supreme', 'krishna', 'devotion', 'worship', 'me', 'surrender', 'शरण', 'देव', 'परमेश्वर', 'भक्ती'],
      'war': ['war', 'fight', 'duty', 'dharma', 'righteous', 'battle', 'युद्ध', 'लढाई', 'धर्म'],
      'fear': ['fear', 'worry', 'anxiety', 'distress', 'afraid', 'डर', 'चिंता', 'भय', 'भीती', 'काळजी'],
      'anger': ['anger', 'rage', 'fury', 'lust', 'attachment', 'राग', 'क्रोध', 'संताप', 'लोभ', 'मोह'],
      'focus': ['focus', 'practice', 'concentration', 'steady', 'अभ्यास', 'लक्ष', 'एकाग्रता']
    };

    final matchedVerses = gitaVerses.where((verse) {
      // Check direct content match in translation or original text
      final contentMatch =
          verse.translation.toLowerCase().contains(normalizedQuery) ||
          verse.text.toLowerCase().contains(normalizedQuery) ||
          verse.transliteration.toLowerCase().contains(normalizedQuery);

      if (contentMatch) return true;

      // Check theme matches across languages
      for (final entry in themeKeywords.entries) {
        final theme = entry.key;
        final keywords = entry.value;
        if (normalizedQuery.contains(theme) || keywords.any((k) => normalizedQuery.contains(k))) {
          if (keywords.any((k) => verse.translation.toLowerCase().contains(k) || verse.text.toLowerCase().contains(k))) {
            return true;
          }
        }
      }

      return false;
    }).toList();

    // Limit to top 3 most relevant shlokas
    if (matchedVerses.length > 3) {
      return matchedVerses.sublist(0, 3);
    }
    return matchedVerses;
  }
}
