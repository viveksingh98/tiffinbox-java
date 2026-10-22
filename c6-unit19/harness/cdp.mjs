// The course's harness, never TiffinBox's: drives a headless Chrome over its DevTools protocol - node's own WebSocket, nothing
// installed. Chrome must already listen on 127.0.0.1:PORT (receipts.sh starts it, with a profile of its own, and stops it by pid).
//   node harness/cdp.mjs PORT version      Chrome's version line (printed to the terminal, never into a capture)
//   node harness/cdp.mjs PORT visit URL OUT  one page in a new tab: every Network event the tab saw is written to OUT (JSON), and the
//                                            page's own line is printed - what its script could read - once its title says "done"
//                                            (60 s at most); then the tab is closed. The browser - and its preflight cache - stays.
//   node harness/cdp.mjs PORT close        Browser.close
import { writeFileSync } from 'node:fs';
const [port, what, url, outFile] = process.argv.slice(2);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ver;
for (let i = 0; i < 240 && !ver; i++) { try { ver = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json(); } catch { await sleep(250); } }
if (!ver) { console.error('no Chrome answered on 127.0.0.1:' + port); process.exit(2); }
if (what === 'version') { console.log(ver.Browser); process.exit(0); }
const ws = new WebSocket(ver.webSocketDebuggerUrl);
await new Promise((ok, no) => { ws.onopen = ok; ws.onerror = no; });
let id = 0; const pending = new Map(); const events = [];
ws.onmessage = m => { const d = JSON.parse(m.data); if (d.id && pending.has(d.id)) { pending.get(d.id)(d); pending.delete(d.id); } else if (d.method && d.method.startsWith('Network.')) events.push(d); };
const send = (method, params = {}, sessionId) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params, sessionId })); });
if (what === 'close') { await send('Browser.close'); ws.close(); process.exit(0); }
if (what !== 'visit') { console.error('visit, version or close'); process.exit(2); }
const { result: { targetId } } = await send('Target.createTarget', { url: 'about:blank' });
const { result: { sessionId } } = await send('Target.attachToTarget', { targetId, flatten: true });
await send('Network.enable', {}, sessionId);
await send('Page.enable', {}, sessionId);
await send('Page.navigate', { url }, sessionId);
const ev = async e => (await send('Runtime.evaluate', { expression: e, returnByValue: true }, sessionId)).result.result.value;
let title = '';
for (let i = 0; i < 240 && title !== 'done'; i++) { await sleep(250); title = await ev('document.title'); }
const line = await ev("(document.getElementById('out') || {}).textContent || ''");
await sleep(500);                      // the last events of a refused request arrive after the page has printed
console.log((title === 'done' ? 'the page printed: ' : 'the page never said done: ') + line);
writeFileSync(outFile, JSON.stringify(events.filter(e => e.sessionId === sessionId || !e.sessionId), null, 1));
await send('Target.closeTarget', { targetId });
ws.close();
