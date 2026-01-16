import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_appbar.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_avatarimage.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_floatingbutton.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_appbar.dart';
import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatefulWidget {
  final bool showBackButton;
  const DailyNews({Key? key, this.showBackButton = true}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Technology",
    "Business",
    "Nature",
    "Gossip",
    "Diversion",
  ];

  void _onSearchChanged() {
    context.read<RemoteArticlesBloc>().add(GetArticles(
          q: _searchController.text.isNotEmpty ? _searchController.text : null,
          category: _selectedCategory != "All" ? _selectedCategory : null,
        ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWdgAppbar(
        title: 'Daily News',
        showBackButton: widget.showBackButton,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: MywdgAvatarimage(
                    urlImage:
                        state is Authenticated ? state.user.photoUrl ?? "" : "",
                    onTap: () {
                      if (state is Authenticated) {
                        Navigator.pushNamed(context, '/Profile');
                      } else {
                        Navigator.pushNamed(context, '/Auth');
                      }
                    },
                  ));
            },
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: MyWdgFloatingButton(
        onPressed: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is Authenticated) {
            Navigator.pushNamed(context, '/AddArticle');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please log in to publish articles')),
            );
            Navigator.pushNamed(context, '/Auth');
          }
        },
        icon: Icons.add,
      ),
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return MyWdgAppbar(
      title: 'Daily News',
      showBackButton: false,
      actions: [],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (_, state) {
        if (state is RemoteArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is RemoteArticlesError) {
          return const Center(child: Icon(Icons.refresh));
        }
        if (state is RemoteArticlesDone) {
          final allArticles = state.articles ?? [];
          final filteredArticles = allArticles.where((article) {
            final matchesSearch = article.title
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                true;
            return matchesSearch;
          }).toList();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Title: Explore all world news
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Explore Today\'s\nWorld News',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Butler',
                    ),
                  ),
                ),

                // 2. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _onSearchChanged();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search news by title...',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = "";
                                  });
                                  _onSearchChanged();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. (Last 2 articles)
                if (filteredArticles.length >= 2)
                  Container(
                    height: 220,
                    width: MediaQuery.of(context).size.width - 40,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                            child: _buildFeaturedCard(
                                context, filteredArticles[0])),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildFeaturedCard(
                                context, filteredArticles[1])),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // 4. Banner Promotions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.indigo],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Hub',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Here you can find the latest news, publish and expand your knowledge on topics with the news community.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Categories Section
                Container(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                              _onSearchChanged();
                            }
                          },
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 6. General Feed
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    return ArticleWidget(
                      article: filteredArticles[index],
                      onArticlePressed: (article) =>
                          _onArticlePressed(context, article),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildFeaturedCard(BuildContext context, ArticleEntity article) {
    return GestureDetector(
      onTap: () => _onArticlePressed(context, article),
      child: Container(
        height: 200,
        width: double.maxFinite,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(article.urlToImage ?? ''),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.author ?? 'Unknown',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              article.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Butler',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}
