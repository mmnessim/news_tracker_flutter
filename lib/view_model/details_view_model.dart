import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/news_response.dart';
import 'package:news_tracker/repository/news_response_repository.dart';

class DetailsViewModel extends AsyncNotifier<NewsResponse> {
  final String term;

  DetailsViewModel(this.term);

  @override
  FutureOr<NewsResponse> build() async {
    final repo = ref.read(newsResponseRepositoryProvider);
    final response = await repo.fetch(term);
    return response ??
        NewsResponse(status: 'Error', totalResults: 0, articles: []);
  }
}

final detailsViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<DetailsViewModel, NewsResponse, String>(DetailsViewModel.new);
