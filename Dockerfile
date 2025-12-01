FROM python:3.10-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy certificates
COPY certs/ /app/certs/

# Copy application code
COPY . .

CMD ["python", "main.py"]
