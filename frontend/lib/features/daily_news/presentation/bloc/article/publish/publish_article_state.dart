part of 'publish_article_cubit.dart';

abstract class PublishArticleState extends Equatable {
  const PublishArticleState();

  @override
  List<Object?> get props => [];
}

class PublishArticleInitial extends PublishArticleState {
  const PublishArticleInitial();
}

class PublishArticleLoading extends PublishArticleState {
  const PublishArticleLoading();
}

class PublishArticleSuccess extends PublishArticleState {
  const PublishArticleSuccess();
}

class PublishArticleError extends PublishArticleState {
  final String message;
  const PublishArticleError(this.message);

  @override
  List<Object?> get props => [message];
}
