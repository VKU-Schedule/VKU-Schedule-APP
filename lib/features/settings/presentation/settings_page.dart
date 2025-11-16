import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/bottom_nav.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/options/providers/chosen_option_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // Profile Section
          if (currentUser != null) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Thông tin sinh viên'),
              subtitle: Text(currentUser.email),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to profile page
              },
            ),
            const Divider(),
          ],
          // Defaults Section
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt mặc định'),
            subtitle: const Text('Trọng số, ngày nghỉ...'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to defaults settings
            },
          ),
          const Divider(),
          // Saved Schedules
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Lịch đã lưu'),
            subtitle: const Text('Xem và quản lý lịch đã lưu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/saved-schedules');
            },
          ),
          const Divider(),
          // Data Management
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Xóa dữ liệu'),
            subtitle: const Text('Xóa tất cả dữ liệu đã lưu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showClearDataDialog(context, ref);
            },
          ),
          const Divider(),
          // Logout
          if (currentUser != null) ...[
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                _showLogoutDialog(context, ref);
              },
            ),
            const Divider(),
          ],
          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Về ứng dụng'),
            subtitle: const Text('VKU Schedule v1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'VKU Schedule',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 VKU',
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/settings'),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dữ liệu'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả dữ liệu đã lưu? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear data
              ref.read(chosenOptionProvider.notifier).clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa dữ liệu'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
          TextButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
