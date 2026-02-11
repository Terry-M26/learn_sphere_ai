// APIs class - handles all AI-related API calls to OpenAI via Firebase Cloud Functions
// All methods are static - no instance needed, call APIs.methodName() directly
// Uses Firebase Cloud Functions as a proxy to keep API keys secure on server

import 'dart:convert'; // For JSON encoding/decoding
import 'dart:developer'; // For log() function - prints to debug console
import 'package:cloud_functions/cloud_functions.dart'; // Firebase Cloud Functions SDK

class APIs {
  // Firebase Cloud Functions singleton instance
  // Used to call server-side functions that proxy OpenAI API
  static final _functions = FirebaseFunctions.instance;

  // Private helper method to call the OpenAI proxy Cloud Function
  // payload: The request body to send to OpenAI API
  // Returns: JSON response from OpenAI as a Map
  static Future<Map<String, dynamic>> _callOpenAIProxy(
    Map<String, dynamic> payload,
  ) async {
    // Get reference to the 'openaiProxy' Cloud Function
    final callable = _functions.httpsCallable('openaiProxy');
    // Call the function with payload wrapped in an object
    final result = await callable.call({'payload': payload});
    // Convert response data to Map and return
    return Map<String, dynamic>.from(result.data);
  }

  // Get AI tutor response for a user question
  // question: The user's current question
  // conversationHistory: Optional list of previous messages for context
  // Returns: AI response string or error message
  static Future<String> getAnswer(
    String question, {
    List<Map<String, String>>? conversationHistory, // Previous chat messages
  }) async {
    try {
      // Build messages array for OpenAI Chat API
      // System prompt defines the AI's personality and behavior
      final messages = <Map<String, String>>[
        {
          "role": "system", // System role sets AI behavior
          "content":
              "You are an AI tutor named Albert. Your job is to help students understand concepts step by step, explain clearly, give examples, and encourage them to think critically instead of just giving the answer right away.",
        },
      ];

      // Add previous messages to maintain conversation context
      // This allows AI to remember what was discussed earlier
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }

      // Add the current user question as the latest message
      messages.add({"role": "user", "content": question});

      // Call OpenAI API via Cloud Function
      final data = await _callOpenAIProxy({
        "model": "gpt-3.5-turbo", // GPT model to use
        "max_tokens": 2000, // Maximum response length
        "temperature": 0, // 0 = deterministic, 1 = creative
        "messages": messages, // Conversation history + current question
      });

      // Log response for debugging
      log('res: $data');
      // Extract and return the AI's response text
      // Response structure: {choices: [{message: {content: "..."}}]}
      return data['choices'][0]['message']['content'];
    } catch (e) {
      // Log error and return user-friendly message
      log('getAnswer: $e');
      return 'Something went wrong (Try again sometime)';
    }
  }

  // Summarize lecture text using GPT
  // text: The lecture content to summarize
  // Returns: Summarized text or error message
  static Future<String> summarizeText(String text) async {
    try {
      // Call OpenAI with summarization prompt
      final data = await _callOpenAIProxy({
        "model": "gpt-3.5-turbo",
        "max_tokens": 1500, // Limit summary length
        "temperature": 0.3, // Low temperature for consistent output
        "messages": [
          {
            "role": "system", // Define summarization behavior
            "content":
                "You are a helpful assistant that summarizes lecture notes and educational content. Create clear, concise summaries that capture the key points, main concepts, and important details. Use bullet points where appropriate. Keep the summary well-organized and easy to review.",
          },
          {
            "role": "user", // User's request with lecture content
            "content":
                "Please summarize the following lecture content:\n\n$text",
          },
        ],
      });

      log('summarizeText res: $data');

      // Check for API error in response
      if (data['error'] != null) {
        return 'Error: ${data['error']['message']}';
      }

      // Return the summary text from response
      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('summarizeText error: $e');
      return 'Something went wrong while summarizing. Please try again.';
    }
  }

  // Summarize a single chunk of text (for large documents)
  // Large texts are split into chunks to avoid API token limits
  // chunk: Text portion to summarize
  // chunkNumber: Current chunk index (1-based)
  // totalChunks: Total number of chunks
  static Future<String> summarizeChunk(
    String chunk,
    int chunkNumber,
    int totalChunks,
  ) async {
    try {
      // Summarize this chunk with context about its position
      final data = await _callOpenAIProxy({
        "model": "gpt-3.5-turbo",
        "max_tokens": 800, // Shorter limit for chunk summaries
        "temperature": 0.3,
        "messages": [
          {
            "role": "system",
            // Tell AI which part of the document this is
            "content":
                "You are summarizing part $chunkNumber of $totalChunks of a lecture. Extract the key points concisely. Do not add introductions like 'This section covers...' - just list the main points directly.",
          },
          {"role": "user", "content": chunk}, // The chunk text to summarize
        ],
      });

      // Return empty string on error (will be filtered out)
      if (data['error'] != null) {
        return '';
      }

      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('summarizeChunk error: $e');
      return ''; // Return empty on error
    }
  }

  // Combine multiple chunk summaries into one cohesive final summary
  // summaries: List of individual chunk summaries
  // Returns: Single unified summary
  static Future<String> combineSummaries(List<String> summaries) async {
    // Join all chunk summaries with double newlines
    final combined = summaries.join('\n\n');

    try {
      // Ask AI to merge and organize the partial summaries
      final data = await _callOpenAIProxy({
        "model": "gpt-3.5-turbo",
        "max_tokens": 1500,
        "temperature": 0.3,
        "messages": [
          {
            "role": "system",
            // Instructions for combining summaries
            "content":
                "You are combining multiple partial summaries of a lecture into one cohesive, well-organized final summary. Remove redundancy, organize by topic, and create a clear structure with bullet points where appropriate.",
          },
          {
            "role": "user",
            // Provide all partial summaries to combine
            "content":
                "Combine these partial summaries into one cohesive summary:\n\n$combined",
          },
        ],
      });

      if (data['error'] != null) {
        return 'Error: ${data['error']['message']}';
      }

      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('combineSummaries error: $e');
      // Fallback: return uncombined summaries if combining fails
      return combined;
    }
  }

  // Generate multiple choice quiz questions from lecture content
  // text: Lecture content to generate questions from
  // questionCount: Number of questions to generate
  // difficulty: 'Easy', 'Medium', or 'Hard'
  // onProgress: Callback for progress updates (chunk processing)
  // Returns: List of question objects with options and answers
  static Future<List<Map<String, dynamic>>> generateQuizQuestions({
    required String text,
    required int questionCount,
    required String difficulty,
    Function(int currentChunk, int totalChunks)?
    onProgress, // Progress callback
  }) async {
    // Maximum characters per chunk to stay within API limits
    const int maxChunkSize = 3000;

    // Split large text into manageable chunks
    final chunks = _splitTextIntoChunks(text, maxChunkSize);
    // Collect all generated questions
    final allQuestions = <Map<String, dynamic>>[];

    // Distribute questions evenly across chunks
    // e.g., 10 questions across 3 chunks = [4, 3, 3]
    final questionsPerChunk = _distributeQuestions(
      questionCount,
      chunks.length,
    );

    // Process each chunk and generate questions
    for (int i = 0; i < chunks.length; i++) {
      // Report progress to UI (e.g., "Processing chunk 2 of 5")
      onProgress?.call(i + 1, chunks.length);

      // Generate questions for this chunk
      final chunkQuestions = await _generateQuestionsFromChunk(
        chunk: chunks[i],
        questionCount: questionsPerChunk[i],
        difficulty: difficulty,
        chunkNumber: i + 1,
        totalChunks: chunks.length,
      );
      // Add to master list
      allQuestions.addAll(chunkQuestions);
    }

    // Shuffle to mix questions from different sections
    allQuestions.shuffle();

    // Trim to exact requested count if we got more
    if (allQuestions.length > questionCount) {
      return allQuestions.sublist(0, questionCount);
    }

    return allQuestions;
  }

  // Split text into chunks at natural boundaries (paragraphs, sentences)
  // Avoids cutting mid-sentence for better context
  static List<String> _splitTextIntoChunks(String text, int maxChunkSize) {
    final chunks = <String>[];

    // If text fits in one chunk, return as-is
    if (text.length <= maxChunkSize) {
      return [text];
    }

    int start = 0;
    // Process text in chunks
    while (start < text.length) {
      int end = start + maxChunkSize;

      // If remaining text fits, add it and finish
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }

      // Try to break at natural boundaries (best to worst):
      // 1. Paragraph break (double newline)
      int breakPoint = text.lastIndexOf('\n\n', end);
      // 2. Sentence end (period + space)
      if (breakPoint <= start) {
        breakPoint = text.lastIndexOf('. ', end);
      }
      // 3. Any space (word boundary)
      if (breakPoint <= start) {
        breakPoint = text.lastIndexOf(' ', end);
      }
      // 4. Hard cut if no boundary found
      if (breakPoint <= start) {
        breakPoint = end;
      }

      // Extract chunk and move to next section
      chunks.add(text.substring(start, breakPoint + 1).trim());
      start = breakPoint + 1;
    }

    return chunks;
  }

  // Distribute questions evenly across chunks
  // e.g., 10 questions / 3 chunks = [4, 3, 3]
  static List<int> _distributeQuestions(int totalQuestions, int chunkCount) {
    // Single chunk gets all questions
    if (chunkCount == 1) return [totalQuestions];

    // Integer division for base count per chunk
    final baseCount = totalQuestions ~/ chunkCount;
    // Remainder distributed to first chunks
    final remainder = totalQuestions % chunkCount;

    // Generate list with distributed counts
    return List.generate(chunkCount, (i) {
      // First 'remainder' chunks get one extra question
      return baseCount + (i < remainder ? 1 : 0);
    });
  }

  // Generate quiz questions from a single text chunk
  // Returns list of question objects with structure:
  // {question, options[], correctAnswer, explanation}
  static Future<List<Map<String, dynamic>>> _generateQuestionsFromChunk({
    required String chunk, // Text to generate questions from
    required int questionCount, // How many questions to generate
    required String difficulty, // Easy/Medium/Hard
    required int chunkNumber, // Current chunk (for context)
    required int totalChunks, // Total chunks (for context)
  }) async {
    // Skip if no questions needed for this chunk
    if (questionCount <= 0) return [];

    // Get difficulty-specific instructions
    final difficultyPrompt = _getDifficultyPrompt(difficulty);

    try {
      final data = await _callOpenAIProxy({
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
      });

      if (data['error'] != null) {
        log('generateQuestions error: ${data['error']['message']}');
        return [];
      }

      // Extract response content and parse JSON
      final content = data['choices'][0]['message']['content'] as String;
      // Parse JSON array from response
      return _parseQuestionsJson(content);
    } catch (e) {
      log('generateQuestionsFromChunk error: $e');
      return []; // Return empty list on error
    }
  }

  // Get difficulty-specific instructions for question generation
  // Returns detailed prompt for the specified difficulty level
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

  // Parse JSON array of questions from AI response
  // Handles cases where AI includes extra text around JSON
  static List<Map<String, dynamic>> _parseQuestionsJson(String content) {
    try {
      // Clean up response text
      String jsonStr = content.trim();

      // Find JSON array boundaries (AI sometimes adds extra text)
      final startIndex = jsonStr.indexOf('['); // Start of array
      final endIndex = jsonStr.lastIndexOf(']'); // End of array

      // Extract just the JSON array portion
      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        jsonStr = jsonStr.substring(startIndex, endIndex + 1);
      }

      // Decode JSON string to Dart objects
      final List<dynamic> parsed = jsonDecode(jsonStr);
      final questions = <Map<String, dynamic>>[];

      // Validate and add each question
      for (final item in parsed) {
        if (item is Map<String, dynamic>) {
          // Only add questions with valid structure
          if (_isValidQuestion(item)) {
            questions.add(item);
          }
        }
      }

      return questions;
    } catch (e) {
      // Log parsing errors for debugging
      log('parseQuestionsJson error: $e');
      log('Content was: $content');
      return []; // Return empty list on parse error
    }
  }

  // Validate question object has required fields with correct types
  // Returns true if question is valid, false otherwise
  static bool _isValidQuestion(Map<String, dynamic> q) {
    // Must have non-empty question text
    if (q['question'] == null || (q['question'] as String).isEmpty) {
      return false;
    }
    // Must have exactly 4 options
    if (q['options'] == null || (q['options'] as List).length != 4) {
      return false;
    }
    // correctAnswer must be 0-3 (index of correct option)
    if (q['correctAnswer'] == null ||
        q['correctAnswer'] < 0 ||
        q['correctAnswer'] > 3) {
      return false;
    }
    return true; // All validations passed
  }
}
