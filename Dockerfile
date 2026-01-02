FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY bot/ ./bot/
COPY assets/ ./assets/

# Create data directory
RUN mkdir -p /app/data

CMD ["python", "-m", "bot.main"]
