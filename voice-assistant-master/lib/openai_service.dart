import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'secrets.dart';

class OpenAIService {
  final Logger _logger = Logger('OpenAIService'); // Create a logger instance

  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.',
            }
          ],
        }),
      );

      // Log the API response instead of printing it
      _logger.info('API Response: ${res.body}');

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'].trim();
        switch (content.toLowerCase()) {
          case 'yes':
            return await dallEAPI(prompt);
          default:
            return await chatGPTAPI(prompt);
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      // Log the error instead of printing it
      _logger.severe('Error occurred: $e');
      return 'An internal error occurred';
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      // Log the API response instead of printing it
      _logger.info('API Response: ${res.body}');

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'].trim();
        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      // Log the error instead of printing it
      _logger.severe('Error occurred: $e');
      return 'An internal error occurred';
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      // Log the API response instead of printing it
      _logger.info('API Response: ${res.body}');

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'].trim();
        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      // Log the error instead of printing it
      _logger.severe('Error occurred: $e');
      return 'An internal error occurred';
    }
  }
}
