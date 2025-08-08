My Modus — Monorepo (Frontend + Backend)

Structure:
- frontend/  — Flutter app (VIP design)
- backend/   — Dart Shelf parser API (returns structured JSON)
- .github/workflows/ — CI: build & deploy web, build backend image, lint/test, deploy to Render

HOW TO USE (local):
1) Frontend:
   cd frontend
   flutter pub get
   flutter create .   # generate platform folders if needed
   flutter run -d chrome

2) Backend:
   cd backend
   dart pub get
   dart run bin/server.dart

DEPLOY:
- Push to GitHub main branch. Web is built and deployed to gh-pages via Actions.
- Backend Docker image is built and pushed to GHCR via Actions.
- To auto-deploy backend to Render, set secret RENDER_SERVICE_ID and RENDER_API_TOKEN in repo secrets.

