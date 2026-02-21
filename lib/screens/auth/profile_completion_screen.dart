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

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedKpssType = 'Lisans';

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.completeProfile(
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
      showErrorSnackBar(context, authProvider.errorMessage ?? 'İşlem başarısız');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          child: LoadingIndicator(message: 'Profil tamamlanıyor...'),
                        );
                      }

                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Profilinizi Tamamlayın',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Devam etmek için birkaç bilgi daha gerekiyor',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

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

                            CustomTextField(
                              controller: _firstNameController,
                              labelText: 'Ad',
                              validator: (value) => value?.isEmpty ?? true ? 'Ad gerekli' : null,
                            ),
                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: _lastNameController,
                              labelText: 'Soyad',
                              validator: (value) => value?.isEmpty ?? true ? 'Soyad gerekli' : null,
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
                            const SizedBox(height: 32),

                            GradientButton(
                              text: 'Tamamla',
                              onPressed: _handleComplete,
                              height: 52,
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
