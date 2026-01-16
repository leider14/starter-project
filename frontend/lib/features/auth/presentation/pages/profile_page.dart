import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_appbar.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_user.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';

class ProfilePage extends StatelessWidget {
  final bool showBackButton;
  final String? userId;

  const ProfilePage({Key? key, this.userId, this.showBackButton = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId =
            authState is Authenticated ? authState.user.uid : null;
        final targetUserId = userId ?? currentUserId;

        if (targetUserId == null) {
          return const Scaffold(
              body: Center(child: Text('Please login to view profile')));
        }

        final isOwnProfile = targetUserId == currentUserId;

        if (isOwnProfile && authState is Authenticated) {
          return _buildProfile(context, authState.user, isOwnProfile);
        } else {
          return FutureBuilder<DataState<UserEntity>>(
            future: sl<GetUserUseCase>().call(params: targetUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasData && snapshot.data is DataSuccess) {
                return _buildProfile(
                    context, snapshot.data!.data!, isOwnProfile);
              }
              return Scaffold(
                appBar: AppBar(),
                body: const Center(child: Text('Error loading profile')),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildProfile(
      BuildContext context, UserEntity user, bool isOwnProfile) {
    return Scaffold(
      appBar: MyWdgAppbar(
        title: isOwnProfile ? 'My Profile' : (user.fullName ?? 'Profile'),
        showBackButton: showBackButton,
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                context.read<AuthBloc>().add(AuthSignOutRequested());
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Facebook Style Header
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[300]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          user.photoUrl != null && user.photoUrl!.isNotEmpty
                              ? NetworkImage(user.photoUrl!)
                              : null,
                      child: user.photoUrl == null || user.photoUrl!.isEmpty
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Text(
              user.fullName ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                user.bio ?? 'No bio available',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            const Divider(height: 40, thickness: 1),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isOwnProfile ? 'My Articles' : 'Articles by ${user.fullName}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            FutureBuilder<DataState<List<ArticleEntity>>>(
              future: sl<ArticleRepository>().getArticlesByUser(user.uid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data is DataSuccess) {
                  final articles = snapshot.data!.data!;
                  if (articles.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No articles published yet.'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      return ArticleWidget(
                        article: articles[index],
                        onArticlePressed: (article) {
                          Navigator.pushNamed(context, '/ArticleDetails',
                              arguments: article);
                        },
                      );
                    },
                  );
                }
                return const Text('Error loading articles');
              },
            ),
          ],
        ),
      ),
    );
  }
}
