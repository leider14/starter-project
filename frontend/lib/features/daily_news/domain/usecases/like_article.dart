import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class LikeArticleUseCase implements UseCase<void, LikeArticleParams> {
  final ArticleRepository _articleRepository;

  LikeArticleUseCase(this._articleRepository);

  @override
  Future<void> call({LikeArticleParams? params}) async {
    if (params!.isLiked) {
      return _articleRepository.unlikeArticle(params.articleId, params.userId);
    } else {
      return _articleRepository.likeArticle(params.articleId, params.userId);
    }
  }
}

class LikeArticleParams {
  final String articleId;
  final String userId;
  final bool isLiked;

  LikeArticleParams({
    required this.articleId,
    required this.userId,
    required this.isLiked,
  });
}
