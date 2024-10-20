class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String content;
  final String author;
  final String publishedAt;
  final String source;
  bool isBookmarked;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.content,
    required this.author,
    required this.publishedAt,
    required this.source,
    this.isBookmarked = false,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'content': content,
      'author': author,
      'publishedAt': publishedAt,
      'source': source,
      'isBookmarked': isBookmarked,
    };
  }
}