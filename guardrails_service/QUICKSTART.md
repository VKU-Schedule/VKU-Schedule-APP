# Quick Start - Guardrails Service với Groq (FREE)

## Bước 1: Lấy Groq API Key (2 phút)

1. Mở https://console.groq.com
2. Click "Sign Up" (dùng email hoặc Google)
3. Vào "API Keys" ở sidebar trái
4. Click "Create API Key"
5. Copy key (dạng: `gsk_...`)

## Bước 2: Setup Service (1 phút)

```bash
cd guardrails_service

# Tạo file .env
cp .env.example .env

# Mở .env và paste API key
nano .env
# Hoặc dùng editor bất kỳ
```

Sửa dòng này trong `.env`:
```
OPENAI_API_KEY=gsk_your_actual_key_here
```

## Bước 3: Chạy Service

### Option A: Docker (Khuyên dùng)

```bash
docker-compose up -d
```

### Option B: Python trực tiếp

```bash
pip install -r requirements.txt
python main.py
```

## Bước 4: Test

```bash
# Test đơn giản - chỉ prompt
curl -X POST http://localhost:8002/api/validate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "tôi thích học buổi sáng"}'

# Test với metadata - check logic conflicts
curl -X POST http://localhost:8002/api/validate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "không sáng nào",
    "metadata": {"morningPreferred": true}
  }'
```

Nếu thấy response JSON → Success! ✅

## Groq Free Tier

- ✅ **FREE** - Không tốn phí
- ✅ **30 requests/minute** - Đủ dùng
- ✅ **14,400 requests/day** - Rất nhiều
- ✅ **Cực nhanh** - ~500 tokens/second
- ✅ **Không cần thẻ** - Chỉ cần email

## Models Available

Đã config sẵn `llama-3.3-70b-versatile` (tốt nhất).

Nếu muốn đổi, edit `config/config.yml`:

```yaml
model: llama-3.1-8b-instant  # Nhanh hơn, nhẹ hơn
# hoặc
model: mixtral-8x7b-32768    # Tốt cho tiếng Việt
```

## Troubleshooting

**"Invalid API key":**
- Check key đã paste đúng chưa
- Key phải bắt đầu bằng `gsk_`
- Thử tạo key mới

**"Rate limit exceeded":**
- Đợi 1 phút rồi thử lại
- Free tier: 30 req/min

**Service không start:**
```bash
# Check logs
docker logs vku-schedule-guardrails

# Hoặc
python main.py
# Xem lỗi gì
```

## Next Steps

1. Tích hợp vào Flutter app (xem GUARDRAILS_INTEGRATION.md)
2. Test với các case khác nhau
3. Customize system prompt nếu cần (config/config.yml)

## Support

- Groq Docs: https://console.groq.com/docs
- Issues: Tạo issue trên GitHub
