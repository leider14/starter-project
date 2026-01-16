import 'dart:io';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class PublishArticleUseCase implements UseCase<void, PublishArticleParams> {
  final ArticleRepository _articleRepository;

  PublishArticleUseCase(this._articleRepository);

  @override
  Future<void> call({PublishArticleParams? params}) {
    return _articleRepository.publishArticle(params!.article,
        image: params.image);
  }
}

class PublishArticleParams {
  final ArticleEntity article;
  final File? image;

  PublishArticleParams({required this.article, this.image});
}
