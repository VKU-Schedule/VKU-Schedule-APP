import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/options/providers/chosen_option_provider.dart';

class SaveSyncPage extends ConsumerStatefulWidget {
  const SaveSyncPage({super.key});

  @override
  ConsumerState<SaveSyncPage> createState() => _SaveSyncPageState();
}

class _SaveSyncPageState extends ConsumerState<SaveSyncPage> {
  bool _isSaving = false;
  bool _isSyncing = false;

  Future<void> _handleSave() async {
    final chosenOption = ref.read(chosenOptionProvider);

    if (chosenOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một phương án trước'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // TODO: Implement actual save to local storage
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu phương án thành công'),
        ),
      );
    }
  }

  Future<void> _handleExportToGoogleCalendar() async {
    final chosenOption = ref.read(chosenOptionProvider);

    if (chosenOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một phương án trước'),
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    // TODO: Implement Google Calendar sync
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tính năng đang được phát triển'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chosenOption = ref.watch(chosenOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lưu & Đồng bộ'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (chosenOption != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phương án đã chọn',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('ID: ${chosenOption.id}'),
                        Text('Điểm: ${chosenOption.score.toStringAsFixed(2)}'),
                        Text(
                          'Số buổi học: ${chosenOption.sessions.length}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ] else ...[
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Chưa có phương án nào được chọn. Hãy chọn một phương án từ danh sách.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              ElevatedButton.icon(
                onPressed: chosenOption == null || _isSaving
                    ? null
                    : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Đang lưu...' : 'Lưu vào thiết bị'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: chosenOption == null || _isSyncing
                    ? null
                    : _handleExportToGoogleCalendar,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.calendar_today),
                label: Text(
                  _isSyncing
                      ? 'Đang xuất...'
                      : 'Xuất sang Google Calendar',
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Lưu ý',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '• Lưu vào thiết bị sẽ lưu phương án vào bộ nhớ local\n'
                '• Xuất sang Google Calendar yêu cầu đăng nhập Google và quyền truy cập Calendar\n'
                '• Bạn có thể xem lại lịch đã lưu trong phần Cài đặt',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
