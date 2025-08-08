# My Modus — Complete Monorepo (Frontend + Backend)

**Contents:**  
- `frontend/` — Flutter app (VIP UI, assets, launcher icon & native splash config).  
- `backend/` — Dart Shelf parser API (returns structured JSON).  
- `.github/workflows/` — Actions: build & deploy web to gh-pages, build backend image & push to GHCR, backend CI tests, optional Render deploy.  
- `setup.sh` — helper script to create platform folders, run `pub get`, and generate icons/splash.  
- `setup.bat` — Windows helper (if present).  
- `README.md` — short intro.  
- `RELEASE_README.md` — this file (detailed instructions, troubleshooting, deploy guide).

---

## Goals of this package

This repository is designed so you can run the project locally and/or deploy it to production using GitHub Actions + Render (optional). The frontend is a Flutter app (mobile + web). The backend is a Dart Shelf service that scrapes Wildberries brand page and returns JSON to the client.

**Important note about legality & scraping:**  
Scraping third-party websites may be restricted by their Terms of Service. Use this project responsibly — ideally with the permission of the data owner. This project is for prototyping and internal testing.

---

## 1) Quick start (Linux / macOS / WSL)

### Prerequisites
- Git
- Flutter (stable) — https://flutter.dev/docs/get-started/install
- Dart SDK (for backend) — https://dart.dev/get-dart  (or use the Dart bundled with Flutter)
- Docker (optional, for backend image)
- jq (optional, for pretty JSON)
- curl

### Steps

1. **Unpack the archive**  
   Extract the zip file and `cd` into the created folder:
   ```bash
   unzip my_modus_complete_all.zip
   cd my_modus_complete_all
   ```

2. **Setup frontend platform folders and icons/splash**  
   Run the helper script (from project root):
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```
   What the script does:
   - Removes existing platform folders inside `frontend/` (android, ios, web, macos, windows, linux) to avoid conflicts.
   - Runs `flutter create .` in `frontend/` to generate platform folders.
   - Runs `flutter pub get`.
   - Generates launcher icons and native splash (via `flutter_launcher_icons` and `flutter_native_splash`).

3. **Run backend (local)** — in a separate terminal:
   ```bash
   cd backend
   dart pub get
   dart run bin/server.dart
   ```
   Server listens on port `8080` by default. You should see:
   ```
   Server listening on port 8080
   ```

4. **Test backend API**:
   ```bash
   curl http://localhost:8080/api/products | jq .
   ```
   Expected: JSON like `{"products":[{...},{...}]}`.

5. **Run frontend (web)**:
   ```bash
   cd frontend
   flutter pub get
   flutter run -d chrome
   ```
   Or explicitly specify backend URL (if backend is on different host/port):
   ```bash
   flutter run -d chrome --dart-define=API_URL=http://localhost:8080/api/products
   ```

6. **Run frontend (mobile)**: connect a device or emulator and:
   ```bash
   flutter run
   ```

---

## 2) How it works — architecture overview

- **Frontend**: Flutter app requests product data from a relative API endpoint (default `http://localhost:8080/api/products` when running via `--dart-define`), then renders cards, images, prices, favorite toggle. The UI uses `google_fonts`, animated favorite button, hero transitions. For web builds the app is published to `gh-pages`.

- **Backend**: Dart Shelf server fetches the public Wildberries brand page `https://www.wildberries.ru/brands/311036101-my-modus`, parses HTML using `package:html`, extracts product cards, normalizes data into JSON and returns `{ "products": [ ... ] }`. CORS headers are added to allow browser clients to call the API.

- **CI/CD**:
  - `build-and-deploy-web.yml`: builds `frontend` web and deploys to `gh-pages` on push to `main`.
  - `build-backend-image.yml`: builds Docker image for backend and pushes to GitHub Container Registry.
  - `backend-ci.yml`: runs backend tests on push/PR.
  - `deploy-backend-render.yml`: optional Render deployment via API (requires secrets).

---

## 3) Deploying the backend (recommended: Render)

We provide two options:

### Option A — Deploy Docker image to Render (recommended for simplicity)
1. Create a Render service (Web Service). Choose Docker.
2. In GitHub, go to repository Settings → Secrets and variables → Actions → Add:  
   - `RENDER_SERVICE_ID` — your Render service ID (starts with `srv-...`).
   - `RENDER_API_TOKEN` — Render API key (from Render dashboard).
3. The workflow `.github/workflows/deploy-backend-render.yml` triggers on push to `main` and will call Render API to create a new deploy. The workflow assumes the repository is connected to Render service. Alternatively you can manually configure Render to deploy from the repo.

### Option B — Deploy to your server / Cloud Run
- Build the Docker image locally:
  ```bash
  cd backend
  docker build -t my-modus-backend .
  docker run -p 8080:8080 my-modus-backend
  ```
- Push to your container registry and run on your hosting provider.

**Important:** After backend is public, update frontend configuration (if needed) to point to the public backend URL:
- In web build you can set `API_URL` via build environment or edit `frontend/lib/services/parser_service.dart` default.

---

## 4) GitHub Pages (frontend web)

The workflow will deploy `frontend/build/web` to `gh-pages` branch automatically when pushing `main`. After push, enable GitHub Pages site in repository Settings → Pages → Source = `gh-pages` branch (if not already auto-enabled by actions).

**CORS note:** The frontend web will call the backend (must be public). The backend includes `Access-Control-Allow-Origin: *`, so cross-origin calls should succeed.

---

## 5) Troubleshooting

### A) Empty UI / No products visible
- Open browser devtools (F12) → Console and Network. Look for:
  - `Failed to fetch` → backend not reachable, or wrong URL.
  - CORS errors → backend not serving CORS headers (ensure you run the provided backend).
- Run `curl http://localhost:8080/api/products` to confirm backend response.

### B) Backend fails to start: `failed to look host up` or DNS errors
- Ensure machine has internet access and can resolve `www.wildberries.ru`.
- Test manually: `curl https://www.wildberries.ru/brands/311036101-my-modus`
- If DNS fails on cloud VM, try changing `/etc/resolv.conf` to use `8.8.8.8`.

### C) Issues with `flutter_launcher_icons` or `flutter_native_splash`
- Run `flutter pub get` then:
  ```bash
  dart run flutter_launcher_icons:main
  dart run flutter_native_splash:create
  ```
- If `dart run` fails, try `flutter pub run ...`.

### D) Parser returns empty list (page structure changed)
- Wildberries may change HTML. Fix by updating selectors in:
  - `backend/bin/server.dart`: adjust `querySelectorAll` selectors and extraction logic.
- If you provide a sample HTML of a few product cards, I can patch selectors.

---

## 6) How to update parser selectors (short guide)

1. Open `backend/bin/server.dart`.
2. Find lines:
   ```dart
   List<Element> items = doc.querySelectorAll('article.product-card');
   if (items.isEmpty) {
     items = doc.querySelectorAll('div.product-card, div.product-card-card, li.product-card');
   }
   ```
3. Inspect the Wildberries page in browser (right-click → Inspect) and find the product element container.
4. Replace selector with accurate one, and adjust extraction: link, title (aria-label or inner text), price (strip non-digits), image (data-src or src).

---

## 7) Security & Rate-limiting
- To be polite and reduce load on Wildberries, add caching and rate limits in the backend. For example, cache the parsed JSON for 5–15 minutes (use in-memory or filesystem cache).
- Avoid making many frequent requests in a short time; consider background scheduled scraping via GitHub Actions (if you choose static JSON) instead of on-demand scraping.

---

## 8) FAQ

**Q:** Will this get banned by Wildberries?  
**A:** Possibly if you make many rapid automated requests. Use caching, respect robots.txt, and seek permission for production use.

**Q:** Can we publish this to App Stores?  
**A:** Frontend can be packaged as normal. Backend scraping component is a legal/ToS concern; consider replacing it with an official API if available.

---

## 9) Next steps I can do for you
- Add caching in backend (file or in-memory with TTL).
- Harden parser and add retries/backoff.
- Create a GitHub Action periodic scraper that updates a static `products.json` (no live backend needed for web).
- Help push to GitHub and configure Render — I will provide the exact steps and the minimal secrets to add.

---

## License
MIT-style (see LICENSE file). Use at your own risk; check Terms of Service of target sites.

