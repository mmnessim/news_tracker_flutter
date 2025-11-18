import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:news_tracker/model/news_response.dart';

final newsProvider = FutureProvider.family<NewsResponse?, String>((
  ref,
  term,
) async {
  final String _apiKey = dotenv.isInitialized
      ? (dotenv.env['API_KEY'] ?? '')
      : (const String.fromEnvironment('API_KEY', defaultValue: ''));
  final response = await http.get(
    Uri.parse(
      "https://newsapi.org/v2/everything?q=$term&sortBy=publishedAt&apiKey=$_apiKey&language=en",
    ),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return NewsResponse.fromJson(jsonData);
  }
  return null;
});
