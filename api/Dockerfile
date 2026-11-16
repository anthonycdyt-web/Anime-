FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates gnupg git \
    && install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone --depth 1 https://github.com/walterwhite-69/ReAnime.to-API.git /app/upstream

WORKDIR /app/upstream
RUN pip install --no-cache-dir fastapi uvicorn "httpx[http2]" pycryptodome

EXPOSE 8000
CMD ["sh", "-c", "uvicorn reanime:app --host 0.0.0.0 --port ${PORT:-8000}"]
