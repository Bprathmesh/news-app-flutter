import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories = [
    'General',
    'Business',
    'Technology',
    'Sports',
    'Entertainment',
    'Health',
    'Science',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        return Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(category),
                  selected: newsProvider.selectedCategory.toLowerCase() == category.toLowerCase(),
                  onSelected: (selected) {
                    if (selected) {
                      newsProvider.setCategory(category.toLowerCase());
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}