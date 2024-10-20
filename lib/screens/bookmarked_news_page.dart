import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../models/news_article.dart';
import 'news_detail_page.dart';

class BookmarkedNewsPage extends StatelessWidget {
  const BookmarkedNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked News'),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          if (bookmarkProvider.bookmarkedArticles.isEmpty) {
            return const Center(child: Text('No bookmarked articles'));
          }
          return ListView.builder(
            itemCount: bookmarkProvider.bookmarkedArticles.length,
            itemBuilder: (context, index) {
              NewsArticle article = bookmarkProvider.bookmarkedArticles[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailPage(article: article),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.urlToImage.isNotEmpty)
                        Image.network(
                          article.urlToImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(child: Text('Image not available')),
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          article.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}