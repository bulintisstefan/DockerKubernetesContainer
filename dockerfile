# Imagine de bază minimală
FROM python:3.12-slim

# Env utilitare
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8080

# Director de lucru
WORKDIR /app

# Instalează dependențele
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiază aplicația
COPY app.py .

# Expune portul (informativ)
EXPOSE 8080

# Pornește aplicația
CMD ["python", "app.py"]
