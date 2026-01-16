import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final int? id;
  final String? firestoreId;
  final String? userId;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final List<String>? likes;
  final String? category;
  final String? authorImage;

  const ArticleEntity({
    this.id,
    this.firestoreId,
    this.userId,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.likes,
    this.category,
    this.authorImage,
  });

  @override
  List<Object?> get props {
    return [
      id,
      firestoreId,
      userId,
      author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
      likes,
      category,
      authorImage,
    ];
  }
}
