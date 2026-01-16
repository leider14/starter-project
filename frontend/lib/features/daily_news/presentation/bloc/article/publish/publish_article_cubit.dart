import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/publish_article.dart';

part 'publish_article_state.dart';

class PublishArticleCubit extends Cubit<PublishArticleState> {
  final PublishArticleUseCase _publishArticleUseCase;

  PublishArticleCubit(this._publishArticleUseCase)
      : super(const PublishArticleInitial());

  Future<void> publishArticle({
    required String title,
    required String content,
    String? description,
    String? author,
    String? url,
    String? userId, // Added userId
    File? image,
    String? authorImage,
    String? category, // Added category
  }) async {
    emit(const PublishArticleLoading());

    try {
      final article = ArticleEntity(
        title: title,
        content: content,
        description: description,
        author: author ?? 'Symmetry Journalist',
        url: url,
        userId: userId, // Added userId
        authorImage: authorImage,
        category: category, // Added category
        publishedAt: DateTime.now().toIso8601String(),
      );

      await _publishArticleUseCase(
        params: PublishArticleParams(article: article, image: image),
      );

      emit(const PublishArticleSuccess());
    } catch (e) {
      emit(PublishArticleError(e.toString()));
    }
  }

  void reset() => emit(const PublishArticleInitial());
}
