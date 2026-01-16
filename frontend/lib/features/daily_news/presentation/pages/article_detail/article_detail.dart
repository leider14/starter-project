import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/mywdg_appbar.dart';
import '../../widgets/mywdg_floatingbutton.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        bool isBookmarked = false;
        if (state is LocalArticlesDone) {
          isBookmarked = state.articles!.any((a) => a.title == article!.title);
        }
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(context),
          floatingActionButton:
              _buildFloatingActionButton(context, isBookmarked),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return const MyWdgAppbar(
      title: 'Article Details',
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          _buildArticleImage(),
          Container(
            margin: const EdgeInsets.only(top: 200),
            padding: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildArticleTitleAndDate(),
                _buildAuthorSection(context),
                _buildArticleDescription(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article!.title!,
            style: const TextStyle(
                fontFamily: 'Butler',
                fontSize: 20,
                fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 14),
          // DateTime
          Row(
            children: [
              const Icon(Ionicons.time_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                article!.publishedAt!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection(BuildContext context) {
    if (article?.userId == null || article!.userId!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: Text(
          'Author: ${article?.author ?? 'Unknown'}',
          style: const TextStyle(
              fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/Profile', arguments: article!.userId);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article?.author ?? 'Unknown Author',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'View Profile',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleImage() {
    return Container(
      color: const Color.fromARGB(255, 235, 235, 235),
      width: double.maxFinite,
      height: 250,
      child: CachedNetworkImage(
        imageUrl: article!.urlToImage!,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.error),
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildArticleDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        '${article!.description ?? ''}\n\n${article!.content ?? ''}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, bool isBookmarked) {
    return MyWdgFloatingButton(
      isActive: isBookmarked,
      onPressed: () => _onFloatingActionButtonPressed(context, isBookmarked),
      icon: isBookmarked ? Ionicons.bookmark : Ionicons.bookmark_outline,
    );
  }

  void _onFloatingActionButtonPressed(BuildContext context, bool isBookmarked) {
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
