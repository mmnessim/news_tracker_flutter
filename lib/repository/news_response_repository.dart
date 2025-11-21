import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_tracker/model/news_response.dart';

class NewsResponseRepository {
  final http.Client client;

  NewsResponseRepository(this.client);

  String formatUrl(String term) {
    final apiKey = dotenv.isInitialized
        ? (dotenv.env['API_KEY'] ?? '')
        : (const String.fromEnvironment('API_KEY', defaultValue: ''));
    final url =
        "https://newsapi.org/v2/everything?q=$term&sortBy=publishedAt&apiKey=$apiKey&language=en";

    return url;
  }

  Future<NewsResponse?> fetch(String term) async {
    final url = formatUrl(term);
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return NewsResponse.fromJson(decoded);
    } catch (err) {
      print(err);
      return null;
    }
  }
}

final newsResponseRepositoryProvider = Provider<NewsResponseRepository>(
  (ref) => NewsResponseRepository(http.Client()),
);
