import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetPublishedArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, Map<String, String?>> {
  final ArticleRepository _articleRepository;

  GetPublishedArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({Map<String, String?>? params}) {
    return _articleRepository.getPublishedArticles(
      category: params?['category'],
      q: params?['q'],
    );
  }
}
