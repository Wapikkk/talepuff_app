import 'package:flutter/material.dart';
import '../../widgets/login/login_header.dart';
import '../../widgets/login/login_input_form.dart';
import '../../widgets/login/login_btn.dart';
import 'package:provider/provider.dart';
import '../../view_models/login_view_model.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}
class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loginVM = Provider.of<LoginViewModel>(context, listen: false);

      await loginVM.loadSavedEmail();

      if (loginVM.email.isNotEmpty && mounted) {
        setState(() {
          _emailController.text = loginVM.email;
        });
        debugPrint("DEBUG UI: Email dipasang ke controller: ${loginVM.email}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LoginHeader(),
                const SizedBox(height: 40),
                LoginInputForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
                const SizedBox(height: 30),
                const LoginButton(),
                const SizedBox(height: 12),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: viewModel.errorMessage != null ? 1.0 : 0.0,
                  curve: Curves.easeInOut,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      viewModel.errorMessage ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppAssets.fontFamily,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 15,
                          fontFamily: AppAssets.fontFamily,
                        ),
                        children: [
                          TextSpan(text: "New User? "),
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}