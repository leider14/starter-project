import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_avatarimage.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_button_icon.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/mywdg_appbar.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({super.key, this.article});
  

  @override
  Widget build(BuildContext context) {
    if (article == null) {
      return Scaffold(
        appBar: MyWdgAppbar(title: 'Article Details'),
        body: const Center(
          child: Text('Article not found'),
        ),
      );
    }
    print("--------");
    print(article?.toString());
    print("--------");
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        bool isBookmarked = false;
        if (state is LocalArticlesDone && article != null) {
          isBookmarked = state.articles!.any((a) => a.title == article?.title);
        }
        return Scaffold(
          appBar: MyWdgAppbar(title: 'Article Details'),
          body: _buildBody(context, isBookmarked),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, bool isBookmarked) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          _buildArticleImage(),
          Container(
            margin: const EdgeInsets.only(top: 200),
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorSection(context),
                _buildArticle(),
              ],
            ),
          ),
          Positioned(
              top: 200 - 23,
              right: 20,
              child: MyWdgButtonIcon(
                icon: Ionicons.bookmark,
                isActive: isBookmarked,
                onPressed: () {
                  _onFloatingActionButtonPressed(context, isBookmarked);
                },
              )),
          if (Uri.tryParse(article!.url ?? '')?.isAbsolute ?? false) 
          Positioned(
              top: 200 - 23,
              right: 65,
              child: MyWdgButtonIcon(
                icon: Icons.launch,
                onPressed: (article?.url != null && article!.url!.isNotEmpty)
                    ? () {
                        final url = article?.url;
                        if (url != null && url.isNotEmpty) {
                          launchUrlString(url);
                        }
                      }
                    : null,
              )),
        ],
      ),
    );
  }

  Widget _buildAuthorSection(BuildContext context) {
    final userId = article?.userId;
    return GestureDetector(
      onTap: (userId != null && userId.isNotEmpty)
          ? () {
              Navigator.pushNamed(context, '/Profile', arguments: userId);
            }
          : null,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            MywdgAvatarimage(
              urlImage: article?.authorImage ?? '',
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article?.author ?? 'Unknown',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                //SizedBox(height: 4,),
                Text(
                  article?.publishedAt?.toString() ?? 'Unknown date',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArticleImage() {
    final imageUrl = article?.urlToImage ?? '';
    return Container(
      color: const Color.fromARGB(255, 235, 235, 235),
      width: double.maxFinite,
      height: 250,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : const Center(
              child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            ),
    );
  }

  Widget _buildArticle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article?.title ?? 'No title',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${article?.description ?? ''}\n\n${article?.content ?? ''}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  void _onFloatingActionButtonPressed(BuildContext context, bool isBookmarked) {
    if (article == null) return;
    
    if (isBookmarked) {
      BlocProvider.of<LocalArticleBloc>(context).add(RemoveArticle(article!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text('Article removed successfully.'),
        ),
      );
    } else {
      BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text('Article saved successfully.'),
        ),
      );
    }
  }
}
