import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_tracker/model/news_response.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_tracker/widgets/page_body_container.dart';
import 'package:news_tracker/widgets/time_picker_row.dart';
import 'widgets/news_fetcher.dart';
import 'widgets/article_tile.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _result = '';
  final List<String> _searchTerms = [];
  NewsResponse? _jsonResponse;
  String _error = '';
  String? _activeTerm;
  final String _apiKey = dotenv.env['API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    loadSearchTerms().then(
      (terms) => setState(() {
        _searchTerms.addAll(terms);
      }),
    );
  }

  Future<void> fetchData(String term) async {
    setState(() {
      _activeTerm = term; // Set the active term
    });
    final response = await http.get(
      Uri.parse(
        "https://newsapi.org/v2/everything?q=$term&sortBy=publishedAt&apiKey=$_apiKey",
      ),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Accept': 'application/json',
      },
    );

    setState(() {
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final newsResponse = NewsResponse.fromJson(jsonData);
        _jsonResponse = NewsResponse(
          status: newsResponse.status,
          totalResults: newsResponse.totalResults,
          articles: newsResponse.articles.take(100).toList(),
        );
      } else {
        _error = 'Request failed with status: ${response.statusCode}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('About'),
      ),
      body: PageBodyContainer(
        children: [
          TimePickerRow(),
          Expanded(
            child: _jsonResponse != null
                ? ListView.builder(
                    itemCount: _jsonResponse!.articles.length > 100
                        ? 100
                        : _jsonResponse!.articles.length,
                    itemBuilder: (context, index) {
                      return ArticleTile(
                        article: _jsonResponse!.articles[index],
                      );
                    },
                  )
                : _error.isNotEmpty
                ? Center(child: Text(_error))
                : const Center(child: Text('No news loaded')),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  "Tracked Terms:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                ..._searchTerms.map(
                  (term) => NewsFetcher(
                    term: term,
                    onButtonClicked: fetchData,
                    isActive: term == _activeTerm,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_result),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
