import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews();
      _animationController.forward();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<NewsProvider>(context, listen: false).fetchNews();
    }
  }

  Future<void> _refreshNews() async {
    await Provider.of<NewsProvider>(context, listen: false).refreshNews();
    _animationController.reset();
    _animationController.forward();
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () => _validateAdminPassword(),
            ),
          ],
        );
      },
    );
  }

  void _validateAdminPassword() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ThemeProvider, NewsProvider>(
      builder: (context, authProvider, themeProvider, newsProvider, _) {
        return Scaffold(
          appBar: _buildAppBar(authProvider, themeProvider),
          body: Column(
            children: [
              NewsSearchBar(),
              CategoryFilter(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: _buildNewsList(newsProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(AuthProvider authProvider, ThemeProvider themeProvider) {
    return AppBar(
      title: const Text('News App'),
      actions: [
        IconButton(
          icon: Icon(Icons.admin_panel_settings),
          onPressed: _showAdminPasswordDialog,
        ),
        IconButton(
          icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: themeProvider.toggleTheme,
        ),
        IconButton(
          icon: const Icon(Icons.bookmark),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookmarkedNewsPage()),
          ),
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
    );
  }

  Widget _buildNewsList(NewsProvider newsProvider) {
    if (newsProvider.error != null) {
      return _buildErrorWidget(newsProvider);
    } else if (newsProvider.articles.isEmpty && newsProvider.isLoading) {
      return Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 500),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: child,
            );
          },
          child: CircularProgressIndicator(),
        ),
      );
    } else if (newsProvider.articles.isEmpty) {
      return Center(child: Text('No articles found'));
    } else {
      return RefreshIndicator(
        onRefresh: _refreshNews,
        child: AnimationLimiter(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: newsProvider.articles.length + 1,
            itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildListItem(newsProvider, index),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildErrorWidget(NewsProvider newsProvider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${newsProvider.error}'),
            ElevatedButton(
              onPressed: newsProvider.refreshNews,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(NewsProvider newsProvider, int index) {
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
  }

  void _navigateToDetailPage(NewsArticle article) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NewsDetailPage(article: article),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}