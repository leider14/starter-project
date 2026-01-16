import 'package:flutter/material.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';
import '../../features/daily_news/presentation/pages/publish_article/publish_article.dart';
import '../../features/auth/presentation/pages/login_register_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';

import '../../features/daily_news/presentation/pages/home/main_scaffold.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const MainScaffold());

      case '/ArticleDetails':
        return _materialRoute(
            ArticleDetailsView(article: settings.arguments as ArticleEntity));

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/AddArticle':
        return _materialRoute(const PublishArticlePage());

      case '/Auth':
        return _materialRoute(const LoginRegisterPage());

      case '/Profile':
        return _materialRoute(
            ProfilePage(userId: settings.arguments as String?));

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
