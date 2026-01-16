import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles(
      {String? q, String? category}) async {
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: category ?? categoryQuery,
        q: q,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO
        .insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> publishArticle(ArticleEntity article, {File? image}) async {
    try {
      String? imageUrl;

      // 1. Upload image to Cloud Storage if exists
      try {
        if (image != null) {
          final storageRef = FirebaseStorage.instance.ref().child(
              'media/articles/${DateTime.now().millisecondsSinceEpoch}.jpg');
          print("---------------");
          print(storageRef);
          print("---------------");
          await storageRef.putFile(image);
          print("---------------");
          print("Image uploaded successfully");
          print("---------------");
          imageUrl = await storageRef.getDownloadURL();
          print("---------------");
          print(imageUrl);
          print("---------------");
        }
      } catch (e) {
        print("---------------");
        print(e);
        print("---------------");
      }

      // 2. Save article to Firestore
      await FirebaseFirestore.instance.collection('articles').add({
        'userId': article.userId, 
        'author': article.author ?? 'Symmetry Journalist',
        'title': article.title,
        'description': article.description ?? '',
        'content': article.content ?? '',
        'thumbnailURL': imageUrl ?? kDefaultImage,
        'publishedAt': article.publishedAt ?? DateTime.now().toIso8601String(),
        'url': article.url ?? '',
        'authorImage': article.authorImage ?? '',
        'category': article.category ?? 'General',
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getPublishedArticles(
      {String? q, String? category}) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('articles')
          .orderBy('publishedAt', descending: true);

      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      final articles = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ArticleModel.fromJson({
          ...data,
          'firestoreId': doc.id,
          'urlToImage': data['thumbnailURL'] ?? kDefaultImage,
          'likes': data['likes'] ?? [],
          'authorImage': data['authorImage'] ?? '',
        });
      }).toList();

      if (q != null && q.isNotEmpty) {
        final filteredArticles = articles.where((article) {
          return article.title!.toLowerCase().contains(q.toLowerCase()) ||
              article.description!.toLowerCase().contains(q.toLowerCase());
        }).toList();
        return DataSuccess(filteredArticles);
      }

      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'firestore/articles'),
        error: e,
        type: DioExceptionType.unknown,
      ));
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getArticlesByUser(
      String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('articles')
          .where('userId', isEqualTo: userId)
          .orderBy('publishedAt', descending: true)
          .get();

      final articles = snapshot.docs.map((doc) {
        final data = doc.data();
        return ArticleModel.fromJson({
          ...data,
          'firestoreId': doc.id,
          'urlToImage': data['thumbnailURL'] ?? kDefaultImage,
          'likes': data['likes'] ?? [],
        });
      }).toList();

      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'firestore/articles/user'),
        error: e,
        type: DioExceptionType.unknown,
      ));
    }
  }

  @override
  Future<void> likeArticle(String articleId, String userId) async {
    await FirebaseFirestore.instance
        .collection('articles')
        .doc(articleId)
        .update({
      'likes': FieldValue.arrayUnion([userId])
    });
  }

  @override
  Future<void> unlikeArticle(String articleId, String userId) async {
    await FirebaseFirestore.instance
        .collection('articles')
        .doc(articleId)
        .update({
      'likes': FieldValue.arrayRemove([userId])
    });
  }

  @override
  Future<DataState<List<ArticleEntity>>> getLikedArticles(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('articles')
          .where('likes', arrayContains: userId)
          .orderBy('publishedAt', descending: true)
          .get();

      final articles = snapshot.docs.map((doc) {
        final data = doc.data();
        return ArticleModel.fromJson({
          ...data,
          'firestoreId': doc.id,
          'urlToImage': data['thumbnailURL'] ?? kDefaultImage,
          'likes': data['likes'] ?? [],
        });
      }).toList();

      return DataSuccess(articles);
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'firestore/articles/liked'),
        error: e,
        type: DioExceptionType.unknown,
      ));
    }
  }
}
