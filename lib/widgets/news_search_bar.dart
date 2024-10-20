import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';

class NewsSearchBar extends StatefulWidget {
  @override
  _NewsSearchBarState createState() => _NewsSearchBarState();
}

class _NewsSearchBarState extends State<NewsSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search news...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Provider.of<NewsProvider>(context, listen: false).setSearchQuery(value);
          }
        },
      ),
    );
  }
}