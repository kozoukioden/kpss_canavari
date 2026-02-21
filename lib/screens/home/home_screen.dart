import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/avatar_widget.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.firebaseUser != null) {
      context.read<UserProvider>().loadUser(authProvider.firebaseUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KPSS Canavari'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.userModel;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: AvatarWidget(
                  imageUrl: user?.photoUrl,
                  name: user?.username ?? 'User',
                  size: 40,
                  onTap: () {
                    // Navigate to profile screen
                  },
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.userModel;
                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                  currentAccountPicture: AvatarWidget(
                    imageUrl: user?.photoUrl,
                    name: user?.username ?? 'User',
                    size: 64,
                  ),
                  accountName: Text(user?.username ?? 'Kullanıcı'),
                  accountEmail: Text(user?.email ?? ''),
                );
              },
            ),
            _buildMenuItem(Icons.home, 'Ana Sayfa', 0),
            _buildMenuItem(Icons.quiz, 'Soru Çözücü', 1),
            _buildMenuItem(Icons.assignment, 'Testler', 2),
            _buildMenuItem(Icons.school, 'Konu Anlatımı', 3),
            _buildMenuItem(Icons.psychology, 'Koçluk Sistemi', 4),
            _buildMenuItem(Icons.location_city, 'Tercih Robotu', 5),
            _buildMenuItem(Icons.calendar_today, 'Haftalık Sınavlar', 6),
            _buildMenuItem(Icons.mic, 'Podcast', 7),
            _buildMenuItem(Icons.archive, 'Soru Arşivi', 8),
            _buildMenuItem(Icons.forum, 'Topluluk', 9),
            const Divider(),
            _buildMenuItem(Icons.person, 'Profil', 10),
            _buildMenuItem(Icons.settings, 'Ayarlar', 11),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Çıkış Yap'),
              onTap: () async {
                await context.read<AuthProvider>().signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade800,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      tileColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildBody() {
    return Consumer2<AuthProvider, UserProvider>(
      builder: (context, authProvider, userProvider, _) {
        final user = userProvider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Merhaba, ${user?.firstName ?? "Kullanıcı"}!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'KPSS yolculuğunda bugün ne yapmak istersin?',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Statistics cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    title: 'Çözülen Sorular',
                    value: '${user?.totalQuestionsSolved ?? 0}',
                    icon: Icons.quiz,
                  ),
                  StatCard(
                    title: 'Doğru Oranı',
                    value: '${user?.accuracy.toStringAsFixed(1) ?? 0}%',
                    icon: Icons.check_circle,
                    gradient: AppTheme.successGradient,
                  ),
                  StatCard(
                    title: 'Çalışma Serisi',
                    value: '${user?.studyStreak ?? 0} gün',
                    icon: Icons.local_fire_department,
                    gradient: AppTheme.warningGradient,
                  ),
                  StatCard(
                    title: 'Zayıf Konular',
                    value: '${userProvider.weakTopics.length}',
                    icon: Icons.trending_down,
                    gradient: AppTheme.errorGradient,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick actions
              const Text(
                'Hızlı Erişim',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildQuickActionCard(
                'Soru Çöz',
                'Kamera veya galeriden soru yükle',
                Icons.camera_alt,
                AppTheme.primaryGradient,
                () {
                  setState(() => _selectedIndex = 1);
                },
              ),
              const SizedBox(height: 12),

              _buildQuickActionCard(
                'Test Oluştur',
                'Yapay zeka ile test oluştur',
                Icons.assignment,
                AppTheme.successGradient,
                () {
                  setState(() => _selectedIndex = 2);
                },
              ),
              const SizedBox(height: 12),

              _buildQuickActionCard(
                'Konu Çalış',
                'İstediğin konuyu öğren',
                Icons.school,
                AppTheme.warningGradient,
                () {
                  setState(() => _selectedIndex = 3);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
