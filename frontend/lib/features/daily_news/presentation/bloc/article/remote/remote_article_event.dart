abstract class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent {
  final String? category;
  final String? q;
  const GetArticles({this.category, this.q});
}
