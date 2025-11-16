import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../models/api_subject.dart';
import '../../../models/session.dart';

class AddSessionPage extends ConsumerStatefulWidget {
  final List<Session> currentSessions;

  const AddSessionPage({
    super.key,
    required this.currentSessions,
  });

  @override
  ConsumerState<AddSessionPage> createState() => _AddSessionPageState();
}

class _AddSessionPageState extends ConsumerState<AddSessionPage> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _searchQuery = '';
  ApiSubject? _selectedSubject;
  String? _errorMessage;

  // Form fields
  final _teacherController = TextEditingController();
  final _roomController = TextEditingController();
  final _areaController = TextEditingController();
  final _languageController = TextEditingController();
  final _fieldController = TextEditingController();
  String _selectedDay = 'Monday';
  final List<int> _selectedPeriods = [];
  int _classIndex = 1;
  int _classSize = 30;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _dayNames = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  final List<int> _allPeriods = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  @override
  void dispose() {
    _searchController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _areaController.dispose();
    _languageController.dispose();
    _fieldController.dispose();
    super.dispose();
  }

  Future<void> _searchSubjects() async {
    if (_searchQuery.isEmpty) {
      setState(() {
        _selectedSubject = null;
      });
      return;
    }

    try {
      final apiService = ref.read(apiServiceProvider);
      final subjects = await apiService.searchSubjects(_searchQuery);
      
      if (subjects.isNotEmpty && mounted) {
        setState(() {
          _selectedSubject = subjects.first;
          _errorMessage = null;
        });
      } else if (mounted) {
        setState(() {
          _selectedSubject = null;
          _errorMessage = 'Không tìm thấy môn học';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tìm kiếm: $e';
        });
      }
    }
  }

  void _togglePeriod(int period) {
    setState(() {
      if (_selectedPeriods.contains(period)) {
        _selectedPeriods.remove(period);
      } else {
        _selectedPeriods.add(period);
        _selectedPeriods.sort();
      }
    });
  }

  bool _hasConflict() {
    if (_selectedSubject == null || _selectedPeriods.isEmpty) return false;
    
    final testSession = Session(
      courseName: _selectedSubject!.courseName,
      teacher: _teacherController.text.isEmpty ? 'N/A' : _teacherController.text,
      day: _selectedDay,
      periods: List<int>.from(_selectedPeriods),
      room: _roomController.text.isEmpty ? 'N/A' : _roomController.text,
      area: _areaController.text.isEmpty ? 'N/A' : _areaController.text,
      classIndex: _classIndex,
      classSize: _classSize,
      language: _languageController.text.isEmpty ? 'N/A' : _languageController.text,
      field: _fieldController.text.isEmpty ? 'N/A' : _fieldController.text,
      subTopic: _selectedSubject!.subTopic,
    );

    return widget.currentSessions.any((s) => testSession.overlapsWith(s));
  }

  void _addSession() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn môn học')),
      );
      return;
    }
    if (_selectedPeriods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một tiết học')),
      );
      return;
    }

    final session = Session(
      courseName: _selectedSubject!.courseName,
      teacher: _teacherController.text.isEmpty ? 'N/A' : _teacherController.text,
      day: _selectedDay,
      periods: List<int>.from(_selectedPeriods),
      room: _roomController.text.isEmpty ? 'N/A' : _roomController.text,
      area: _areaController.text.isEmpty ? 'N/A' : _areaController.text,
      classIndex: _classIndex,
      classSize: _classSize,
      language: _languageController.text.isEmpty ? 'N/A' : _languageController.text,
      field: _fieldController.text.isEmpty ? 'N/A' : _fieldController.text,
      subTopic: _selectedSubject!.subTopic,
    );

    Navigator.pop(context, session);
  }

  @override
  Widget build(BuildContext context) {
    final hasConflict = _hasConflict();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm môn học'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm môn học',
                hintText: 'Nhập tên môn học...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedSubject = null;
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchQuery == value && mounted) {
                    _searchSubjects();
                  }
                });
              },
            ),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),

            // Selected subject info
            if (_selectedSubject != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.book, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedSubject!.courseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (_selectedSubject!.subTopic.isNotEmpty)
                            Text(
                              _selectedSubject!.subTopic,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Form fields
            if (_selectedSubject != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Thông tin lớp học',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Day selection
              DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Thứ',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(_days.length, (index) {
                  return DropdownMenuItem(
                    value: _days[index],
                    child: Text(_dayNames[index]),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDay = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Periods selection
              const Text('Tiết học:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allPeriods.map((period) {
                  final isSelected = _selectedPeriods.contains(period);
                  return FilterChip(
                    label: Text('Tiết $period'),
                    selected: isSelected,
                    onSelected: (_) => _togglePeriod(period),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Teacher
              TextFormField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: 'Giảng viên',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Room
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Phòng học',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Area
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Khu vực',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Class index and size
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _classIndex.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Số lớp',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _classIndex = int.tryParse(value) ?? 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _classSize.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Số lượng SV',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _classSize = int.tryParse(value) ?? 30;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Language
              TextFormField(
                controller: _languageController,
                decoration: const InputDecoration(
                  labelText: 'Ngôn ngữ',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Field
              TextFormField(
                controller: _fieldController,
                decoration: const InputDecoration(
                  labelText: 'Lĩnh vực',
                  border: OutlineInputBorder(),
                ),
              ),

              // Conflict warning
              if (hasConflict) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cảnh báo: Lớp học này xung đột với lịch hiện có',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addSession,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Thêm vào lịch'),
                ),
              ),
            ] else ...[
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nhập từ khóa để tìm kiếm môn học',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
