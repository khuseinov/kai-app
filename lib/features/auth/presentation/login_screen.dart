import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/components/kai_button.dart';
import '../../../core/design/components/kai_text_field.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../../../core/design/theme/theme_extensions.dart';
import '../logic/auth_notifier.dart';
import '../logic/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next is Authenticated) {
        context.go('/chat');
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: colors.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: KaiSpacing.screenPadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.flight_takeoff,
                    size: 64,
                    color: colors.primary,
                  ),
                  const SizedBox(height: KaiSpacing.xl),
                  Text(
                    'С возвращением!',
                    style: typography.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: KaiSpacing.xxs),
                  Text(
                    'Войдите в аккаунт, чтобы продолжить',
                    style: typography.bodyLarge.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: KaiSpacing.xxl),
                  KaiTextField(
                    hintText: 'Email',
                    controller: _emailController,
                    prefixIcon: const Icon(Icons.email_outlined),
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: KaiSpacing.s),
                  KaiTextField(
                    hintText: 'Пароль',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: KaiSpacing.xl),
                  KaiButton(
                    label: 'Войти',
                    onPressed: _submit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: KaiSpacing.l),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(
                      'Нет аккаунта? Зарегистрироваться',
                      style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
