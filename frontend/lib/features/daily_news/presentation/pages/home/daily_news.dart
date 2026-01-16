import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_appbar.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_avatarimage.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_chip.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_featuredcard.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_floatingbutton.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_textfield.dart';
import '../../../domain/entities/article.dart';
import '../../widgets/mywdg_articletile.dart';

class DailyNews extends StatefulWidget {
  final bool showBackButton;
  const DailyNews({Key? key, this.showBackButton = true}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class Category {
  final String key;
  final String label;
  final IconData icon;

  const Category({
    required this.key,
    required this.label,
    required this.icon,
  });
}


class _DailyNewsState extends State<DailyNews> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<Category> _categories = const [
    Category(key: 'all', label: 'All', icon: Icons.category),
    Category(key: 'technology', label: 'Technology', icon: Icons.apple),
    Category(key: 'business', label: 'Business', icon: Icons.monetization_on),
    Category(key: 'nature', label: 'Nature', icon: Icons.park),
    Category(key: 'gossip', label: 'Gossip', icon: Icons.emoji_emotions_sharp),
    Category(key: 'diversion', label: 'Diversion', icon: Icons.rowing_outlined),
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
      backgroundColor: Colors.grey[100],
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
                    child: MyWdgTextField(
                      hintText: 'Search news by title...',
                      controller: _searchController,
                      onSubmitted: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _onSearchChanged();
                      },),
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
                            child: MywdgFeaturedcard(
                              article: filteredArticles[0],
                              onPressed: () {
                                _onArticlePressed(context, filteredArticles[0]);
                              },
                            )),
                        const SizedBox(width: 10),
                        Expanded(
                            child: MywdgFeaturedcard(
                              article: filteredArticles[1],
                              onPressed: () {
                                _onArticlePressed(context, filteredArticles[1]);
                              },
                            )),
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
                      final isSelected = _selectedCategory == category.label;
                      return MywdgChip(
                        text: category.label,
                        icon: category.icon,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category.label;
                          });
                          _onSearchChanged();
                        },
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


  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}
