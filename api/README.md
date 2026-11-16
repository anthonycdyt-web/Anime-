# ReAnime API — Render deployment

This folder contains a Docker build definition for the upstream ReAnime.to API. The Docker image installs Python 3.11 and Node.js 20, clones the upstream API source at build time, installs its documented Python dependencies, and starts FastAPI with Uvicorn.

## Deploy

1. Push this repository to GitHub.
2. In Render, choose **New → Blueprint** and select this repository.
3. Render detects the root `render.yaml` and creates the `reanime-api` web service.
4. Wait for the Docker build to finish, then open the service URL.
5. A healthy service returns JSON at `/` describing available API endpoints.

## Roku app API base URL

Use the Render service origin (for example, `https://your-service.onrender.com`) as the API base URL. Do not add a trailing slash.

## Important limitations

- This is a deployment configuration, not a live deployment. A Render account must be connected and the Blueprint must be deployed.
- The upstream project is maintained separately. This image clones its default branch during each build, so upstream changes can affect future builds.
- Free Render web services may spin down when idle and take time to wake.
- The upstream scraper depends on ReAnime and Flixcloud continuing to respond. Stream URLs may expire, and some hosts may reject playback outside a browser.
- Roku playback requires a compatible HLS stream. Successful API deployment does not guarantee every returned stream will play on Roku.
