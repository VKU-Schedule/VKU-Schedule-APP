import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../models/schedule_option.dart';
import '../models/session.dart';
import '../core/theme/app_theme.dart';

class TimetableExportService {
  /// Capture timetable as image
  Future<Uint8List?> captureAsImage(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  /// Generate shareable text for timetable
  String generateShareText(ScheduleOption schedule) {
    final buffer = StringBuffer();
    buffer.writeln('📅 Lịch học VKU');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();

    // Group sessions by day
    final sessionsByDay = <int, List<Session>>{};
    for (final session in schedule.sessions) {
      sessionsByDay.putIfAbsent(session.dayIndex, () => []).add(session);
    }

    // Sort days
    final sortedDays = sessionsByDay.keys.toList()..sort();

    for (final dayIndex in sortedDays) {
      final sessions = sessionsByDay[dayIndex]!;
      final dayName = _getDayName(dayIndex);

      buffer.writeln('📌 $dayName');
      buffer.writeln();

      // Sort sessions by start period
      sessions.sort((a, b) => a.startPeriod.compareTo(b.startPeriod));

      for (final session in sessions) {
        buffer.writeln('  • ${session.courseName}');
        buffer.writeln('    ⏰ ${session.periodRange}');
        buffer.writeln('    📍 ${session.room}');
        buffer.writeln('    👨‍🏫 ${session.teacher}');
        buffer.writeln();
      }

      buffer.writeln();
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Tạo bởi VKU Schedule App');

    return buffer.toString();
  }

  /// Generate PDF-friendly HTML
  String generatePdfHtml(ScheduleOption schedule) {
    final buffer = StringBuffer();

    buffer.writeln('''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Lịch học VKU</title>
  <style>
    @page {
      size: A4;
      margin: 20mm;
    }
    
    body {
      font-family: 'Roboto', 'Arial', sans-serif;
      margin: 0;
      padding: 20px;
      color: #212121;
    }
    
    .header {
      text-align: center;
      margin-bottom: 30px;
      border-bottom: 3px solid #E31E24;
      padding-bottom: 15px;
    }
    
    .header h1 {
      color: #E31E24;
      margin: 0;
      font-size: 28px;
    }
    
    .header p {
      color: #616161;
      margin: 5px 0 0 0;
    }
    
    .timetable {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
    }
    
    .timetable th {
      background: linear-gradient(135deg, #2B3990, #E31E24);
      color: white;
      padding: 12px 8px;
      text-align: center;
      font-weight: 600;
      font-size: 12px;
    }
    
    .timetable td {
      border: 1px solid #E0E0E0;
      padding: 8px;
      vertical-align: top;
      font-size: 10px;
      min-height: 60px;
    }
    
    .session {
      background: linear-gradient(135deg, #FCE4E5, #F9BCBE);
      border-left: 3px solid #E31E24;
      padding: 6px;
      margin-bottom: 4px;
      border-radius: 4px;
    }
    
    .session-name {
      font-weight: 600;
      color: #E31E24;
      margin-bottom: 3px;
    }
    
    .session-detail {
      color: #616161;
      font-size: 9px;
      margin: 2px 0;
    }
    
    .footer {
      margin-top: 30px;
      text-align: center;
      color: #757575;
      font-size: 10px;
      border-top: 1px solid #E0E0E0;
      padding-top: 15px;
    }
    
    @media print {
      body {
        padding: 0;
      }
      
      .no-print {
        display: none;
      }
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>📅 LỊCH HỌC VKU</h1>
    <p>Vietnam-Korea University of Information and Communication Technology</p>
  </div>
  
  <table class="timetable">
    <thead>
      <tr>
        <th style="width: 80px;">Tiết</th>
        <th>Thứ 2</th>
        <th>Thứ 3</th>
        <th>Thứ 4</th>
        <th>Thứ 5</th>
        <th>Thứ 6</th>
        <th>Thứ 7</th>
        <th>CN</th>
      </tr>
    </thead>
    <tbody>
''');

    // Build timetable grid
    final sessionsByDayAndPeriod = <String, Session>{};
    for (final session in schedule.sessions) {
      for (final period in session.periods) {
        final key = '${session.dayIndex}_$period';
        sessionsByDayAndPeriod[key] = session;
      }
    }

    for (int period = 1; period <= 12; period++) {
      buffer.writeln('      <tr>');
      buffer.writeln('        <td style="text-align: center; font-weight: 600;">');
      buffer.writeln('          Tiết $period<br>');
      buffer.writeln('          <span style="font-size: 9px; color: #757575;">${_getHourForPeriod(period)}</span>');
      buffer.writeln('        </td>');

      for (int day = 0; day < 7; day++) {
        final key = '${day}_$period';
        final session = sessionsByDayAndPeriod[key];

        if (session != null && session.startPeriod == period) {
          final rowspan = session.periods.length;
          buffer.writeln('        <td rowspan="$rowspan">');
          buffer.writeln('          <div class="session">');
          buffer.writeln('            <div class="session-name">${session.courseName}</div>');
          buffer.writeln('            <div class="session-detail">📍 ${session.room}</div>');
          buffer.writeln('            <div class="session-detail">👨‍🏫 ${session.teacher}</div>');
          buffer.writeln('            <div class="session-detail">👥 ${session.group}</div>');
          buffer.writeln('          </div>');
          buffer.writeln('        </td>');
        } else if (session == null) {
          buffer.writeln('        <td></td>');
        }
      }

      buffer.writeln('      </tr>');
    }

    buffer.writeln('''
    </tbody>
  </table>
  
  <div class="footer">
    <p>Tạo bởi VKU Schedule App | © 2024 VKU</p>
  </div>
</body>
</html>
''');

    return buffer.toString();
  }

  /// Generate print-friendly view
  Widget buildPrintableView(ScheduleOption schedule) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.gradientNavyToRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '📅 LỊCH HỌC VKU',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vietnam-Korea University',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Timetable grid would go here
          // (This is a simplified version for demonstration)
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, dayIndex) {
                final daySessions = schedule.sessions
                    .where((s) => s.dayIndex == dayIndex)
                    .toList()
                  ..sort((a, b) => a.startPeriod.compareTo(b.startPeriod));

                if (daySessions.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayName(dayIndex),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.vkuRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...daySessions.map((session) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.vkuRed50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.vkuRed,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.courseName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.vkuRed,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '⏰ ${session.periodRange}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '📍 ${session.room}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '👨‍🏫 ${session.teacher}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          // Footer
          const Divider(),
          const Center(
            child: Text(
              'Tạo bởi VKU Schedule App',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayIndex) {
    const dayNames = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật'
    ];
    return dayNames[dayIndex];
  }

  String _getHourForPeriod(int period) {
    if (period <= 5) {
      final hour = 6 + period;
      return '${hour}h30';
    } else {
      final hour = 7 + period;
      return '${hour}h';
    }
  }
}
