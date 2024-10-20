import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news_article.dart';

class NewsService {
  final String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

  Future<List<NewsArticle>> getNews({String? category, String? query, int page = 1}) async {
    String url = '$_baseUrl/top-headlines?country=us&pageSize=10&page=$page';

    if (category != null && category.isNotEmpty) {
      url += '&category=$category';
    }

    if (query != null && query.isNotEmpty) {
      url += '&q=$query';
    }

    url += '&apiKey=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> articles = jsonData['articles'];
      return articles.map((article) => NewsArticle.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}