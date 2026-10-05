# Council — AI Group Chat (prototype)

## Install on Windows / Chrome
1. Extract the ZIP into a permanent folder.
2. Open chrome://extensions and enable Developer mode.
3. Click **Load unpacked** and choose the `council` folder containing manifest.json.
4. Sign in normally at chatgpt.com, grok.com, and gemini.google.com. Open a dedicated empty conversation on each, and select your preferred model there. Keep those tabs open.
5. Click the extension toolbar icon (pin Council if needed). Click **Check connections**.
6. Send a small test question. Replies appear in the room. Click **Continue discussion** to share the collected answers with all selected participants for one further round.

## How it works
Each selected provider receives the same snapshot of the group transcript at the start of a round. By default Council brings each selected provider tab forward and collects replies one at a time, then returns to the room. Turn off **Bring provider tabs forward** to run concurrently in background tabs. Keep Chrome visible during foreground collection. The next round includes the collected replies, so the models can converse. Use the recipient menu or @ChatGPT / @Grok / @Gemini to direct a message. No background autonomous discussion runs. Stop attempts to stop the provider pages and cancels local collection.

## Important prototype limits
The extension’s website adapters are heuristic and have NOT been verified against live signed-in ChatGPT, Grok, or Gemini sessions. Composer/send selectors and response collection may require adjustment. Grok’s generic message-bubble fallback can misidentify a user bubble; inspect collected replies before continuing. A long reasoning pause can be mistaken for a completed response if the site exposes no generation indicator. Manual reply is available when collection fails. Refresh provider tabs after extension updates.

Only English website button labels are included. Choose the dedicated provider tab from its dropdown; selection is retained. Keep tabs visible if your browser throttles background pages. Start fresh provider chats when clearing the local conversation. Responses have a ten-minute collection timeout. Collection wakes on DOM changes as well as timed polls. A stop may not halt server-side generation. Do not immediately restart while provider pages are still generating.

This uses existing website sessions, not API keys. Your subscriptions’ normal model access and usage limits apply. This extension does not bypass limits or challenges. Website terms may restrict automation; review the applicable rules before use.

## Privacy
The extension reads visible chat content and enters prompts only on the three allowed domains. It does not read passwords, cookies or tokens and has no analytics or external backend. Your shared transcript is stored in chrome.storage.local (not encrypted) and is sent to the selected AI providers as prompt text. Export provides a JSON backup. New conversation removes the stored transcript; exported files and provider histories remain separate.

## Source and development
No build step or dependencies. Manifest V3, plain JavaScript/CSS. Adapters are in bridge.js; round orchestration is in room.js. Run `node --check` on each JavaScript file after edits. Load unpacked again or click Reload on chrome://extensions.

## Updating from 0.1.0
Replace the extracted extension files, click Reload on Council in chrome://extensions, refresh the ChatGPT/Grok/Gemini tabs, and reload the Council room. Then click Check connections. Refreshing provider tabs is required because the old bridge remains installed until navigation. Version 0.1.1 broadens ChatGPT editor detection, searches open shadow roots, and waits briefly for the composer to mount.

## Version 0.1.6
Council stays bound to the selected provider tabs and tracks delivered messages per conversation. It sends a short setup once, then only unseen user/peer messages, excluding the provider’s own replies and connection errors. A newly selected conversation starts with the latest human request instead of replaying the full room history. Changed conversations reset that cursor. Provider-side request records are polled by the room; completion no longer depends on a long-lived message callback. Website response selectors remain heuristic and need live validation.

## Version 0.1.9
Adds foreground collection (enabled by default), retaining the same round snapshot for every participant. Concurrent background mode remains available. DOM changes wake collection, completion uses elapsed quiet time instead of poll counts, and replies have up to ten minutes to finish. Foreground mode restores Council after completion or Stop. Website adapters still need live validation.

## Version 0.2.0 — Unified answer
Unified mode is the default for new rooms. Select at least two connected providers and a draft lead (Grok by default). Council collects proposals, shares them for discussion, asks the lead for a shared draft, obtains reviews from the other participants, then asks the lead for one final answer. Three providers use ten website replies per request; two use seven. These replies count against normal subscription limits. Work is saved under one collapsed discussion panel. Failures and Stop preserve contributions and mark the answer incomplete; no fabricated consensus or automatic fallback answer is shown. A compact shared brief carries context across requests without resending the full transcript. Existing chats remain bound to selected provider tabs. Switch to Group chat for individual replies and @mention routing. Refine answer runs another bounded collaboration cycle. The lead can be changed; if unselected, the first selected participant leads. Website adapters and foreground collection retain their existing limitations; keep Chrome visible.
