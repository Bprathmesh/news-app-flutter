import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../models/news_article.dart';
import 'news_detail_page.dart';
import '../widgets/news_list_item.dart';
import '../widgets/category_filter.dart';
import '../widgets/news_search_bar.dart';
import 'login_page.dart';
import 'bookmarked_news_page.dart';
import 'admin_panel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews();
    }
  }

  Future<void> _refreshNews() async {
    await Provider.of<NewsProvider>(context, listen: false).refreshNews();
  }

  void _showAdminPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Admin Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: "Password"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                if (_passwordController.text == 'bhardwaj') {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminPanelPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Incorrect password')),
                  );
                }
                _passwordController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: _showAdminPasswordDialog,
          ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkedNewsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          NewsSearchBar(),
          CategoryFilter(),
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                if (newsProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${newsProvider.error}'),
                        ElevatedButton(
                          onPressed: () => newsProvider.refreshNews(),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (newsProvider.articles.isEmpty && newsProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (newsProvider.articles.isEmpty) {
                  return const Center(child: Text('No articles found'));
                } else {
                  return RefreshIndicator(
                    onRefresh: _refreshNews,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: newsProvider.articles.length + 1,
                      itemBuilder: (context, index) {
                        if (index < newsProvider.articles.length) {
                          return NewsListItem(
                            article: newsProvider.articles[index],
                            onTap: () => _navigateToDetailPage(newsProvider.articles[index]),
                          );
                        } else if (newsProvider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetailPage(NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailPage(article: article),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}