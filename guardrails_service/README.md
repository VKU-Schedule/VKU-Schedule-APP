# VKU Schedule Guardrails Service

NeMo Guardrails service for content moderation and validation in VKU Schedule app.

## Features

- **Offensive Content Detection**: Blocks inappropriate language
- **Logic Conflict Detection**: Identifies contradictions in preferences
- **Irrelevant Intent Detection**: Filters non-schedule-related content
- **Prompt Injection Prevention**: Blocks malicious input attempts
- **Feasibility Checks**: Warns about unrealistic constraints

## Setup

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Get FREE Groq API Key

Groq cung cấp API AI hoàn toàn miễn phí với tốc độ cực nhanh:

1. Truy cập: https://console.groq.com
2. Đăng ký tài khoản (free, chỉ cần email)
3. Vào "API Keys" → "Create API Key"
4. Copy key

### 3. Configure Environment

```bash
cp .env.example .env
# Edit .env và paste Groq API key vào OPENAI_API_KEY
```

### 4. Run Locally

```bash
python main.py
```

Service will be available at `http://localhost:8002`

### 5. Run with Docker

```bash
docker-compose up -d
```

## Why Groq?

- **FREE**: Không tốn phí
- **Fast**: ~500 tokens/second (nhanh hơn GPT nhiều lần)
- **Quality**: Llama 3.3 70B tương đương GPT-3.5/4
- **Generous limits**: 30 req/min, 14,400 req/day
- **No credit card**: Không cần thẻ tín dụng

## API Endpoints

### POST /api/validate

Validate user input for schedule optimization.

**Request:**
```json
{
  "prompt": "tôi thích học buổi chiều nhưng đừng đăng ký buổi chiều nào"
}
```

Siêu đơn giản - chỉ cần prompt!

**Response:**
```json
{
  "isValid": true,
  "severity": "ok",
  "message": null,
  "suggestion": null,
  "issues": []
}
```

**Severity Levels:**
- `ok`: No issues, proceed normally
- `warn`: Has warnings but can proceed
- `block`: Must be blocked, cannot proceed

## Configuration

### Using Groq (FREE - Recommended)

Đã config sẵn trong `config/config.yml`:
```yaml
models:
  - type: main
    engine: openai
    model: llama-3.3-70b-versatile
    parameters:
      openai_api_base: https://api.groq.com/openai/v1
```

Chỉ cần lấy API key tại https://console.groq.com

### Using OpenAI GPT (Paid)

Edit `config/config.yml`:
```yaml
models:
  - type: main
    engine: openai
    model: gpt-4o-mini
    # Bỏ parameters.openai_api_base
```

### Using Local Model (Offline)

```yaml
models:
  - type: main
    engine: huggingface
    model: meta-llama/Llama-2-7b-chat-hf
```

Cần GPU và download model (~13GB).

### Custom Rails

Edit `config/rails.co` to add custom validation rules using Colang syntax.

## Testing

```bash
# Test offensive content
curl -X POST http://localhost:8002/api/validate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "ghét cô X"}'

# Test logic conflict trong prompt
curl -X POST http://localhost:8002/api/validate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "tôi thích học buổi chiều nhưng đừng đăng ký buổi chiều nào"}'
```

## Integration with Flutter App

Update `lib/core/config/api_config.dart`:
```dart
static const String guardrailsApiBaseUrl = 'http://localhost:8002';
```

The Flutter app will call this service before optimization to validate input.
