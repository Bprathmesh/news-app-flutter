import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/news_article.dart';

class BookmarkProvider with ChangeNotifier {
  List<NewsArticle> _bookmarkedArticles = [];
  List<NewsArticle> get bookmarkedArticles => _bookmarkedArticles;

  BookmarkProvider() {
    _loadBookmarkedArticles();
  }

  Future<void> _loadBookmarkedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookmarkedArticlesJson = prefs.getString('bookmarkedArticles');
    if (bookmarkedArticlesJson != null) {
      final List<dynamic> decodedData = json.decode(bookmarkedArticlesJson);
      _bookmarkedArticles = decodedData.map((item) => NewsArticle.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveBookmarkedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_bookmarkedArticles.map((article) => article.toJson()).toList());
    await prefs.setString('bookmarkedArticles', encodedData);
  }

  void toggleBookmark(NewsArticle article) {
    final index = _bookmarkedArticles.indexWhere((item) => item.url == article.url);
    if (index >= 0) {
      _bookmarkedArticles.removeAt(index);
    } else {
      _bookmarkedArticles.add(article);
    }
    article.isBookmarked = !article.isBookmarked;
    _saveBookmarkedArticles();
    notifyListeners();
  }

  bool isBookmarked(NewsArticle article) {
    return _bookmarkedArticles.any((item) => item.url == article.url);
  }
}