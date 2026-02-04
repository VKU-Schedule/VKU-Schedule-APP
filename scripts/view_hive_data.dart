// Quick script để xem Hive data
// Chạy: dart run scripts/view_hive_data.dart

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 VKU Schedule - Hive Data Viewer\n');
  
  // Hướng dẫn lấy data
  print('📋 Hướng dẫn:');
  print('1. Kết nối thiết bị Android');
  print('2. Chạy lệnh: adb pull /data/data/com.vku.schedule/app_flutter/ ./hive_data/');
  print('3. Files sẽ được lưu vào folder ./hive_data/\n');
  
  // Check if hive_data folder exists
  final hiveDir = Directory('./hive_data');
  if (!await hiveDir.exists()) {
    print('❌ Folder ./hive_data/ không tồn tại');
    print('   Chạy lệnh ADB để pull data trước\n');
    return;
  }
  
  print('✅ Tìm thấy folder ./hive_data/\n');
  
  // List all files
  print('📁 Files trong Hive:');
  await for (final entity in hiveDir.list()) {
    if (entity is File) {
      final stat = await entity.stat();
      final size = (stat.size / 1024).toStringAsFixed(2);
      print('   ${entity.path.split('/').last} - ${size}KB');
    }
  }
  
  print('\n⚠️  Lưu ý: Files Hive là binary format');
  print('   Cần dùng Hive Browser hoặc Debug Screen trong app để xem nội dung\n');
  
  print('💡 Các cách xem data:');
  print('   1. Debug Screen trong app (khuyên dùng)');
  print('   2. Hive Browser: flutter pub global activate hive_browser');
  print('   3. Xem file HOW_TO_VIEW_HIVE_DATA.md\n');
}
