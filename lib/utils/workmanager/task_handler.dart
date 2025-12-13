import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/providers/news_helper.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';
import 'package:news_tracker/utils/notifications/new_schedule_notification.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Ensure notifications are initialized

  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'check_new_article':
        print('Checking for new article');
        await checkForNewArticles();
        break;
      case Workmanager.iOSBackgroundTask:
        await checkForNewArticles();
        break;
      default:
        break;
    }

    return Future.value(true);
  });
}

@pragma('vm:entry-point')
Future<void> checkForNewArticles() async {
  final container = ProviderContainer();
  try {
    final terms = await container.read(newTrackedTermsProvider.future);
    for (final term in terms) {
      print('Fetching news for ${term.term}');
      final news = await container.read(newsProvider(term.term).future);
      final articles = news?.articles;
      if (articles != null && articles.isNotEmpty) {
        print('Got articles successfully for ${term.term}');
        if (term.lastPublishedAt == null) {
          print('Setting lastPublishedAt initially for ${term.term}');
          final updated = term.copyWith(
            lastPublishedAt: articles.first.publishedAt,
            hasNewArticle: true,
          );
          final termProvider = container.read(newTrackedTermsProvider.notifier);
          await termProvider.updateTerm(updated, term.notificationId);

          final scheduler = container.read(schedulerProvider);
          await scheduler.scheduleOne(updated);
          continue;
        }

        if (articles.first.publishedAt != term.lastPublishedAt) {
          print('Updating lastPublishedAt for ${term.term}');
          final updated = term.copyWith(
            lastPublishedAt: articles.first.publishedAt,
            hasNewArticle: true,
          );
          final termProvider = container.read(newTrackedTermsProvider.notifier);
          await termProvider.updateTerm(updated, term.notificationId);

          final scheduler = container.read(schedulerProvider);
          await scheduler.scheduleOne(updated);
          print('Scheduled for ${term.term}');
          continue;
        }

        // TODO: handle no new article better
        final updated = term.copyWith(
          lastPublishedAt: articles.first.publishedAt,
          hasNewArticle: false,
        );
        final termProvider = container.read(newTrackedTermsProvider.notifier);
        await termProvider.updateTerm(updated, term.notificationId);

        final scheduler = container.read(schedulerProvider);
        await scheduler.scheduleOne(updated);
        continue;
      }
    }
  } finally {
    print('Done with background task');
    container.dispose();
  }
}
