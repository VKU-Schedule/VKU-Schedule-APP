import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/subject_card.dart';
import '../../../models/subject.dart';
import '../providers/subject_selection_provider.dart';

class SubjectSelectionPage extends ConsumerStatefulWidget {
  const SubjectSelectionPage({super.key});

  @override
  ConsumerState<SubjectSelectionPage> createState() =>
      _SubjectSelectionPageState();
}

class _SubjectSelectionPageState extends ConsumerState<SubjectSelectionPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use search provider with current query
    final subjectsAsync = _searchQuery.isEmpty
        ? const AsyncValue<List<Subject>>.data([])
        : ref.watch(subjectSearchProvider(_searchQuery));
    final selection = ref.watch(subjectSelectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn môn học'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm môn học',
                hintText: 'Nhập tên môn học hoặc mã môn...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: subjectsAsync.when(
              data: (subjects) {
                if (_searchQuery.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nhập từ khóa để tìm kiếm môn học',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (subjects.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Không tìm thấy môn học nào',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final isEnrolled = selection.enrolledSubjects
                        .contains(subject.id);
                    final isSkipped = selection.skippedSubjects
                        .contains(subject.id);

                    return SubjectCard(
                      subject: subject,
                      index: index + 1,
                      isEnrolled: isEnrolled,
                      isSkipped: isSkipped,
                      onEnroll: () {
                        ref
                            .read(subjectSelectionProvider.notifier)
                            .toggleEnroll(subject.id, subject: subject);
                      },
                      onSkip: () {
                        ref
                            .read(subjectSelectionProvider.notifier)
                            .toggleSkip(subject.id, subject: subject);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Lỗi: $error'),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final enrolledCount = selection.enrolledSubjects.length;
                    if (enrolledCount == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng chọn ít nhất một môn học',
                          ),
                        ),
                      );
                      return;
                    }
                    context.go('/preferences');
                  },
                  child: Text(
                    'Tiếp theo - Nhập sở thích (${selection.enrolledSubjects.length} môn)',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


