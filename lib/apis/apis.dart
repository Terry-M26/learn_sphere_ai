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
            {"role": "system",
              "content":
                  "You are an AI tutor. Your job is to help students understand concepts step by step, explain clearly, give examples, and encourage them to think critically instead of just giving the answer right away."
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
}
