import 'dart:io';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // API methods
  Future<DataState<List<ArticleEntity>>> getNewsArticles(
      {String? q, String? category});

  // Database methods
  Future<List<ArticleEntity>> getSavedArticles();

  Future<void> saveArticle(ArticleEntity article);

  Future<void> removeArticle(ArticleEntity article);

  // Firebase methods
  Future<void> publishArticle(ArticleEntity article, {File? image});
  Future<DataState<List<ArticleEntity>>> getPublishedArticles(
      {String? q, String? category});
  Future<DataState<List<ArticleEntity>>> getArticlesByUser(String userId);
  Future<void> likeArticle(String articleId, String userId);
  Future<void> unlikeArticle(String articleId, String userId);
  Future<DataState<List<ArticleEntity>>> getLikedArticles(String userId);
}
