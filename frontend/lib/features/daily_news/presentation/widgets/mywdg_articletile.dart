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

class MywdgArticleTile extends StatefulWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const MywdgArticleTile({
    super.key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  });

  @override
  State<MywdgArticleTile> createState() => _MywdgArticleTileState();
}

class _MywdgArticleTileState extends State<MywdgArticleTile> {
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color:  Colors.grey.shade300,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: widget.isRemovable! ? 8 : 4,
        ),
        height: MediaQuery.of(context).size.width / 2.5,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de imagen con avatar
            _buildImageSection(context),
            
            // Espaciado entre imagen y contenido
            const SizedBox(width: 14),
            
            // Sección de contenido principal
            Expanded(
              child: _buildContentSection(),
            ),
            
            // Sección de acciones removibles (si aplica)
            if (widget.isRemovable!) _buildRemovableSection(),
          ],
        ),
      ),
    );
  }

  // SECCIÓN 1: IMAGEN Y AVATAR DEL AUTOR
  Widget _buildImageSection(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Imagen principal del artículo
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.width / 4,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.08),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.article!.urlToImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CupertinoActivityIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        
        // Avatar del autor superpuesto
        if (widget.article!.authorImage != null && widget.article!.authorImage!.isNotEmpty)
          Positioned(
            right: 0,
            bottom: 0,
            child: MywdgAvatarimage(urlImage: widget.article!.authorImage!),
          ),
      ],
    );
  }

  // SECCIÓN 2: CONTENIDO PRINCIPAL
  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: Información del artículo
          _buildArticleInfoRow(),
          
          // Título del artículo
          _buildArticleTitle(),
          
          // Descripción del artículo
          _buildArticleDescription(),
          
          // Fila inferior: Fecha y estadísticas
          _buildArticleFooter(),
        ],
      ),
    );
  }

  // Fila superior con información del artículo
  Widget _buildArticleInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información del autor y categoría
        if (widget.article!.category != null && widget.article!.category!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
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
        
        // Acciones del usuario
        _buildUserActions(),
      ],
    );
  }

  // Acciones del usuario (bookmark y like)
  Widget _buildUserActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bookmark
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.black : Colors.grey,
                  size: 20,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 5),
        
        // Like
        if (widget.article?.firestoreId != null && widget.article!.firestoreId!.isNotEmpty) 
        GestureDetector(
          onTap: _toggleLike,
          child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
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
        ),
      ],
    );
  }

  // Título del artículo
  Widget _buildArticleTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        widget.article!.title ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Butler',
          fontWeight: FontWeight.w900,
          fontSize: 18,
          color: Colors.black87,
          height: 1.2,
        ),
      ),
    );
  }

  // Descripción del artículo
  Widget _buildArticleDescription() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          widget.article!.description ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // Pie de artículo con fecha
  Widget _buildArticleFooter() {
    return Row(
      children: [
        const Icon(
          Icons.access_time_outlined,
          size: 14,
          color: Colors.grey,
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 80,
          child: Text(
            widget.article!.publishedAt!,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // SECCIÓN 3: ACCIÓN REMOVIBLE (solo si aplica)
  Widget _buildRemovableSection() {
    return GestureDetector(
      onTap: _onRemove,
      child: const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(
          Icons.remove_circle_outline,
          color: Colors.red,
          size: 22,
        ),
      ),
    );
  }

  // MÉTODOS DE INTERACCIÓN
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