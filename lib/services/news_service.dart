import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news_article.dart';

class NewsService {
  final String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

  // Rate limiting
  final int _maxRequestsPerMinute = 10;
  final _requestTimestamps = <DateTime>[];

  Future<List<NewsArticle>> getNews({String? category, String? query, int page = 1}) async {
    await _waitForRateLimit();

    String url = '$_baseUrl/top-headlines?country=us&pageSize=10&page=$page';

    if (category != null && category.isNotEmpty) {
      url += '&category=$category';
    }

    if (query != null && query.isNotEmpty) {
      url += '&q=$query';
    }

    url += '&apiKey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> articles = jsonData['articles'];
        return articles.map((article) => NewsArticle.fromJson(article)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded');
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> _waitForRateLimit() async {
    final now = DateTime.now();
    _requestTimestamps.add(now);
    
    if (_requestTimestamps.length > _maxRequestsPerMinute) {
      final oldestTimestamp = _requestTimestamps.removeAt(0);
      final timeSinceOldest = now.difference(oldestTimestamp);
      
      if (timeSinceOldest < const Duration(minutes: 1)) {
        final timeToWait = const Duration(minutes: 1) - timeSinceOldest;
        await Future.delayed(timeToWait);
      }
    }
  }
}