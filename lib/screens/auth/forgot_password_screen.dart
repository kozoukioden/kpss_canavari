import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    } else {
      showErrorSnackBar(context, authProvider.errorMessage ?? 'İşlem başarısız');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Sıfırlama'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.isLoading) {
                        return const SizedBox(
                          width: 300,
                          height: 300,
                          child: LoadingIndicator(message: 'E-posta gönderiliyor...'),
                        );
                      }

                      if (_emailSent) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mark_email_read, size: 80, color: Colors.green.shade400),
                            const SizedBox(height: 24),
                            const Text(
                              'E-posta Gönderildi!',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen e-postanızı kontrol edin.',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            GradientButton(
                              text: 'Giriş Ekranına Dön',
                              onPressed: () => Navigator.of(context).pop(),
                              height: 52,
                            ),
                          ],
                        );
                      }

                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(Icons.lock_reset, size: 64, color: AppTheme.primaryColor),
                            const SizedBox(height: 24),
                            const Text(
                              'Şifrenizi mi Unuttunuz?',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            CustomTextField(
                              controller: _emailController,
                              labelText: 'E-posta',
                              hintText: 'ornek@email.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'E-posta gerekli';
                                if (!value.contains('@')) return 'Geçerli e-posta girin';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            GradientButton(
                              text: 'Sıfırlama Bağlantısı Gönder',
                              onPressed: _handleResetPassword,
                              height: 52,
                            ),
                            const SizedBox(height: 16),

                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Giriş ekranına dön'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
