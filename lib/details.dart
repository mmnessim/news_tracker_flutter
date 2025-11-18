import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/news_response.dart';
import 'package:news_tracker/providers/news_helper.dart';
import 'package:news_tracker/widgets/page_body_container.dart';

import 'widgets/article_tile.dart';

class DetailsPage extends ConsumerWidget {
  final String term;

  const DetailsPage({super.key, required this.term});

  Widget _buildResultsArea(AsyncValue<NewsResponse?> contentAsync) {
    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (response) {
        if (response == null) {
          return const Center(child: Text('Error, response is null'));
        }
        return ListView.builder(
          itemCount: response.articles.length,
          itemBuilder: (context, index) {
            return ArticleTile(article: response.articles[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(newsProvider(term));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(term),
      ),
      body: PageBodyContainer(
        children: [Expanded(child: _buildResultsArea(contentAsync))],
      ),
    );
  }
}

//
// /// Page to display detailed news articles for a specific search term.
// class DetailsPage extends StatefulWidget {
//   /// The search term for which to display news articles.
//   final String term;
//   final http.Client? client;
//
//   final Future<List<String>> Function()? searchTermsLoader;
//
//   const DetailsPage({
//     super.key,
//     required this.term,
//     this.client,
//     this.searchTermsLoader,
//   });
//
//   @override
//   State<DetailsPage> createState() => _DetailsPageState();
// }
//
// /// State for [DetailsPage].
// class _DetailsPageState extends State<DetailsPage> {
//   /// API response containing news articles.
//   NewsResponse? _jsonResponse;
//
//   /// Error message, if any.
//   String _error = '';
//
//   /// API key for accessing the news service.
//   final String _apiKey = dotenv.isInitialized
//       ? (dotenv.env['API_KEY'] ?? '')
//       : (const String.fromEnvironment('API_KEY', defaultValue: ''));
//   int? _id;
//
//   /// Initializes the state and fetches news articles.
//   @override
//   void initState() {
//     super.initState();
//     if (dotenv.isInitialized) {
//       print('API Key loaded from .env $_apiKey');
//     } else {
//       print('API Key loaded from compile-time environment variable $_apiKey');
//     }
//     _initAsync();
//   }
//
//   void _initAsync() async {
//     final loader = widget.searchTermsLoader ?? loadSearchTerms;
//     final terms = await loader();
//     // print('loaded search terms');
//     setState(() {
//       _id = terms.indexOf(widget.term);
//       // print('term id: $_id');
//     });
//     fetchNews();
//   }
//
//   /// Checks and returns appropriate result text based on _jsonResponse and _error.
//   String getResultsText() {
//     if (_error.isNotEmpty) return 'Error: $_error';
//     if (_jsonResponse == null) return 'Loading...';
//     if (_jsonResponse!.articles.isNotEmpty) {
//       return '${_jsonResponse!.articles.length} Results';
//     }
//     return 'No results';
//   }
//
//   /// Builds the list of news articles or error message.
//   Widget buildResultsList() {
//     // show error first if present
//     if (_error.isNotEmpty) {
//       return Center(child: Text('Error: $_error'));
//     }
//     if (_jsonResponse == null) {
//       return const Center(child: Text('Loading...'));
//     }
//     if (_jsonResponse!.articles.isNotEmpty) {
//       return ListView.builder(
//         itemCount: _jsonResponse!.articles.length,
//         itemBuilder: (context, index) {
//           return ArticleTile(article: _jsonResponse!.articles[index]);
//         },
//       );
//     }
//     return const Center(child: Text('No results'));
//   }
//
//   /// Fetches news articles from the API based on the search term.
//   Future<void> fetchNews() async {
//     final client = widget.client ?? http.Client();
//     final response = await client.get(
//       Uri.parse(
//         "https://newsapi.org/v2/everything?q=${widget.term}&sortBy=publishedAt&apiKey=$_apiKey&language=en",
//       ),
//     );
//
//     /// Updates the state with the fetched news articles or error message.
//     setState(() {
//       print('setting state');
//       print('${response.statusCode}');
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonData = json.decode(response.body);
//         final newsResponse = NewsResponse.fromJson(jsonData);
//         _jsonResponse = NewsResponse(
//           status: newsResponse.status,
//           totalResults: newsResponse.totalResults,
//           articles: newsResponse.articles.take(100).toList(),
//         );
//         _error = ''; // clear any previous error
//       } else {
//         _error = 'Request failed with status: ${response.statusCode}';
//         _jsonResponse = null;
//       }
//     });
//   }
//
//   /// Builds the UI for the details page, including the app bar and body.
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.term),
//       ),
//       body: PageBodyContainer(
//         children: [
//           if (_id != null) NotificationDetails(id: _id!),
//           Text(getResultsText()),
//           Expanded(child: buildResultsList()),
//         ],
//       ),
//     );
//   }
// }
