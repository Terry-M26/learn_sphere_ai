import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:learn_sphere_ai/helper/global.dart';
import 'dart:developer';

class APIs {
  //get answer from GPT
  static Future<String> getAnswer(String question) async {
    try {
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
          "messages": [
            {
              "role": "system",
              "content":
                  "You are an AI tutor. Your job is to help students understand concepts step by step, explain clearly, give examples, and encourage them to think critically instead of just giving the answer right away.",
            },
            {"role": "user", "content": question},
          ],
        }),
      );

      final data = jsonDecode(res.body);

      log('res: $data');
      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('getAnswer: $e');
      return 'Something went wrong (Try again sometime)';
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
    } catch (e) {
      log('summarizeText error: $e');
      return 'Something went wrong while summarizing. Please try again.';
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
}
