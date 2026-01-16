import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;
  final GetPublishedArticlesUseCase _getPublishedArticlesUseCase;

  RemoteArticlesBloc(
    this._getArticleUseCase,
    this._getPublishedArticlesUseCase,
  ) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    final bool isAllCategory =
        event.category == null || event.category == 'All';

    DataState<List<ArticleEntity>>? apiDataState;
    if (isAllCategory) {
      apiDataState = await _getArticleUseCase(params: {
        'category': null,
        'q': event.q,
      });
    }

    final firebaseDataState = await _getPublishedArticlesUseCase(params: {
      'category': isAllCategory ? null : event.category,
      'q': event.q,
    });

    List<ArticleEntity> combinedArticles = [];

    // Add Firestore articles first
    if (firebaseDataState is DataSuccess &&
        firebaseDataState.data!.isNotEmpty) {
      combinedArticles.addAll(firebaseDataState.data!);
    }

    // Add API articles only if it's "All" category
    if (isAllCategory &&
        apiDataState != null &&
        apiDataState is DataSuccess &&
        apiDataState.data!.isNotEmpty) {
      combinedArticles.addAll(apiDataState.data!);
    }

    if (combinedArticles.isNotEmpty) {
      emit(RemoteArticlesDone(combinedArticles));
    } else {
      if (apiDataState != null && apiDataState is DataFailed) {
        emit(RemoteArticlesError(apiDataState.error!));
      } else if (firebaseDataState is DataFailed) {
        emit(RemoteArticlesError(firebaseDataState.error!));
      } else {
        emit(const RemoteArticlesDone([]));
      }
    }
  }
}
