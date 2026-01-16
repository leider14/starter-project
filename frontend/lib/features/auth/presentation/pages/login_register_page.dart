import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_appbar.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_button.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/mywdg_textfield.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginRegisterPage extends StatefulWidget {
  final bool showBackButton;
  const LoginRegisterPage({Key? key, this.showBackButton = false})
      : super(key: key);

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _image;
  bool _isLogin = true;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (_isLogin) {
      context.read<AuthBloc>().add(AuthSignInRequested(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          ));
    } else {
      context.read<AuthBloc>().add(AuthSignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _nameController.text.trim(),
            bio: _bioController.text.trim(),
            image: _image,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: MyWdgAppbar(
            showBackButton: widget.showBackButton,
            title: _isLogin ? 'Login' : 'Create Account',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (!_isLogin) ...[
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.add_a_photo,
                              size: 30, color: Colors.black)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  MyWdgTextField(
                    title: 'Full Name',
                    controller: _nameController,
                    hintText: 'Your name',
                  ),
                  const SizedBox(height: 16),
                  MyWdgTextField(
                    title: 'Bio',
                    controller: _bioController,
                    hintText: 'Tell us about yourself',
                  ),
                  const SizedBox(height: 16),
                ],
                MyWdgTextField(
                  title: 'Email',
                  controller: _emailController,
                  hintText: 'you@example.com',
                ),
                const SizedBox(height: 16),
                MyWdgTextField(
                  title: 'Password',
                  controller: _passwordController,
                  hintText: '••••••••',
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                MyWdgButton(
                  text: _isLogin ? 'Login' : 'Register',
                  isLoading: state is AuthLoading,
                  onPressed: _submit,
                ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Login"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
