// The course's harness, never TiffinBox's: drives a headless Chrome over its DevTools protocol - node's own WebSocket, nothing
// installed. Chrome must already listen on 127.0.0.1:PORT (receipts.sh starts it, with a profile of its own, and stops it by pid).
// Every command after the first meets what Chrome kept from the ones before - its cookies above all: one Chrome is one visitor.
//   node harness/cdp.mjs PORT open URL OUT         one page in a new tab, as a person types its address: every Network event the
//                                                  tab saw is written to OUT (JSON), and the page Chrome shows is printed - its
//                                                  title, its address, its notes, how many of its links carry a session id - once
//                                                  it has loaded (60 s at most); then the tab is closed
//   node harness/cdp.mjs PORT form URL OUT FIELDS  the same for the form at URL, then its inputs set from FIELDS (name=value&...,
//                                                  as a person would type them) and the form submitted with its own button's
//                                                  action (requestSubmit); Chrome's record and the page are those of what followed
//   node harness/cdp.mjs PORT cookies              Chrome's cookie store, every cookie in it, one line each: its name=value, its
//                                                  domain and path, and the four flags Chrome keeps (httpOnly, secure, sameSite,
//                                                  session: kept only until the browser closes)
//   node harness/cdp.mjs PORT close                Browser.close
import { writeFileSync } from 'node:fs';
const [port, what, url, outFile, fields] = process.argv.slice(2);
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
if (what === 'cookies') {
  const c = (await send('Storage.getCookies')).result.cookies;
  console.log("Chrome's cookie store: " + c.length + ' cookie' + (c.length === 1 ? '' : 's'));
  for (const k of c) console.log('  ' + k.name + '=' + k.value + ' · domain ' + k.domain + ' · path ' + k.path + ' · httpOnly ' + k.httpOnly
    + ' · secure ' + k.secure + ' · sameSite ' + (k.sameSite || '(none)') + ' · session ' + k.session);
  ws.close(); process.exit(0);
}
if (what !== 'open' && what !== 'form') { console.error('open, form, cookies or close'); process.exit(2); }
const { result: { targetId } } = await send('Target.createTarget', { url: 'about:blank' });
const { result: { sessionId } } = await send('Target.attachToTarget', { targetId, flatten: true });
await send('Network.enable', {}, sessionId);
await send('Page.enable', {}, sessionId);
const ev = async e => (await send('Runtime.evaluate', { expression: e, returnByValue: true }, sessionId)).result.result.value;
// loaded(n): the n-th load event has fired and the document says complete (60 s at most)
const loaded = async n => { for (let i = 0; i < 240; i++) { if (loads >= n && await ev('document.readyState') === 'complete') return true; await sleep(250); } return false; };
await send('Page.navigate', { url }, sessionId);
let ok = await loaded(1);
if (ok && what === 'form') {
  const set = [...new URLSearchParams(fields)].map(([k, v]) => `document.querySelector('[name="${k}"]').value = ${JSON.stringify(v)};`).join(' ');
  await ev(`${set} document.querySelector('form').requestSubmit(); 'sent'`);
  ok = await loaded(2);
}
const page = await ev(`(() => { const notes = [...document.querySelectorAll('.note')].map(e => e.textContent);
  const links = [...document.querySelectorAll('a[href], link[href]')].filter(e => e.getAttribute('href').includes(';jsessionid=')).length;
  return document.title + ' · its address: ' + location.pathname + ' · its notes: ' + (notes.length ? notes.join(' | ') : 'none')
    + ' · its links that carry a session id: ' + links; })()`);
await sleep(500);                      // the last events of the page's own requests arrive after it has loaded
console.log((ok ? 'the page Chrome shows: ' : 'the page never finished loading: ') + page);
writeFileSync(outFile, JSON.stringify(events.filter(e => e.sessionId === sessionId || !e.sessionId), null, 1));
await send('Target.closeTarget', { targetId });
ws.close();
