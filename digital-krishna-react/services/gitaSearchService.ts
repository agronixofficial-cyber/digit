
import { GITA_VERSES } from '../data/gita_data';
import { Verse } from '../types';

export const findRelevantVerses = (query: string): Verse[] => {
  const normalizedQuery = query.toLowerCase();
  
  // Multilingual keyword mapping (English, Hindi, Marathi)
  const themeKeywords: Record<string, string[]> = {
    'karma': ['karma', 'action', 'duty', 'work', 'result', 'fruit', 'deed', 'कर्म', 'काम', 'कर्तव्य'],
    'death': ['death', 'soul', 'birth', 'die', 'eternal', 'body', 'मृत्यु', 'मरण', 'आत्मा', 'जन्म', 'देह'],
    'peace': ['peace', 'mind', 'control', 'calm', 'meditation', 'शान्ति', 'मन', 'संयम', 'शांत'],
    'god': ['god', 'supreme', 'krishna', 'devotion', 'worship', 'me', 'surrender', 'शरण', 'देव', 'परमेश्वर', 'भक्ती'],
    'war': ['war', 'fight', 'duty', 'dharma', 'righteous', 'battle', 'युद्ध', 'लढाई', 'धर्म'],
    'fear': ['fear', 'worry', 'anxiety', 'distress', 'afraid', 'डर', 'चिंता', 'भय', 'भीती', 'काळजी'],
    'anger': ['anger', 'rage', 'fury', 'lust', 'attachment', 'राग', 'क्रोध', 'संताप', 'लोभ', 'मोह'],
    'focus': ['focus', 'practice', 'concentration', 'steady', 'अभ्यास', 'लक्ष', 'एकाग्रता']
  };

  const matchedVerses = GITA_VERSES.filter(verse => {
    // Check direct content match in translation or original text
    const contentMatch = 
      verse.translation.toLowerCase().includes(normalizedQuery) ||
      verse.text.toLowerCase().includes(normalizedQuery) ||
      verse.transliteration.toLowerCase().includes(normalizedQuery);
    
    if (contentMatch) return true;

    // Check theme matches across languages
    for (const [theme, keywords] of Object.entries(themeKeywords)) {
      if (normalizedQuery.includes(theme) || keywords.some(k => normalizedQuery.includes(k))) {
        if (keywords.some(k => verse.translation.toLowerCase().includes(k) || verse.text.toLowerCase().includes(k))) {
          return true;
        }
      }
    }
    
    return false;
  });

  // Limit to top 3 most relevant shlokas
  return matchedVerses.slice(0, 3);
};
