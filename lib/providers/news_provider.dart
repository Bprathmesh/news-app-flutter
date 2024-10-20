import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  final List<NewsArticle> _articles = [];
  String _selectedCategory = '';
  String _searchQuery = '';
  bool _isLoading = false;
  int _currentPage = 1;

  List<NewsArticle> get articles => _articles;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  Future<void> fetchNews({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _articles.clear();
    }

    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newArticles = await _newsService.getNews(
        category: _selectedCategory,
        query: _searchQuery,
        page: _currentPage,
      );
      _articles.addAll(newArticles);
      _currentPage++;
    } catch (e) {
      print('Error fetching news: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNews() async {
    await fetchNews(refresh: true);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _articles.clear();
    _currentPage = 1;
    fetchNews();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _articles.clear();
    _currentPage = 1;
    fetchNews();
  }
}