

## Bot service (FastAPI) — quickstart

The repository now includes a bot service (bot_service/) that provides:
- FastAPI endpoints to enqueue scraping tasks (`POST /enqueue`)
- A worker (`worker.py`) that polls the sqlite DB and processes jobs
- A simple requests-based scraper (`scraper_requests.py`) and an optional Playwright scraper (`scraper_playwright.py`)

Local dev steps:
1. Create virtualenv and install dependencies:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r bot_service/requirements.txt
   ```
2. Optionally install Playwright browsers if you plan to use the Playwright scraper:
   ```bash
   playwright install chromium
   ```
3. Initialize DB:
   ```bash
   python bot_service/init_db.py
   ```
4. Start API server:
   ```bash
   uvicorn bot_service.app:app --host 0.0.0.0 --port 8001
   ```
5. Start worker in another shell:
   ```bash
   python bot_service/worker.py
   ```

To enqueue a job:
```bash
curl -X POST http://localhost:8001/enqueue -H "Content-Type: application/json" -d '{"url":"https://www.wildberries.ru/catalog/12345", "connector":"wildberries"}'
```

Notes:
- For many marketplace pages you'll need Playwright (JS-rendered pages). The requests-based scraper works on simple static pages.
- Respect robots.txt and marketplace ToS. Use polite delays, proxy rotation and don't overload target sites.


## Ingest & Scrapers

To run the ingest job locally:

```
# ensure DB is running and migrations applied
dart backend/bin/ingest.dart seeds/seed_urls.txt
```

Search endpoint:
`GET /api/v1/search?q=shirt&limit=10`


## Testing marketplace scrapers

Seed URLs now include Lamoda, Wildberries and Ozon brand pages (from your input). Run ingest to attempt parsing them:

```
dart backend/bin/ingest.dart seeds/seed_urls.txt
```

If parsing fails for a page, adapters will return an error; send me the exact HTML snapshot and I will refine the parser.
