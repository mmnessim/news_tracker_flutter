import 'package:flutter/material.dart';
import 'package:news_tracker/model/news_response.dart';
import 'package:news_tracker/utils/format_date.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleTile extends StatelessWidget {
  final Article article;

  const ArticleTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2.5),
        borderRadius: BorderRadius.circular(8), // Optional: rounded corners
      ),
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(article.url);
          await launchUrl(url, mode: LaunchMode.platformDefault);
        },
        child: ListTile(
          title: Text(
            article.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${formatDate(article.publishedAt)} - ${article.source.name}',
              ),
              if (article.urlToImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.network(
                    article.urlToImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        height: 180,
                        child: Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      );
                    },
                  ),
                ),
              Text(article.description != null ? article.description! : ''),
            ],
          ),
        ),
      ),
    );
  }
}
