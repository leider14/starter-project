import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_articletile.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_appbar.dart';

class LikedArticlesPage extends StatelessWidget {
  final bool showBackButton;
  const LikedArticlesPage({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is! Authenticated) {
        return Scaffold(
          appBar: MyWdgAppbar(
            title: 'Liked Articles',
            showBackButton: showBackButton,
          ),
          body: const Center(
            child: Text('Please login to see your liked articles'),
          ),
        );
      }

      final userId = authState.user.uid;

      return Scaffold(
        appBar: MyWdgAppbar(
          title: 'Liked Articles',
          showBackButton: showBackButton,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('articles')
              .where('likes', arrayContains: userId)
              .orderBy('publishedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading liked articles',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No liked articles yet'));
            }

            final articles = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ArticleModel.fromJson({
                ...data,
                'firestoreId': doc.id,
                'urlToImage': data['thumbnailURL'] ?? kDefaultImage,
                'likes': data['likes'] ?? [],
              });
            }).toList();

            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return MywdgArticleTile(
                  article: articles[index],
                  onArticlePressed: (article) {
                    Navigator.pushNamed(context, '/ArticleDetails',
                        arguments: article);
                  },
                );
              },
            );
          },
        ),
      );
    });
  }
}
