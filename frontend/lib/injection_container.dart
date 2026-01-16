import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_liked_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/domain/usecases/publish_article.dart';
import 'features/daily_news/domain/usecases/get_published_articles.dart';
import 'features/daily_news/domain/usecases/get_articles_by_user.dart';
import 'features/daily_news/domain/usecases/like_article.dart';
import 'features/daily_news/presentation/bloc/article/publish/publish_article_cubit.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_user.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl(), sl(), sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(),sl())
    );

  //UseCases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));
  sl.registerSingleton<GetArticlesByUserUseCase>(
      GetArticlesByUserUseCase(sl()));
  sl.registerSingleton<LikeArticleUseCase>(LikeArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  sl.registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl()));

  sl.registerSingleton<GetPublishedArticlesUseCase>(
      GetPublishedArticlesUseCase(sl()));
  sl.registerSingleton<GetLikedArticlesUseCase>(GetLikedArticlesUseCase(sl()));
  sl.registerSingleton<GetUserUseCase>(GetUserUseCase(sl()));

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl(), sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  sl.registerFactory<AuthBloc>(() => AuthBloc(sl())..add(AuthCheckRequested()));

  sl.registerFactory<PublishArticleCubit>(() => PublishArticleCubit(sl()));
}
