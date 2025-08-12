FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /app
COPY ./bot_service/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Playwright browsers install (optional) - will be executed if PLAYWRIGHT_INSTALL env var=true
ARG PLAYWRIGHT_INSTALL=false
RUN if [ "$PLAYWRIGHT_INSTALL" = "true" ] ; then playwright install --with-deps chromium ; fi

COPY ./bot_service /app

EXPOSE 8001
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8001"]
