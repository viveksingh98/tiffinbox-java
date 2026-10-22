// The course's harness, never TiffinBox's: drives a headless Chrome over its DevTools protocol - node's own WebSocket, nothing
// installed. Chrome must already listen on 127.0.0.1:PORT (receipts.sh starts it, with a profile of its own, and stops it by pid).
// One tab is a visitor: open makes it, again and reload use it, so every visit after the first meets what Chrome kept from the ones
// before - its cache.
//   node harness/cdp.mjs PORT open URL OUT     a new tab, URL typed into its address bar
//   node harness/cdp.mjs PORT again URL OUT    the tab open opened: URL typed into its address bar again
//   node harness/cdp.mjs PORT reload OUT       the tab open opened: the page reloaded (Chrome's reload button)
//   node harness/cdp.mjs PORT close            Browser.close
// open, again and reload write every Network event the tab saw during that visit to OUT (JSON), and print the page Chrome shows
// once it has loaded (60 s at most): its title, its address, the stylesheet it links, and the colour the stylesheet gave its footer
// (computed by Chrome: what the person sees).
import { writeFileSync } from 'node:fs';
const [port, what, a1, a2] = process.argv.slice(2);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ver;
for (let i = 0; i < 240 && !ver; i++) { try { ver = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json(); } catch { await sleep(250); } }
if (!ver) { console.error('no Chrome answered on 127.0.0.1:' + port); process.exit(2); }
const ws = new WebSocket(ver.webSocketDebuggerUrl);
await new Promise((ok, no) => { ws.onopen = ok; ws.onerror = no; });
let id = 0, loads = 0; const pending = new Map(); const events = [];
ws.onmessage = m => { const d = JSON.parse(m.data); if (d.id && pending.has(d.id)) { pending.get(d.id)(d); pending.delete(d.id); }
  else if (d.method === 'Page.loadEventFired') loads++; else if (d.method && d.method.startsWith('Network.')) events.push(d); };
const send = (method, params = {}, sessionId) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params, sessionId })); });
if (what === 'close') { await send('Browser.close'); ws.close(); process.exit(0); }
if (what !== 'open' && what !== 'again' && what !== 'reload') { console.error('open, again, reload or close'); process.exit(2); }
const url = what === 'reload' ? null : a1, outFile = what === 'reload' ? a1 : a2;
let targetId;
if (what === 'open') targetId = (await send('Target.createTarget', { url: 'about:blank' })).result.targetId;
else {
  const t = (await send('Target.getTargets')).result.targetInfos.filter(x => x.type === 'page' && x.url.startsWith('http://127.0.0.1:'));
  if (t.length !== 1) { console.error('the tab open opened: ' + t.length + ' found'); process.exit(2); }
  targetId = t[0].targetId;
}
const { result: { sessionId } } = await send('Target.attachToTarget', { targetId, flatten: true });
await send('Network.enable', {}, sessionId);
await send('Page.enable', {}, sessionId);
const ev = async e => (await send('Runtime.evaluate', { expression: e, returnByValue: true }, sessionId)).result.result.value;
// loaded(n): the n-th load event has fired and the document says complete (60 s at most)
const loaded = async n => { for (let i = 0; i < 240; i++) { if (loads >= n && await ev('document.readyState') === 'complete') return true; await sleep(250); } return false; };
if (what === 'reload') await send('Page.reload', {}, sessionId); else await send('Page.navigate', { url }, sessionId);
const ok = await loaded(1);
const page = await ev(`(() => { const l = document.querySelector('link[rel=stylesheet]'); const f = document.querySelector('footer');
  return document.title + ' · its address: ' + location.pathname + ' · its stylesheet: ' + (l ? new URL(l.href).pathname : 'none')
    + ' · its footer, coloured by it: ' + (f ? getComputedStyle(f).color : 'no footer'); })()`);
await sleep(500);                      // the last events of the page's own requests arrive after it has loaded
console.log((ok ? 'the page Chrome shows: ' : 'the page never finished loading: ') + page);
writeFileSync(outFile, JSON.stringify(events.filter(e => e.sessionId === sessionId || !e.sessionId), null, 1));
await send('Target.detachFromTarget', { sessionId });
ws.close();
