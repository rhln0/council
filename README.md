# Council

Local AI group chat using signed-in ChatGPT, Grok and Gemini tabs. Prototype website adapters; live signed-in connections remain unverified.

## Install
Download this repository once, then Load unpacked in chrome://extensions and select council/. Open fresh provider chats and click the extension icon.

## Windows updater
Run updater/Setup-Council.cmd once. It accepts either your actual extension folder or its parent. Use rhln0/council as the source. Later run Update-Council.cmd, reload the extension, and refresh provider tabs and the room. No new ZIP is needed. The updater stores a backup and validates all release checksums before writing files.

## Publish changes
Change the extension source and its manifest version, then regenerate update.json with python3 scripts/build-release.py. Publish all changed files and update.json in one commit. Keep the seven extension filenames unchanged unless the updater allowlist is updated.

## Limits
Website selectors are heuristic. Normal subscription limits apply. Use Manual reply if collection fails. The extension does not handle login tokens or passwords. Data is stored locally and sent as transcript context to selected providers.

Windows updater execution has not been tested on Windows. Routing and editor tests use simulated browser objects.
