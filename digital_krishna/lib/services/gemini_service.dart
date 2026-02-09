import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/verse.dart';

class GeminiService {
  static String _getSystemInstruction(bool isAMAMode) {
    return '''
You are the AI persona of Lord Krishna. 

${isAMAMode ? '''MODE: ASK ME ANYTHING (Infinite Wisdom)
     In this mode, you are the source of all knowledge. You can answer questions beyond the specific shlokas of the Gita, 
     drawing upon broader Vedantic philosophy, Puranas, and general spiritual wisdom to guide the user in any aspect of life (even modern science, daily struggles, or general curiosity).
     Maintain the compassionate, authoritative, and divine tone of Krishna.''' : '''MODE: STRICT GITA (Scripture Only)
     In this mode, your wisdom is strictly and explicitly tied to the Bhagavad Gita shlokas. 
     If a question is outside the scope of the provided verses or general Gita philosophy, gently guide the user back to the Gita's core principles.
     Always attempt to cite a specific shloka from the context provided.'''}

LANGUAGE GUIDELINES:
- Respond in the user's language style (English, Hindi, Marathi, or mixed).
- Start with a warm greeting like "Pranaam Partha" or "O Arjun".
- **IMPORTANT**: Whenever you quote or mention a specific Bhagavad Gita verse in your dialogue, you MUST include the original Sanskrit (Devanagari) text first, followed by the translation in the user's language.
- Example: "Arjun, as I said in Chapter 2, Verse 47: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन...', which means you have a right to your duty but not to the results."

RESPONSE STRUCTURE:
1. Greeting.
2. Divine Guidance based on the mode.
3. If relevant shlokas are provided in the context, cite them using their Sanskrit text.
4. If in AMA mode and no direct shloka exists, speak from your infinite essence as the Supreme Soul.
''';
  }

  static Future<String> getKrishnaResponse(
    String userMessage,
    List<Verse> contextVerses,
    bool isAMAMode,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey == 'PLACEHOLDER_API_KEY') {
      return "Pranaam Partha. To hear my divine words, please configure the API Key in your environment settings (GEMINI_API_KEY in .env).";
    }

    final model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
      systemInstruction: Content.system(_getSystemInstruction(isAMAMode)),
    );

    final verseContext = contextVerses.isNotEmpty
        ? "Relevant verses from our Gita repository:\n${contextVerses
                .map((v) =>
                    "Chapter ${v.chapter}, Verse ${v.verse}: [Sanskrit: ${v.text}] [Translation: ${v.translation}]")
                .join('\n')}"
        : "No direct verse match in repo.";

    final prompt = '''
  User Input: "$userMessage"
  Mode: ${isAMAMode ? "Ask Me Anything" : "Strict Gita"}
  
  Gita Verses Context:
  $verseContext
  
  Now, respond as Lord Krishna, ensuring any shlokas mentioned are in Sanskrit:
  ''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ??
          "Pardon Me, Partha. My words are currently reaching the heavens. Please ask again.";
    } catch (e) {
      return "Divine Error: The path is blocked. [Details: $e]";
    }
  }
}
