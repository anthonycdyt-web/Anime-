# ReAnime Roku channel (starter)

This is a native Roku SceneGraph channel starter connected to the hosted API.

API base: https://reanime-api-8923.onrender.com

## Current state
- Roku manifest and SceneGraph entry point added.
- Home screen requests /home?limit=30 and maps anime results into a PosterGrid.
- API requests run asynchronously in a Task node.
- Search, anime details, episode selection, and video playback still need implementation and device testing.

## Important
A Render API being live does not mean the Roku channel is published or installed. Roku requires a packaged ZIP and developer-mode sideloading for testing. Playback depends on Roku-compatible HLS streams and codecs.
