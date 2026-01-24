import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:learn_sphere_ai/helper/global.dart';
import 'dart:developer';

class APIs {
  //get answer from GPT with conversation history for context
  static Future<String> getAnswer(
    String question, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      // Build messages list with system prompt
      final messages = <Map<String, String>>[
        {
          "role": "system",
          "content":
              "You are an AI tutor named Albert. Your job is to help students understand concepts step by step, explain clearly, give examples, and encourage them to think critically instead of just giving the answer right away.",
        },
      ];

      // Add conversation history for context
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }

      // Add current question
      messages.add({"role": "user", "content": question});

      final res = await post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),

        //headers
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $apiKey',

          //body
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "max_tokens": 2000,
          "temperature": 0,
          "messages": messages,
        }),
      );

      final data = jsonDecode(res.body);

      log('res: $data');
      return data['choices'][0]['message']['content'];
    } on SocketException catch (_) {
      log('getAnswer: Network error');
      return 'No internet connection. Please check your network and try again.';
    } catch (e) {
      log('getAnswer: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        return 'No internet connection. Please check your network and try again.';
      }
      return 'Service temporarily unavailable. Please try again later.';
    }
  }

  // Summarize text using GPT
  static Future<String> summarizeText(String text) async {
    try {
      final res = await post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "max_tokens": 1500,
          "temperature": 0.3,
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful assistant that summarizes lecture notes and educational content. Create clear, concise summaries that capture the key points, main concepts, and important details. Use bullet points where appropriate. Keep the summary well-organized and easy to review.",
            },
            {
              "role": "user",
              "content":
                  "Please summarize the following lecture content:\n\n$text",
            },
          ],
        }),
      );

      final data = jsonDecode(res.body);
      log('summarizeText res: $data');

      if (data['error'] != null) {
        return 'Error: ${data['error']['message']}';
      }

      return data['choices'][0]['message']['content'];
    } on SocketException catch (_) {
      log('summarizeText: Network error');
      return 'No internet connection. Please check your network and try again.';
    } catch (e) {
      log('summarizeText error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        return 'No internet connection. Please check your network and try again.';
      }
      return 'Service temporarily unavailable. Please try again later.';
    }
  }

  // Summarize a single chunk (used for large texts)
  static Future<String> summarizeChunk(
    String chunk,
    int chunkNumber,
    int totalChunks,
  ) async {
    try {
      final res = await post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "max_tokens": 800,
          "temperature": 0.3,
          "messages": [
            {
              "role": "system",
              "content":
                  "You are summarizing part $chunkNumber of $totalChunks of a lecture. Extract the key points concisely. Do not add introductions like 'This section covers...' - just list the main points directly.",
            },
            {"role": "user", "content": chunk},
          ],
        }),
      );

      final data = jsonDecode(res.body);

      if (data['error'] != null) {
        return '';
      }

      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('summarizeChunk error: $e');
      return '';
    }
  }

  // Combine multiple chunk summaries into a final summary
  static Future<String> combineSummaries(List<String> summaries) async {
    final combined = summaries.join('\n\n');

    try {
      final res = await post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "max_tokens": 1500,
          "temperature": 0.3,
          "messages": [
            {
              "role": "system",
              "content":
                  "You are combining multiple partial summaries of a lecture into one cohesive, well-organized final summary. Remove redundancy, organize by topic, and create a clear structure with bullet points where appropriate.",
            },
            {
              "role": "user",
              "content":
                  "Combine these partial summaries into one cohesive summary:\n\n$combined",
            },
          ],
        }),
      );

      final data = jsonDecode(res.body);

      if (data['error'] != null) {
        return 'Error: ${data['error']['message']}';
      }

      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('combineSummaries error: $e');
      return combined; // Return uncombined summaries as fallback
    }
  }

  // Generate quiz questions from lecture content
  static Future<List<Map<String, dynamic>>> generateQuizQuestions({
    required String text,
    required int questionCount,
    required String difficulty,
    Function(int currentChunk, int totalChunks)? onProgress,
  }) async {
    const int maxChunkSize = 3000;

    // Split text into chunks
    final chunks = _splitTextIntoChunks(text, maxChunkSize);
    final allQuestions = <Map<String, dynamic>>[];

    // Calculate questions per chunk
    final questionsPerChunk = _distributeQuestions(
      questionCount,
      chunks.length,
    );

    for (int i = 0; i < chunks.length; i++) {
      // Report progress
      onProgress?.call(i + 1, chunks.length);

      final chunkQuestions = await _generateQuestionsFromChunk(
        chunk: chunks[i],
        questionCount: questionsPerChunk[i],
        difficulty: difficulty,
        chunkNumber: i + 1,
        totalChunks: chunks.length,
      );
      allQuestions.addAll(chunkQuestions);
    }

    // Shuffle questions to mix content from different chunks
    allQuestions.shuffle();

    // Ensure we return exactly the requested number of questions
    if (allQuestions.length > questionCount) {
      return allQuestions.sublist(0, questionCount);
    }

    return allQuestions;
  }

  static List<String> _splitTextIntoChunks(String text, int maxChunkSize) {
    final chunks = <String>[];

    if (text.length <= maxChunkSize) {
      return [text];
    }

    int start = 0;
    while (start < text.length) {
      int end = start + maxChunkSize;

      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }

      // Try to break at a paragraph or sentence boundary
      int breakPoint = text.lastIndexOf('\n\n', end);
      if (breakPoint <= start) {
        breakPoint = text.lastIndexOf('. ', end);
      }
      if (breakPoint <= start) {
        breakPoint = text.lastIndexOf(' ', end);
      }
      if (breakPoint <= start) {
        breakPoint = end;
      }

      chunks.add(text.substring(start, breakPoint + 1).trim());
      start = breakPoint + 1;
    }

    return chunks;
  }

  static List<int> _distributeQuestions(int totalQuestions, int chunkCount) {
    if (chunkCount == 1) return [totalQuestions];

    final baseCount = totalQuestions ~/ chunkCount;
    final remainder = totalQuestions % chunkCount;

    return List.generate(chunkCount, (i) {
      return baseCount + (i < remainder ? 1 : 0);
    });
  }

  static Future<List<Map<String, dynamic>>> _generateQuestionsFromChunk({
    required String chunk,
    required int questionCount,
    required String difficulty,
    required int chunkNumber,
    required int totalChunks,
  }) async {
    if (questionCount <= 0) return [];

    final difficultyPrompt = _getDifficultyPrompt(difficulty);

    try {
      final res = await post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "max_tokens": 2000,
          "temperature": 0.7,
          "messages": [
            {
              "role": "system",
              "content":
                  '''You are a quiz generator for educational content. Generate exactly $questionCount multiple choice questions based on the provided lecture content.

Difficulty level: $difficulty
$difficultyPrompt

IMPORTANT: You must respond with ONLY a valid JSON array, no other text. Each question object must have exactly these fields:
- "question": The question text (string)
- "options": Array of exactly 4 answer options (strings)
- "correctAnswer": Index of correct option (0-3)
- "explanation": Brief explanation of why the answer is correct (string)

Example format:
[{"question":"What is X?","options":["A","B","C","D"],"correctAnswer":0,"explanation":"A is correct because..."}]''',
            },
            {
              "role": "user",
              "content":
                  "Generate $questionCount $difficulty multiple choice questions from this lecture content (part $chunkNumber of $totalChunks):\n\n$chunk",
            },
          ],
        }),
      );

      final data = jsonDecode(res.body);

      if (data['error'] != null) {
        log('generateQuestions error: ${data['error']['message']}');
        return [];
      }

      final content = data['choices'][0]['message']['content'] as String;
      return _parseQuestionsJson(content);
    } catch (e) {
      log('generateQuestionsFromChunk error: $e');
      return [];
    }
  }

  static String _getDifficultyPrompt(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return '''Easy questions should:
- Focus on basic recall and definitions
- Test fundamental concepts
- Have clearly distinct answer options
- Be straightforward without tricks''';
      case 'Medium':
        return '''Medium questions should:
- Test understanding and application of concepts
- Require connecting related ideas
- Include some analysis
- Have plausible distractors''';
      case 'Hard':
        return '''Hard questions should:
- Require deep analysis and critical thinking
- Test edge cases and nuanced understanding
- Include subtle distinctions between options
- May require combining multiple concepts''';
      default:
        return '';
    }
  }

  static List<Map<String, dynamic>> _parseQuestionsJson(String content) {
    try {
      // Try to extract JSON array from the response
      String jsonStr = content.trim();

      // If response has extra text, try to find the JSON array
      final startIndex = jsonStr.indexOf('[');
      final endIndex = jsonStr.lastIndexOf(']');

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        jsonStr = jsonStr.substring(startIndex, endIndex + 1);
      }

      final List<dynamic> parsed = jsonDecode(jsonStr);
      final questions = <Map<String, dynamic>>[];

      for (final item in parsed) {
        if (item is Map<String, dynamic>) {
          // Validate question structure
          if (_isValidQuestion(item)) {
            questions.add(item);
          }
        }
      }

      return questions;
    } catch (e) {
      log('parseQuestionsJson error: $e');
      log('Content was: $content');
      return [];
    }
  }

  static bool _isValidQuestion(Map<String, dynamic> q) {
    if (q['question'] == null || (q['question'] as String).isEmpty) {
      return false;
    }
    if (q['options'] == null || (q['options'] as List).length != 4) {
      return false;
    }
    if (q['correctAnswer'] == null ||
        q['correctAnswer'] < 0 ||
        q['correctAnswer'] > 3) {
      return false;
    }
    return true;
  }
}
