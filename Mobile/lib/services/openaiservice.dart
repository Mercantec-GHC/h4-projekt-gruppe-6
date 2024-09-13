import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static Future<Map<String, dynamic>> getGuideBook(String country) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final requestBody = jsonEncode({
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content": "You are a Tourist-guide book that makes a guidebook over a given country and further instructions in the message."
        },
        {
          "role": "user",
          "content": "Make a tourist guide book over $country. The topics should be: A little introduction to how the people of the country is like and what to expect from the environment, famous tourist attractions in the country(amusement park always included), Basic words that would be nice to learn in the country's language(should always be from English to the country's language) and transportation. These topics should be in a Json-Object format."
        }
      ],
    });

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {

      try {
        return jsonDecode(response.body);
      } catch (e) {
        return {
          'navn': 'Fejl',
          'art': 'Ukendt',
          'type': 'Fejl',
          'description': 'Fejl ved JSON parsing: $e'
        };
      }
    } else {
      throw Exception('Fejl ved hentning af data: ${response.statusCode}');
    }
  }
}