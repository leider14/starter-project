import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_appbar.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_button.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_textfield.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import '../../bloc/article/publish/publish_article_cubit.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_event.dart';

class PublishArticlePage extends StatefulWidget {
  const PublishArticlePage({Key? key}) : super(key: key);

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  String? _selectedCategory = "Technology";
  String? _titleError;
  String? _contentError;

  final List<String> _categories = [
    "Technology",
    "Business",
    "Nature",
    "Gossip",
    "Diversion",
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Verifica si hay contenido en los campos
  bool _hasContent() {
    return _titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _urlController.text.isNotEmpty ||
        _image != null;
  }

  // Muestra diálogo de confirmación al salir
  Future<bool> _onWillPop() async {
    if (!_hasContent()) {
      return true; // No hay contenido, puede salir sin confirmación
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '¿Estás seguro de salir?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Al salir no guardarás el progreso de este artículo nuevo.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Descartar',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PublishArticleCubit>(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;
          
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
          bottomNavigationBar: _buildBottomCTA(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return MyWdgAppbar(
      title: 'Publish Article',
      onBackTapped: () async {
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          const Text(
            "Image",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: _image != null
                  ? Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 10,
                          child: MyWdgButton(
                              text: "Edit",
                              icon: Icons.edit,
                              onPressed: () => _pickImage()),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add_photo_alternate,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 10,
                          child: MyWdgButton(
                              text: "Add",
                              icon: Icons.add,
                              onPressed: () => _pickImage()),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          // Category Selection
          const Text(
            "Category",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Title Input
          MyWdgTextField(
            title: 'Title',
            controller: _titleController,
            hintText: 'Write your title here...',
            isRequired: true,
            errorText: _titleError,
            helpText:
                'Ingresa un título llamativo para tu noticia. Esto es lo primero que verán los lectores.',
            maxLength: 50,
          ),
          const SizedBox(height: 20),

          // Description Input
          MyWdgTextField(
            title: 'Description',
            controller: _descriptionController,
            hintText: 'A short summary of the article...',
            maxLines: 2,
            helpText: 'Un resumen breve para mostrar en la lista de noticias.',
          ),
          const SizedBox(height: 20),

          // URL Input
          MyWdgTextField(
            title: 'Source URL',
            controller: _urlController,
            hintText: 'https://example.com/article',
            helpText: 'Link opcional a la fuente original de la noticia.',
          ),
          const SizedBox(height: 20),

          // Content Input
          MyWdgTextField(
            title: 'Content',
            controller: _contentController,
            hintText: 'Add article here, .....',
            maxLines: 8,
            isRequired: true,
            errorText: _contentError,
            helpText:
                'Escribe aquí el cuerpo de la noticia. Sé detallado y directo.',
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(BuildContext context) {
    return BlocConsumer<PublishArticleCubit, PublishArticleState>(
      listener: (context, state) {
        if (state is PublishArticleSuccess) {
          context.read<RemoteArticlesBloc>().add(const GetArticles());
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article published successfully!')),
          );
          Navigator.pop(context);
        } else if (state is PublishArticleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: MyWdgButton(
            isLoading: state is PublishArticleLoading,
            text: state is PublishArticleLoading
                ? 'Publishing...'
                : 'Publish Article',
            icon: Icons.newspaper,
            onPressed: () {
              setState(() {
                _titleError = _titleController.text.isEmpty
                    ? 'Por favor, llena este campo'
                    : null;
                _contentError = _contentController.text.isEmpty
                    ? 'Por favor, llena este campo'
                    : null;
              });

              if (_titleError == null && _contentError == null) {
                final authState = context.read<AuthBloc>().state;
                String? userId;
                String? authorName;
                String? authorImage;

                if (authState is Authenticated) {
                  userId = authState.user.uid;
                  authorName = authState.user.fullName;
                  authorImage = authState.user.photoUrl;
                  print(authState.user.photoUrl ?? "");
                }

                context.read<PublishArticleCubit>().publishArticle(
                      title: _titleController.text,
                      content: _contentController.text,
                      description: _descriptionController.text,
                      author: authorName,
                      url: _urlController.text,
                      userId: userId,
                      image: _image,
                      authorImage: authorImage,
                      category: _selectedCategory,
                    );
              }
            },
          ),
        );
      },
    );
  }
}
