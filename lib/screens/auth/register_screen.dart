import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedKpssType = 'Lisans';
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      showErrorSnackBar(context, 'Kullanım koşullarını kabul etmelisiniz');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      kpssType: _selectedKpssType,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      showErrorSnackBar(context, authProvider.errorMessage ?? 'Kayıt başarısız');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
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
                          height: 400,
                          child: LoadingIndicator(message: 'Kayıt yapılıyor...'),
                        );
                      }

                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Hesap Oluştur',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            CustomTextField(
                              controller: _emailController,
                              labelText: 'E-posta',
                              prefixIcon: const Icon(Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'E-posta gerekli';
                                if (!value.contains('@')) return 'Geçerli e-posta girin';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: _usernameController,
                              labelText: 'Kullanıcı Adı',
                              prefixIcon: const Icon(Icons.person_outlined),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Kullanıcı adı gerekli';
                                if (value.length < 3) return 'En az 3 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _firstNameController,
                                    labelText: 'Ad',
                                    validator: (value) => value?.isEmpty ?? true ? 'Ad gerekli' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _lastNameController,
                                    labelText: 'Soyad',
                                    validator: (value) => value?.isEmpty ?? true ? 'Soyad gerekli' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              value: _selectedKpssType,
                              decoration: InputDecoration(
                                labelText: 'KPSS Türü',
                                prefixIcon: const Icon(Icons.school),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: AppConstants.kpssExamTypes
                                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                  .toList(),
                              onChanged: (value) => setState(() => _selectedKpssType = value!),
                            ),
                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: _passwordController,
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              obscureText: true,
                              showPasswordToggle: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Şifre gerekli';
                                if (value.length < 6) return 'En az 6 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: _confirmPasswordController,
                              labelText: 'Şifre Tekrar',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              obscureText: true,
                              showPasswordToggle: true,
                              validator: (value) {
                                if (value != _passwordController.text) return 'Şifreler eşleşmiyor';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                                  activeColor: AppTheme.primaryColor,
                                ),
                                Expanded(
                                  child: Text(
                                    'Kullanım koşullarını kabul ediyorum',
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            GradientButton(
                              text: 'Kayıt Ol',
                              onPressed: _handleRegister,
                              height: 52,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Zaten hesabınız var mı?'),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Giriş Yap'),
                                ),
                              ],
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
