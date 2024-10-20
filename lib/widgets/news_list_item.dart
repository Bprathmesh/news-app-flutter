import 'package:flutter/material.dart';
import '../models/news_article.dart';

class NewsListItem extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsListItem({Key? key, required this.article, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          article.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(article.description),
            SizedBox(height: 8),
            Text(
              'Source: ${article.source}',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        leading: article.urlToImage.isNotEmpty
            ? Image.network(
                article.urlToImage,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}