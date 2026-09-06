import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});
  final VoidCallback onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _demoEmail = 'demo@biletfy.com';
  static const _demoPassword = 'Biletfy123';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registerMode = false;
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setMode(bool register) {
    if (_submitting) return;
    setState(() {
      _registerMode = register;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    if (_registerMode) {
      widget.onLogin();
      return;
    }
    final valid =
        _emailController.text.trim().toLowerCase() == _demoEmail &&
        _passwordController.text == _demoPassword;
    if (!valid) {
      setState(() {
        _submitting = false;
        _errorMessage = 'E-posta veya şifre hatalı';
      });
      return;
    }
    widget.onLogin();
  }

  Future<void> _forgotPassword() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) =>
          _ForgotPasswordDialog(initialEmail: _emailController.text),
    );
    if (!mounted || email == null || email.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Şifre yenileme bağlantısı $email için hazırlandı.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.screenX),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: AppSpace.sectionGap),
                    _ModeSelector(
                      registerMode: _registerMode,
                      onChanged: _setMode,
                    ),
                    const SizedBox(height: AppSpace.sectionGap),
                    if (_registerMode) ...[
                      const _FieldLabel(text: 'Ad Soyad'),
                      const SizedBox(height: AppSpace.chipGap),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(
                          hint: 'Adınızı ve soyadınızı girin',
                          icon: AppIcons.user,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Ad Soyad boş bırakılamaz'
                            : null,
                      ),
                      const SizedBox(height: AppSpace.cardPadding),
                    ],
                    const _FieldLabel(text: 'E-posta veya Telefon'),
                    const SizedBox(height: AppSpace.chipGap),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: _decoration(
                        hint: 'ornek@biletfy.com',
                        icon: AppIcons.mail,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'E-posta boş bırakılamaz';
                        }
                        if (!email.contains('@')) {
                          return 'Geçerli bir e-posta girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpace.cardPadding),
                    const _FieldLabel(text: 'Şifre'),
                    const SizedBox(height: AppSpace.chipGap),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: _decoration(
                        hint: 'En az 6 karakter',
                        icon: AppIcons.lock,
                        suffix: IconButton(
                          tooltip: _obscurePassword
                              ? 'Şifreyi göster'
                              : 'Şifreyi gizle',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword ? AppIcons.eye : AppIcons.eyeOff,
                          ),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Şifre en az 6 karakter olmalı'
                          : null,
                    ),
                    if (!_registerMode) ...[
                      const SizedBox(height: AppSpace.chipGap),
                      Row(
                        children: [
                          SizedBox(
                            width: AppSize.minTouch,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Switch(
                                value: _rememberMe,
                                onChanged: (value) =>
                                    setState(() => _rememberMe = value),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          Expanded(
                            child: Text(
                              'Beni Hatırla',
                              style: AppTypography.caption,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpace.xs,
                              ),
                              minimumSize: const Size(0, AppSize.minTouch),
                            ),
                            onPressed: _forgotPassword,
                            child: Text(
                              'Şifremi Unuttum?',
                              style: AppTypography.micro.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpace.chipGap),
                      Text(
                        _errorMessage!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.danger,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpace.cardPadding),
                    SizedBox(
                      height: AppSize.minTouch,
                      child: FilledButton.icon(
                        key: const Key('auth-submit'),
                        onPressed: _submitting ? null : _submit,
                        iconAlignment: IconAlignment.end,
                        icon: _submitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(AppIcons.arrowRight),
                        label: Text(_registerMode ? 'Kayıt Ol' : 'Giriş Yap'),
                      ),
                    ),
                    if (!_registerMode) ...[
                      const SizedBox(height: AppSpace.cardGap),
                      OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(AppIcons.fingerprint),
                        label: const Text('Face ID ile Hızlı Giriş'),
                      ),
                      const SizedBox(height: AppSpace.cardPadding),
                      const _DividerLabel(),
                      const SizedBox(height: AppSpace.cardPadding),
                      Row(
                        children: [
                          Expanded(
                            child: _ProviderButton(
                              label: 'Apple',
                              onPressed: null,
                            ),
                          ),
                          const SizedBox(width: AppSpace.cardGap),
                          Expanded(
                            child: _ProviderButton(
                              label: 'Google',
                              onPressed: null,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpace.cardPadding),
                    TextButton(
                      onPressed: () => _setMode(!_registerMode),
                      child: Text(
                        _registerMode
                            ? 'Hesabınız var mı? Giriş Yapın'
                            : 'Hesabınız yok mu? Hemen Ücretsiz Kayıt Olun',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: AppRadius.cellR,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.cellR,
      borderSide: const BorderSide(color: AppColors.border),
    ),
  );
}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Şifremi Unuttum'),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofocus: true,
        onFieldSubmitted: (_) => _submit(),
        decoration: const InputDecoration(labelText: 'E-posta'),
        validator: (value) {
          final email = value?.trim() ?? '';
          if (email.isEmpty) return 'E-posta boş bırakılamaz';
          if (!email.contains('@')) return 'Geçerli bir e-posta girin';
          return null;
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Vazgeç'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Bağlantı Gönder')),
    ],
  );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: AppRadius.pillR,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.md,
            vertical: AppSpace.xs,
          ),
          child: Text('BKM Mutfak Etkinlik Ağı', style: AppTypography.micro),
        ),
      ),
      const SizedBox(height: AppSpace.cardPadding),
      ClipRRect(
        borderRadius: AppRadius.cardR,
        child: Image.asset(
          'assets/images/bkm-logo.png',
          width: 128,
          height: 64,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: AppSpace.cardPadding),
      Text('Biletfy’ye Hoş Geldiniz', style: AppTypography.titleL),
      const SizedBox(height: AppSpace.chipGap),
      Text(
        'Etkinliklerinizi, bilet satışlarınızı ve doluluk oranlarını tek yerden takip edin.',
        style: AppTypography.caption,
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.registerMode, required this.onChanged});
  final bool registerMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpace.xs),
    decoration: BoxDecoration(
      color: AppColors.surfaceAlt,
      borderRadius: AppRadius.cellR,
    ),
    child: Row(
      children: [
        Expanded(
          child: _ModeButton(
            label: 'Giriş Yap',
            selected: !registerMode,
            onTap: () => onChanged(false),
          ),
        ),
        Expanded(
          child: _ModeButton(
            label: 'Kayıt Ol',
            selected: registerMode,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    ),
  );
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.surface : Colors.transparent,
    borderRadius: AppRadius.pillR,
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillR,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.chipGap),
        child: Text(
          label,
          style: selected ? AppTypography.labelStrong : AppTypography.label,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppTypography.label);
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
        child: Text('VEYA ŞUNUNLA DEVAM ET', style: AppTypography.micro),
      ),
      const Expanded(child: Divider()),
    ],
  );
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onPressed, child: Text(label));
}
