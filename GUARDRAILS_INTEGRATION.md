# Tích hợp NeMo Guardrails vào VKU Schedule App

## Tổng quan

Đã triển khai đầy đủ NeMo Guardrails service để kiểm soát đầu vào với các tính năng:

### Các kiểm tra đã implement:

**1. Block (chặn hoàn toàn):**
- Ngôn từ công kích/thô tục
- Prompt injection attempts  
- Nội dung không liên quan ("không muốn học")
- Prompt quá dài (>500 ký tự)
- Chưa chọn môn học
- Mâu thuẫn logic nghiêm trọng
- Tránh quá nhiều ngày (>=6 ngày)

**2. Warn (cảnh báo nhưng cho tiếp tục):**
- Môn học trùng lặp
- Quá nhiều ràng buộc (khó tìm lịch)
- Ràng buộc không hợp lý

## Cấu trúc đã tạo

```
guardrails_service/
├── config/
│   ├── config.yml          # Cấu hình NeMo Guardrails
│   └── rails.co            # Định nghĩa rails bằng Colang
├── main.py                 # FastAPI service
├── requirements.txt        # Python dependencies
├── Dockerfile             # Docker image
├── docker-compose.yml     # Docker compose config
├── .env.example           # Environment variables template
└── README.md              # Documentation

lib/
├── core/
│   ├── config/
│   │   └── api_config.dart           # Đã thêm guardrailsApiBaseUrl
│   └── di/
│       └── providers.dart            # Đã thêm guardrailsServiceProvider
└── services/
    └── guardrails_service.dart       # Service gọi Guardrails API
```

## Cách chạy

### 1. Setup Guardrails Service

```bash
cd guardrails_service

# Lấy FREE Groq API Key
# 1. Truy cập https://console.groq.com
# 2. Đăng ký (free)
# 3. Tạo API key
# 4. Copy key

# Tạo .env file
cp .env.example .env
# Edit .env và paste Groq API key vào OPENAI_API_KEY

# Chạy với Docker
docker-compose up -d

# Hoặc chạy trực tiếp
pip install -r requirements.txt
python main.py
```

Service sẽ chạy tại `http://localhost:8002`

**Tại sao dùng Groq?**
- ✅ Hoàn toàn FREE
- ✅ Cực nhanh (~500 tokens/s)
- ✅ Chất lượng tốt (Llama 3.3 70B)
- ✅ Không cần thẻ tín dụng
- ✅ 30 req/min, 14,400 req/day

### 2. Tích hợp vào Flutter App

Trong `lib/features/preferences/presentation/preference_input_page.dart`, thêm validation trước khi submit:

```dart
Future<void> _handleSubmit() async {
  final promptText = _textController.text.trim();
  
  // ... existing validation ...
  
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  // Validate using NeMo Guardrails
  final guardrailsService = ref.read(guardrailsServiceProvider);
  final subjectSelection = ref.read(subjectSelectionProvider);
  final preferences = ref.read(preferencesProvider);
  final selectedSubjects = subjectSelection.getEnrolledSubjects();

  final validationResult = await guardrailsService.validate(
    prompt: promptText,
    subjects: selectedSubjects,
    constraints: preferences,
  );

  if (mounted) {
    setState(() {
      _isLoading = false;
    });

    // Handle validation result
    if (validationResult.isBlock) {
      _showValidationDialog(
        context: context,
        result: validationResult,
        canProceed: false,
      );
      return;
    }

    if (validationResult.isWarn) {
      final shouldProceed = await _showValidationDialog(
        context: context,
        result: validationResult,
        canProceed: true,
      );
      
      if (shouldProceed != true) {
        return;
      }
    }

    // Save and proceed
    ref.read(preferencesProvider.notifier).updatePromptText(promptText);
    context.go('/weights');
  }
}
```

### 3. Test Guardrails Service

```bash
# Test offensive content
curl -X POST http://localhost:8002/api/validate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "ghét cô X",
    "subjects": [],
    "constraints": {"morningPreferred": false, "noDays": [], "avoidInstructors": []}
  }'

# Expected response:
# {
#   "isValid": false,
#   "severity": "block",
#   "message": "Vui lòng không sử dụng ngôn từ không phù hợp",
#   "suggestion": "Hãy mô tả sở thích của bạn một cách lịch sự và tích cực",
#   "issues": [...]
# }

# Test logic conflict
curl -X POST http://localhost:8002/api/validate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "tôi thích học buổi sáng nhưng không sáng nào",
    "subjects": [{"courseName": "Python", "subTopic": "Cơ bản"}],
    "constraints": {"morningPreferred": true, "noDays": [], "avoidInstructors": []}
  }'

# Expected response:
# {
#   "isValid": false,
#   "severity": "block",
#   "message": "Mâu thuẫn: Vừa chọn ưu tiên sáng nhưng lại nói không muốn học sáng",
#   ...
# }
```

## Cấu hình cho Genymotion

Trong `lib/core/config/api_config.dart`, URL đã được set đúng cho Genymotion:

```dart
static const String guardrailsApiBaseUrl = 'http://10.0.3.2:8002';
```

## Tùy chỉnh Rails

Để thêm/sửa rules, edit `guardrails_service/config/rails.co`:

```colang
# Thêm pattern mới
define user express new offensive pattern
  "từ cấm mới"
  "pattern khác"

define bot refuse new pattern
  "Thông báo lỗi tương ứng"

define flow new pattern check
  user express new offensive pattern
  bot refuse new pattern
  stop
```

Sau đó restart service:
```bash
docker-compose restart
```

## Fallback Strategy

Nếu Guardrails service down, `GuardrailsService` sẽ tự động fallback về `ValidationResult.ok()` để không block user. Điều này đảm bảo app vẫn hoạt động ngay cả khi service validation gặp sự cố.

## So sánh với InputValidationService

| Feature | InputValidationService (Local) | GuardrailsService (NeMo) |
|---------|-------------------------------|--------------------------|
| Offline | ✅ Hoàn toàn offline | ❌ Cần internet/server |
| Hiểu ngữ cảnh | ❌ Rule-based đơn giản | ✅ LLM hiểu sâu hơn |
| Latency | ✅ <1ms | ⚠️ 100-500ms |
| Bắt biến thể | ❌ Phải list hết | ✅ Tự động bắt |
| Setup | ✅ Đơn giản | ⚠️ Phức tạp hơn |
| Chi phí | ✅ Free | ⚠️ Có thể tốn tiền (GPT) |

## Khuyến nghị

- **Development**: Dùng InputValidationService (đơn giản, nhanh)
- **Production**: Dùng GuardrailsService (chính xác hơn, bắt được nhiều case hơn)
- **Hybrid**: Dùng cả hai - local validation trước, sau đó gọi Guardrails nếu cần

## Monitoring

Guardrails service có logging đầy đủ. Xem logs:

```bash
docker logs -f vku-schedule-guardrails
```

## Troubleshooting

**Service không start:**
- Check Groq API key trong .env (lấy tại https://console.groq.com)
- Verify API key còn hạn sử dụng
- Check logs: `docker logs -f vku-schedule-guardrails`

**Validation quá chậm:**
- Groq đã rất nhanh (~500 tokens/s)
- Nếu vẫn chậm, đổi sang model nhỏ hơn: `llama-3.1-8b-instant`
- Giảm timeout trong api_config.dart

**Rate limit exceeded:**
- Groq free: 30 req/min, 14,400 req/day
- Implement caching ở Flutter app
- Hoặc upgrade Groq plan (vẫn rẻ hơn OpenAI nhiều)

**False positives:**
- Điều chỉnh system prompt trong config.yml
- Thêm ví dụ cụ thể vào instructions
- Tăng temperature nếu quá strict (hiện tại: 0.1)
