import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_tracker/model/news_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_tracker/widgets/page_body_container.dart';
import 'widgets/article_tile.dart';

/// Page to display detailed news articles for a specific search term.
class DetailsPage extends StatefulWidget {
  /// The search term for which to display news articles.
  final String term;
  final http.Client? client;
  const DetailsPage({super.key, required this.term, this.client});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

/// State for [DetailsPage].
class _DetailsPageState extends State<DetailsPage> {
  /// API response containing news articles.
  NewsResponse? _jsonResponse;

  /// Error message, if any.
  String _error = '';

  /// API key for accessing the news service.
  final String _apiKey = dotenv.env['API_KEY'] ?? '';

  /// Initializes the state and fetches news articles.
  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  /// Checks and returns appropriate result text based on _jsonResponse and _error.
  String getResultsText() {
    if (_error.isNotEmpty) return 'Error: $_error';
    if (_jsonResponse == null) return 'Loading...';
    if (_jsonResponse!.articles.isNotEmpty) {
      return '${_jsonResponse!.articles.length} Results';
    }
    return 'No results';
  }

  /// Builds the list of news articles or error message.
  Widget buildResultsList() {
    // show error first if present
    if (_error.isNotEmpty) {
      return Center(child: Text('Error: $_error'));
    }
    if (_jsonResponse == null) {
      return const Center(child: Text('Loading...'));
    }
    if (_jsonResponse!.articles.isNotEmpty) {
      return ListView.builder(
        itemCount: _jsonResponse!.articles.length,
        itemBuilder: (context, index) {
          return ArticleTile(article: _jsonResponse!.articles[index]);
        },
      );
    }
    return const Center(child: Text('No results'));
  }

  /// Fetches news articles from the API based on the search term.
  Future<void> fetchNews() async {
    final client = widget.client ?? http.Client();
    final response = await client.get(
      Uri.parse(
        "https://newsapi.org/v2/everything?q=${widget.term}&sortBy=publishedAt&apiKey=$_apiKey&language=en",
      ),
    );

    /// Updates the state with the fetched news articles or error message.
    setState(() {
      print('setting state');
      print('${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final newsResponse = NewsResponse.fromJson(jsonData);
        _jsonResponse = NewsResponse(
          status: newsResponse.status,
          totalResults: newsResponse.totalResults,
          articles: newsResponse.articles.take(100).toList(),
        );
        _error = ''; // clear any previous error
      } else {
        _error = 'Request failed with status: ${response.statusCode}';
        _jsonResponse = null;
      }
    });
  }

  /// Builds the UI for the details page, including the app bar and body.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.term),
      ),
      body: PageBodyContainer(
        children: [
          Text(getResultsText()),
          Expanded(child: buildResultsList()),
        ],
      ),
    );
  }
}
