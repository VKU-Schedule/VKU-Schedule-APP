import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vku_schedule/core/widgets/app_bar.dart';

class SemesterSelectionPage extends ConsumerStatefulWidget {
  const SemesterSelectionPage({super.key});

  @override
  ConsumerState<SemesterSelectionPage> createState() =>
      _SemesterSelectionPageState();
}

class _SemesterSelectionPageState
    extends ConsumerState<SemesterSelectionPage> {
  String? _selectedYear;
  String? _selectedSemester;
  bool _isLoading = false;

  final List<String> _years = [
    '2024-2025',
    '2023-2024',
    '2022-2023',
  ];

  final List<String> _semesters = [
    'Học kỳ 1',
    'Học kỳ 2',
    'Học kỳ hè',
  ];

  Future<void> _handleSync() async {
    if (_selectedYear == null || _selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn năm học và học kỳ'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement actual sync
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đồng bộ thành công'),
        ),
      );

      context.go('/subjects');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VKUAppBar(
        title: 'Chọn học kỳ',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Chọn năm học và học kỳ',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Năm học',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: _years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: const InputDecoration(
                  labelText: 'Học kỳ',
                  prefixIcon: Icon(Icons.school),
                ),
                items: _semesters.map((semester) {
                  return DropdownMenuItem(
                    value: semester,
                    child: Text(semester),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSemester = value;
                  });
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSync,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(_isLoading ? 'Đang đồng bộ...' : 'Đồng bộ môn học'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}


