import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.source),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'Published on: ${article.publishedAt}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 16),
              if (article.urlToImage.isNotEmpty)
                Image.network(
                  article.urlToImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 16),
              Text(
                article.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _launchURL(context, article.url),
                child: Text('Read Full Article'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}