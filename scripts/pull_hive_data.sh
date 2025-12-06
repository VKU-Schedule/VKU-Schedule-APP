#!/bin/bash

# Script để pull Hive data từ Android device
# Sử dụng: ./scripts/pull_hive_data.sh

echo "🔍 VKU Schedule - Pull Hive Data"
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ ADB không được cài đặt"
    echo "   Cài đặt Android SDK Platform Tools"
    exit 1
fi

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "❌ Không tìm thấy thiết bị Android"
    echo "   Kết nối thiết bị và bật USB Debugging"
    exit 1
fi

echo "✅ Tìm thấy thiết bị Android"
echo ""

# Package name
PACKAGE="com.vku.schedule"
HIVE_PATH="/data/data/$PACKAGE/app_flutter"
OUTPUT_DIR="./hive_data"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "📥 Đang pull Hive data..."
echo "   From: $HIVE_PATH"
echo "   To: $OUTPUT_DIR"
echo ""

# Pull all files
if adb pull "$HIVE_PATH" "$OUTPUT_DIR"; then
    echo ""
    echo "✅ Pull thành công!"
    echo ""
    
    # List files
    echo "📁 Files đã pull:"
    ls -lh "$OUTPUT_DIR/app_flutter/" 2>/dev/null || ls -lh "$OUTPUT_DIR/"
    echo ""
    
    # Count files
    FILE_COUNT=$(find "$OUTPUT_DIR" -type f -name "*.hive" | wc -l)
    echo "📊 Tổng số files .hive: $FILE_COUNT"
    echo ""
    
    echo "💡 Để xem nội dung:"
    echo "   1. Dùng Debug Screen trong app (khuyên dùng)"
    echo "   2. Dùng Hive Browser:"
    echo "      flutter pub global activate hive_browser"
    echo "      hive_browser --path $OUTPUT_DIR"
    echo "   3. Xem file HOW_TO_VIEW_HIVE_DATA.md"
    echo ""
else
    echo ""
    echo "❌ Lỗi khi pull data"
    echo "   Kiểm tra quyền truy cập hoặc app đã được cài đặt chưa"
    echo ""
fi
