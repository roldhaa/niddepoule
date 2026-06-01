import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/widgets/civic_banner.dart';
import 'package:niddepoule/core/widgets/civic_button.dart';
import 'package:niddepoule/core/widgets/civic_text_field.dart';
import 'package:niddepoule/features/auth/presentation/providers/auth_providers.dart';
import 'package:niddepoule/features/auth/presentation/widgets/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _formatError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    if (message.contains('permission-denied')) {
      return 'Accès Firestore refusé. Vérifiez les règles et App Check.';
    }
    return message;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    final result = ref.read(authControllerProvider);
    if (!mounted) return;

    if (result.hasError) {
      setState(() => _errorMessage = _formatError(result.error!));
      return;
    }
    context.go('/home/map');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Bon retour',
      subtitle: 'Connectez-vous pour accéder à la carte et signaler.',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              CivicBanner(message: _errorMessage!, type: CivicBannerType.error),
            CivicTextField(
              controller: _emailCtrl,
              label: 'Courriel',
              hint: 'vous@exemple.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Entrez votre courriel';
                if (!v.contains('@')) return 'Courriel invalide';
                return null;
              },
            ),
            AppSpacing.vLg,
            CivicTextField(
              controller: _passwordCtrl,
              label: 'Mot de passe',
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: true,
              obscureVisible: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Entrez votre mot de passe';
                return null;
              },
            ),
            AppSpacing.vXl,
            CivicButton(
              label: 'Se connecter',
              icon: Icons.login_rounded,
              isLoading: isLoading,
              onPressed: _submit,
            ),
            AppSpacing.vLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pas encore de compte ?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: isLoading ? null : () => context.go('/register'),
                  child: const Text(
                    'S\'inscrire',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandOrange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
