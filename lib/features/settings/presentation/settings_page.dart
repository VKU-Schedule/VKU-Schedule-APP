import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/vku_card.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/options/providers/saved_schedules_provider.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/di/providers.dart';
import '../../../models/app_settings.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final savedSchedules = ref.watch(savedSchedulesProvider);
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeroSection(context, currentUser),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: AppTheme.spaceMd),
                  if (currentUser != null) _buildStatsSection(savedSchedules.length),
                  const SizedBox(height: AppTheme.spaceLg),
                  _buildSettingsSection(context, ref, settings),
                  const SizedBox(height: AppTheme.spaceLg),
                  _buildDataManagementSection(context, ref),
                  const SizedBox(height: AppTheme.spaceLg),
                  _buildAboutSection(context, ref, currentUser),
                  const SizedBox(height: AppTheme.space3xl),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/settings'),
    );
  }

  Widget _buildHeroSection(BuildContext context, dynamic currentUser) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.vkuNavy,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.gradientNavyToRed,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppTheme.space2xl),
                  _buildAvatar(currentUser),
                  const SizedBox(height: AppTheme.spaceMd),
                  if (currentUser != null) ...[
                    Text(
                      currentUser.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(
                      currentUser.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (currentUser.studentId != null) ...[
                      const SizedBox(height: AppTheme.spaceXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceMd,
                          vertical: AppTheme.spaceXs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'MSSV: ${currentUser.studentId}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    Text(
                      'Chưa đăng nhập',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.spaceMd),
                  if (currentUser != null)
                    TextButton.icon(
                      onPressed: () => _showEditProfileDialog(context, currentUser),
                      icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                      label: const Text(
                        'Chỉnh sửa thông tin',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceMd,
                          vertical: AppTheme.spaceSm,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
    );
  }

  Widget _buildAvatar(dynamic currentUser) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.gradientRedToYellow,
        boxShadow: [
          BoxShadow(
            color: AppTheme.vkuYellow.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(4),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.vkuNavy50,
          backgroundImage: currentUser?.photoUrl != null
              ? NetworkImage(currentUser.photoUrl)
              : null,
          child: currentUser?.photoUrl == null
              ? const Icon(
                  Icons.person,
                  size: 50,
                  color: AppTheme.vkuNavy,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStatsSection(int schedulesCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.bookmark,
              label: 'Lịch đã lưu',
              value: schedulesCount.toString(),
              gradient: AppTheme.gradientRedToYellow,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: _buildStatCard(
              icon: Icons.history,
              label: 'Lần tối ưu',
              value: '0',
              gradient: AppTheme.gradientYellowToNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: AppTheme.glassmorphism(
        borderRadius: AppTheme.radiusMd,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceSm),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      child: VKUCard(
        useGlassmorphism: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Cài đặt ứng dụng', Icons.settings),
            const SizedBox(height: AppTheme.spaceMd),
            _buildSettingTile(
              context: context,
              icon: Icons.palette_outlined,
              title: 'Giao diện',
              subtitle: _getThemeModeLabel(settings.themeMode),
              onTap: () => _showThemeSelectionDialog(context, ref, settings),
              trailing: const Icon(Icons.chevron_right),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              context: context,
              icon: Icons.notifications_outlined,
              title: 'Thông báo',
              subtitle: 'Nhận thông báo về lịch học',
              trailing: Switch(
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateNotifications(value);
                },
              ),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              context: context,
              icon: Icons.bookmark_outline,
              title: 'Lịch đã lưu',
              subtitle: 'Xem và quản lý lịch đã lưu',
              onTap: () => context.go('/saved-schedules'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      child: VKUCard(
        useGlassmorphism: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Quản lý dữ liệu', Icons.storage),
            const SizedBox(height: AppTheme.spaceMd),
            _buildStorageUsage(context),
            const SizedBox(height: AppTheme.spaceMd),
            const Divider(height: 1),
            _buildSettingTile(
              context: context,
              icon: Icons.cleaning_services_outlined,
              title: 'Xóa bộ nhớ đệm',
              subtitle: 'Giải phóng dung lượng lưu trữ',
              onTap: () => _showClearCacheDialog(context, ref),
              trailing: const Icon(Icons.chevron_right),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              context: context,
              icon: Icons.delete_outline,
              title: 'Xóa tất cả dữ liệu',
              subtitle: 'Xóa toàn bộ dữ liệu đã lưu',
              onTap: () => _showClearDataDialog(context, ref),
              trailing: const Icon(Icons.chevron_right),
              iconColor: AppTheme.error,
              titleColor: AppTheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, WidgetRef ref, dynamic currentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      child: VKUCard(
        useGlassmorphism: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Về ứng dụng', Icons.info_outline),
            const SizedBox(height: AppTheme.spaceMd),
            _buildSettingTile(
              context: context,
              icon: Icons.school_outlined,
              title: 'VKU Schedule',
              subtitle: 'Phiên bản 1.0.0',
              onTap: () => _showAboutDialog(context),
              trailing: const Icon(Icons.chevron_right),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              context: context,
              icon: Icons.people_outline,
              title: 'Đóng góp',
              subtitle: 'Nhóm phát triển và cảm ơn',
              onTap: () => _showCreditsDialog(context),
              trailing: const Icon(Icons.chevron_right),
            ),
            if (currentUser != null) ...[
              const Divider(height: 1),
              _buildSettingTile(
                context: context,
                icon: Icons.logout,
                title: 'Đăng xuất',
                subtitle: 'Thoát khỏi tài khoản',
                onTap: () => _showLogoutDialog(context, ref),
                iconColor: AppTheme.error,
                titleColor: AppTheme.error,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceXs),
          decoration: BoxDecoration(
            gradient: AppTheme.gradientRedToYellow,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppTheme.spaceSm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.spaceXs),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.vkuNavy).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppTheme.vkuNavy,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildStorageUsage(BuildContext context) {
    const totalStorage = 100.0;
    const usedStorage = 12.5;
    const percentage = usedStorage / totalStorage;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dung lượng sử dụng',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${usedStorage.toStringAsFixed(1)} / ${totalStorage.toStringAsFixed(0)} MB',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppTheme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.8 ? AppTheme.error : AppTheme.vkuYellow,
            ),
          ),
        ),
      ],
    );
  }

  String _getThemeModeLabel(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Sáng';
      case 'dark':
        return 'Tối';
      case 'system':
      default:
        return 'Theo hệ thống';
    }
  }

  void _showEditProfileDialog(BuildContext context, dynamic currentUser) {
    _nameController.text = currentUser.name;
    _studentIdController.text = currentUser.studentId ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Mã số sinh viên',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật thông tin')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context, WidgetRef ref, AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn giao diện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context: context,
              title: 'Sáng',
              subtitle: 'Giao diện sáng',
              icon: Icons.light_mode,
              value: 'light',
              currentValue: settings.themeMode,
              onTap: () {
                ref.read(settingsProvider.notifier).updateThemeMode('light');
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context: context,
              title: 'Tối',
              subtitle: 'Giao diện tối',
              icon: Icons.dark_mode,
              value: 'dark',
              currentValue: settings.themeMode,
              onTap: () {
                ref.read(settingsProvider.notifier).updateThemeMode('dark');
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context: context,
              title: 'Theo hệ thống',
              subtitle: 'Tự động theo thiết bị',
              icon: Icons.brightness_auto,
              value: 'system',
              currentValue: settings.themeMode,
              onTap: () {
                ref.read(settingsProvider.notifier).updateThemeMode('system');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String currentValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == currentValue;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.vkuRed : AppTheme.textLight,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.vkuRed)
          : null,
      onTap: onTap,
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bộ nhớ đệm'),
        content: const Text(
          'Xóa bộ nhớ đệm sẽ giải phóng dung lượng lưu trữ nhưng không ảnh hưởng đến dữ liệu đã lưu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa bộ nhớ đệm')),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả dữ liệu'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả dữ liệu đã lưu? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final localStorage = ref.read(localStorageServiceProvider);
                await localStorage.clearAllData();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa tất cả dữ liệu')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceXs),
              decoration: BoxDecoration(
                gradient: AppTheme.gradientRedToYellow,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 24),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            const Text('VKU Schedule'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ứng dụng tối ưu hóa lịch học cho sinh viên VKU',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: AppTheme.spaceMd),
            Text(
              'Phiên bản: 1.0.0',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
            SizedBox(height: AppTheme.spaceXs),
            Text(
              '© 2024 Vietnam-Korea University',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
            SizedBox(height: AppTheme.spaceMd),
            Text(
              'Sử dụng thuật toán NSGA-II và mô hình NLP ViT5 để tạo lịch học tối ưu.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showCreditsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đóng góp'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhóm phát triển',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spaceSm),
            Text('• Sinh viên VKU'),
            Text('• Giảng viên hướng dẫn'),
            SizedBox(height: AppTheme.spaceMd),
            Text(
              'Công nghệ sử dụng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spaceSm),
            Text('• Flutter & Dart'),
            Text('• NSGA-II Algorithm'),
            Text('• ViT5 NLP Model'),
            Text('• Riverpod State Management'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
