import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/like_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_avatarimage.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import '../../domain/entities/article.dart';

class ArticleWidget extends StatefulWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  }) : super(key: key);

  @override
  State<ArticleWidget> createState() => _ArticleWidgetState();
}

class _ArticleWidgetState extends State<ArticleWidget> {
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is Authenticated ? authState.user.uid : null;
    _isLiked = widget.article?.likes?.contains(currentUserId) ?? false;
    _likesCount = widget.article?.likes?.length ?? 0;
  }

  void _toggleLike() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like articles')),
      );
      Navigator.pushNamed(context, '/Auth');
      return;
    }

    final userId = authState.user.uid;
    final articleId = widget.article?.firestoreId;

    if (articleId == null) return;

    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likesCount--;
      } else {
        _isLiked = true;
        _likesCount++;
      }
    });

    try {
      await sl<LikeArticleUseCase>().call(
        params: LikeArticleParams(
          articleId: articleId,
          userId: userId!,
          isLiked: !_isLiked,
        ),
      );
    } catch (e) {
      // Revert if failed
      setState(() {
        if (_isLiked) {
          _isLiked = false;
          _likesCount--;
        } else {
          _isLiked = true;
          _likesCount++;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.only(
            start: 14, end: 14, bottom: 7, top: 7),
        height: MediaQuery.of(context).size.width / 2.2,
        child: Row(
          children: [
            _buildImage(context),
            _buildTitleAndDescription(),
            _buildRemovableArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 5),
          child: CachedNetworkImage(
              imageUrl: widget.article!.urlToImage!,
              imageBuilder: (context, imageProvider) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.08),
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover)),
                      ),
                    ),
                  ),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: double.maxFinite,
                        child: CupertinoActivityIndicator(),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ),
              errorWidget: (context, url, error) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: double.maxFinite,
                        child: Icon(Icons.error),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                    ),
                  )),
        ),
        Positioned(
            bottom: 0,
            right: 10,
            child:
                MywdgAvatarimage(urlImage: widget.article!.authorImage ?? ""))
      ],
    );
  }

  Widget _buildTitleAndDescription() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 232, 232, 232),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Text(
                          widget.article!.author ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (widget.article!.category != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Text(
                            widget.article!.category!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<LocalArticleBloc, LocalArticlesState>(
                  builder: (context, state) {
                    bool isBookmarked = false;
                    if (state is LocalArticlesDone) {
                      isBookmarked = state.articles!.any((a) =>
                          a.url == widget.article!.url ||
                          (a.title == widget.article!.title &&
                              a.author == widget.article!.author));
                    }
                    return GestureDetector(
                      onTap: () => _toggleBookmark(context, isBookmarked),
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.black : Colors.grey,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_likesCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isLiked ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                widget.article!.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Butler',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),

            // Description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.article!.description ?? '',
                  maxLines: 2,
                ),
              ),
            ),

            // Datetime
            Row(
              children: [
                const Icon(Icons.timeline_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.article!.publishedAt!,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovableArea() {
    if (widget.isRemovable!) {
      return GestureDetector(
        onTap: _onRemove,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.remove_circle_outline, color: Colors.red),
        ),
      );
    }
    return Container();
  }

  void _onTap() {
    if (widget.onArticlePressed != null) {
      widget.onArticlePressed!(widget.article!);
    }
  }

  void _onRemove() {
    if (widget.onRemove != null) {
      widget.onRemove!(widget.article!);
    }
  }

  void _toggleBookmark(BuildContext context, bool isBookmarked) {
    if (isBookmarked) {
      context.read<LocalArticleBloc>().add(RemoveArticle(widget.article!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article removed from bookmarks')),
      );
    } else {
      context.read<LocalArticleBloc>().add(SaveArticle(widget.article!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article saved to bookmarks')),
      );
    }
  }
}
