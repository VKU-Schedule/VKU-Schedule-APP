import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../providers/preferences_provider.dart';

class PreferenceInputPage extends ConsumerStatefulWidget {
  const PreferenceInputPage({super.key});

  @override
  ConsumerState<PreferenceInputPage> createState() =>
      _PreferenceInputPageState();
}

class _PreferenceInputPageState extends ConsumerState<PreferenceInputPage> {
  final _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Save raw prompt text to provider - will be sent directly to API
    final promptText = _textController.text.trim();
    
    if (promptText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập sở thích của bạn'),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    // Save prompt text to provider
    ref.read(preferencesProvider.notifier).updatePromptText(promptText);

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu sở thích'),
        ),
      );

      context.go('/weights');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập sở thích'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mô tả sở thích của bạn',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Nhập bằng tiếng Việt tự nhiên, ví dụ: "tôi thích học buổi sáng, không học thứ sáu"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText:
                        'Ví dụ: Tôi thích học buổi sáng, không học thứ sáu, tránh các giảng viên Nguyễn Văn A...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Phân tích và tiếp tục'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


