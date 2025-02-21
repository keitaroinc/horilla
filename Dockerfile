# Builder stage for docker image to build python reqs
FROM python:3.12.9-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY . .

RUN pip wheel --wheel-dir=/wheels --no-cache-dir -r requirements.txt

# Main Docker Image
FROM python:3.12.9-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY --from=builder /wheels /wheels
COPY --from=builder /app /app

RUN pip install --no-index --find-links=/wheels -r requirements.txt && \
    python manage.py collectstatic --noinput && \
    rm -rf /wheels

EXPOSE 8000

CMD ["gunicorn", "horilla.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "4", "--threads", "2", "--access-logfile", "-", "--error-logfile", "-"]