import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../../../core/di/providers.dart';
import '../../../core/widgets/app_bar.dart';

class HiveDebugPage extends ConsumerWidget {
  const HiveDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localStorage = ref.watch(localStorageServiceProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const VKUAppBar(
        title: 'Hive Database Debug',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Storage Status
          _buildSection(
            context,
            'Storage Status',
            Icons.storage,
            [
              _buildInfoTile(
                'Initialized',
                localStorage.isInitialized ? 'Yes ✓' : 'No ✗',
                localStorage.isInitialized ? Colors.green : Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Saved Schedules
          _buildSection(
            context,
            'Saved Schedules',
            Icons.bookmark,
            [
              _buildDataBox(
                context,
                'Saved Schedules',
                () {
                  final schedules = localStorage.getSavedSchedules();
                  return {
                    'count': schedules.length,
                    'data': schedules.map((s) => {
                      'id': s.id,
                      'savedAt': s.savedAt.toString(),
                      'isActive': s.isActive,
                      'sessionId': s.sessionId,
                      'scheduleJson': s.scheduleJson.substring(0, 100) + '...',
                    }).toList(),
                  };
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User Profile
          _buildSection(
            context,
            'User Profile',
            Icons.person,
            [
              _buildDataBox(
                context,
                'User Profile',
                () {
                  final profile = localStorage.getUserProfile();
                  if (profile == null) return {'status': 'No user profile'};
                  return {
                    'studentId': profile.studentId,
                    'fullName': profile.fullName,
                    'email': profile.email,
                    'major': profile.major,
                  };
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // App Settings
          _buildSection(
            context,
            'App Settings',
            Icons.settings,
            [
              _buildDataBox(
                context,
                'Settings',
                () {
                  final settings = localStorage.getSettings();
                  return {
                    'hasCompletedOnboarding': settings.hasCompletedOnboarding,
                    'themeMode': settings.themeMode,
                    'notificationsEnabled': settings.notificationsEnabled,
                  };
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Optimization History
          _buildSection(
            context,
            'Optimization History',
            Icons.history,
            [
              _buildDataBox(
                context,
                'History',
                () {
                  final history = localStorage.getOptimizationHistory();
                  return {
                    'count': history.length,
                    'data': history.map((h) => {
                      'id': h.id,
                      'createdAt': h.createdAt.toString(),
                      'optionsCount': h.scheduleOptionIds.length,
                    }).toList(),
                  };
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actions
          _buildSection(
            context,
            'Actions',
            Icons.build,
            [
              ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All Data'),
                      content: const Text(
                        'Are you sure you want to delete all data? This cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete All'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    await localStorage.clearAllData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All data cleared'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text('Clear All Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataBox(
    BuildContext context,
    String title,
    Map<String, dynamic> Function() getData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                try {
                  final data = getData();
                  final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
                  Clipboard.setData(ClipboardData(text: jsonStr));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              tooltip: 'Copy JSON',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              () {
                try {
                  final data = getData();
                  return const JsonEncoder.withIndent('  ').convert(data);
                } catch (e) {
                  return 'Error: $e';
                }
              }(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
