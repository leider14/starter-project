import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_liked_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_appbar.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

class LikedArticlesPage extends StatelessWidget {
  final bool showBackButton;
  const LikedArticlesPage({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            appBar: MyWdgAppbar(
                title: 'Liked Articles', showBackButton: showBackButton),
            body: Center(
              child: Text('Please login to see your liked articles'),
            ),
          );
        }

        return Scaffold(
          appBar: MyWdgAppbar(
            title: 'Liked Articles',
            showBackButton: showBackButton,
          ),
          body: FutureBuilder<DataState<List<ArticleEntity>>>(
            future:
                sl<GetLikedArticlesUseCase>().call(params: authState.user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData && snapshot.data is DataSuccess) {
                final articles = snapshot.data!.data!;
                if (articles.isEmpty) {
                  return const Center(child: Text('No liked articles yet'));
                }

                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return ArticleWidget(
                      article: articles[index],
                      onArticlePressed: (article) {
                        Navigator.pushNamed(context, '/ArticleDetails',
                            arguments: article);
                      },
                    );
                  },
                );
              }

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
                        'This is likely due to a missing Firestore index. Please check your debug console and click the link to create the index.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
