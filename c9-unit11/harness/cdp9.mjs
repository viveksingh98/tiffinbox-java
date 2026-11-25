// Course 9 unit 08's extension of c6-unit23/harness/cdp.mjs - the harness's, never TiffinBox's. It is the S2 probe's cdp9probe.mjs
// (C9/_research/s2-probe-2026-11-24/instruments/, md5 09018a79...) REVIEWED and EDITED, so not byte-equal: every fixed sleep that stood
// in for a condition is a poll on a counted condition with a deadline (a deadline hit exits 4 with the state printed, never a hang); the
// operation is opened from a CLOSED state (already open exits 3: the step would be skipped); the expand control is measured both ways
// (click 1 on .opblock-summary-control, click 2 on .opblock-control-arrow only if click 1 left it closed - both outcomes printed); the
// shown status is read from the response row's cell, never the table's header. It attaches to the ONE tab cdp.mjs opened.
//   node cdp9.mjs PORT version                        Browser.getVersion: the product and the user agent
//   node cdp9.mjs PORT eval 'EXPR'                    prints the value (JSON)
//   node cdp9.mjs PORT rendered DEADLINE_MS           polls until the page shows operations and their count is the same on two polls
//                                                     in a row (a counted condition), then prints the count; 0 operations at the
//                                                     deadline exits 4 with the state printed
//   node cdp9.mjs PORT tryit OPID VALUE OUT.json      opens the operation OPID from closed, Try it out, fills the first input, Execute;
//                                                     every step's state before and after printed; the request's events to OUT.json
// STATUS_SEL (environment, the harness's plant only) points the status reader elsewhere: the default is the response row's cell.
import { writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
const [port, what, a1, a2, a3] = process.argv.slice(2);
const DEADLINE = Number(process.env.CDP9_DEADLINE_MS || 30000);
const STATUS_SEL = process.env.STATUS_SEL || '.live-responses-table tbody .response .response-col_status';
const tick = () => new Promise(r => setTimeout(r, 50));            // one poll step: never a wait standing in for a condition
let ver;
for (let i = 0; i < 240 && !ver; i++) { try { ver = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json(); } catch { await tick(); } }
if (!ver) { console.error('no Chrome answered on 127.0.0.1:' + port); process.exit(2); }
const ws = new WebSocket(ver.webSocketDebuggerUrl);
await new Promise((ok, no) => { ws.onopen = ok; ws.onerror = no; });
let id = 0; const pending = new Map(); const events = [];
ws.onmessage = m => { const d = JSON.parse(m.data); if (d.id && pending.has(d.id)) { pending.get(d.id)(d); pending.delete(d.id); }
  else if (d.method && d.method.startsWith('Network.')) events.push(d); };
const send = (method, params = {}, sessionId) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params, sessionId })); });
if (what === 'version') { const v = (await send('Browser.getVersion')).result; console.log('Browser.getVersion: product ' + v.product + ' · userAgent ' + v.userAgent); ws.close(); process.exit(0); }
const t = (await send('Target.getTargets')).result.targetInfos.filter(x => x.type === 'page' && x.url.startsWith('http://127.0.0.1:'));
if (t.length !== 1) { console.error('tabs found: ' + t.length); process.exit(2); }
const { result: { sessionId } } = await send('Target.attachToTarget', { targetId: t[0].targetId, flatten: true });
await send('Network.enable', {}, sessionId);
const ev = async e => (await send('Runtime.evaluate', { expression: e, returnByValue: true, awaitPromise: true }, sessionId)).result.result.value;
// until(label, expr): polls expr (a JSON state with a boolean "met") until met, or exits 4 at the deadline with the state printed
const until = async (label, expr) => { const t0 = Date.now(); let s;
  for (;;) { s = await ev(expr); if (s && s.met) return s; if (Date.now() - t0 > DEADLINE) { console.log(label + ': DEADLINE - the condition was never met; state ' + JSON.stringify(s)); process.exit(4); } await tick(); } };
const done = async c => { await send('Target.detachFromTarget', { sessionId }); ws.close(); process.exit(c); };
if (what === 'eval') { console.log(JSON.stringify(await ev(a1))); await done(0); }
if (what === 'rendered') {
  const t0 = Date.now(), dl = Number(a1 || DEADLINE); let last = -1, n;
  for (;;) { n = await ev(`document.querySelectorAll('.opblock').length`);
    if (n > 0 && n === last) break;
    if (Date.now() - t0 > dl) { console.log('rendered: DEADLINE - operations shown ' + n + ' (the condition: more than 0, the same on two polls in a row)'); await done(4); }
    last = n; await new Promise(r => setTimeout(r, 200)); }
  console.log('rendered: operations shown ' + n + ' (the same on two polls in a row)'); await done(0); }
if (what === 'tryit') {
  const op = a1, value = a2, out = a3, O = `document.querySelector('#operations-${op}')`;
  const state = `(() => { const o = ${O}; if (!o) return { met: false, op: 'absent' };
      const rows = o.querySelectorAll('.live-responses-table tbody .response').length; const st = o.querySelector(${JSON.stringify(STATUS_SEL)});
      return { open: o.classList.contains('is-open'), tryout: !!o.querySelector('.try-out__btn'), input: !!o.querySelector('.parameters input'),
               execute: !!o.querySelector('.execute'), liveRows: rows, status: st ? st.textContent.trim() : null }; })()`;
  const show = async label => { const s = await ev(state); console.log(label + ': ' + JSON.stringify(s)); return s; };
  const s0 = await show('state before');
  if (!s0 || s0.op === 'absent') { console.log('no operation ' + op); await done(2); }
  if (s0.open) { console.log('already open - the step was skipped'); await done(3); }
  const opened = `(() => { const o = ${O}; return { met: o.classList.contains('is-open') }; })()`;
  // click 1: the summary control; its outcome is printed whatever it is
  await ev(`(() => { const c = ${O}.querySelector('.opblock-summary-control'); if (c) c.click(); return !!c; })()`);
  let t1 = Date.now(), o1 = false;
  while (Date.now() - t1 < 2000) { if ((await ev(opened)).met) { o1 = true; break; } await tick(); }
  const s1 = await show('click 1 (.opblock-summary-control), state after');
  console.log('click 1 outcome: ' + (o1 ? 'opened' : 'still closed (polled 2 s on the is-open class)'));
  if (!o1) {
    await ev(`(() => { const c = ${O}.querySelector('.opblock-control-arrow'); if (c) c.click(); return !!c; })()`);
    await until('click 2 (.opblock-control-arrow)', opened);
    await show('click 2 (.opblock-control-arrow), state after');
    console.log('click 2 outcome: opened');
  } else console.log('click 2 (.opblock-control-arrow): not clicked - click 1 opened the operation');
  await until('try it out button', `(() => ({ met: !!${O}.querySelector('.try-out__btn') }))()`);
  await ev(`${O}.querySelector('.try-out__btn').click()`);
  await until('the input', `(() => ({ met: !!${O}.querySelector('.parameters input') && !!${O}.querySelector('.execute') }))()`);
  await show('try it out, state after');
  // the fill is typed as keyboard input (Input.insertText into the focused field), so the page's own handlers see it; then polled on
  // the field's value (a counted condition)
  await ev(`(() => { const i = ${O}.querySelector('.parameters input'); i.focus(); i.select(); return document.activeElement === i; })()`);
  await send('Input.insertText', { text: value }, sessionId);
  const filled = (await until('the fill', `(() => { const i = ${O}.querySelector('.parameters input'); return { met: i.value === ${JSON.stringify(value)}, value: i.value }; })()`)).value;
  // the field is a debounced input: leaving it (blur) hands the value to the page at once, where a fixed wait would only hope to outlast
  // the debounce
  await ev(`(() => { const i = ${O}.querySelector('.parameters input'); i.blur(); return document.activeElement !== i; })()`);
  console.log('fill: ' + JSON.stringify(filled));
  const before = events.length;
  await ev(`${O}.querySelector('.execute').click()`);
  await until('the answer', `(() => { const o = ${O}; const st = o.querySelector(${JSON.stringify(STATUS_SEL)}); const ve = o.querySelector('.validation-errors');
      return { met: o.querySelectorAll('.live-responses-table tbody .response').length >= 1 && !!st && st.textContent.trim() !== '', validation: ve ? ve.textContent.trim() : null }; })()`);
  await show('execute, state after');
  // the request the click made: every requestWillBeSent after it, and the one to TiffinBox waited for to its loadingFinished
  const after = () => events.slice(before);
  const reqs = () => after().filter(e => e.method === 'Network.requestWillBeSent');
  { const t0 = Date.now(); for (;;) { const r = reqs().filter(e => e.params.request.url.startsWith('http://127.0.0.1:'));
      if (r.length >= 1 && after().some(e => e.method === 'Network.loadingFinished' && e.params.requestId === r[0].params.requestId)) break;
      if (Date.now() - t0 > DEADLINE) { console.log('the request: DEADLINE - no loadingFinished'); await done(4); } await tick(); } }
  const R = reqs();
  console.log('requests after the click: ' + R.length);
  for (const r of R) {
    const q = r.params.request, rid = r.params.requestId, h = q.headers;
    const resp = after().find(e => e.method === 'Network.responseReceived' && e.params.requestId === rid);
    console.log('request: ' + q.method + ' ' + q.url + ' · accept ' + (h.Accept || h.accept) + ' · Referer ' + (h.Referer || h.referer) + ' · user agent ' + (h['User-Agent'] || h['user-agent']));
    if (resp) { const b = (await send('Network.getResponseBody', { requestId: rid }, sessionId)).result;
      const body = b.base64Encoded ? Buffer.from(b.body, 'base64') : Buffer.from(b.body, 'utf8');
      console.log('response: ' + resp.params.response.status + ' · Content-Type ' + resp.params.response.mimeType + ' · body ' + body.length + ' B md5 ' + createHash('md5').update(body).digest('hex')); }
  }
  const shown = await ev(`(() => { const o = ${O}; const c = o.querySelector(${JSON.stringify(STATUS_SEL)}); const u = o.querySelector('.request-url pre');
      const cu = o.querySelector('.curl-command .curl, .curl-command pre, pre.curl'); return { status: c && c.textContent.trim(), url: u && u.textContent.trim(), curl: cu && cu.textContent.trim().replace(/\\s+/g, ' ') }; })()`);
  console.log('the page shows: status ' + JSON.stringify(shown.status) + ' · request URL ' + JSON.stringify(shown.url) + ' · curl ' + JSON.stringify(shown.curl));
  writeFileSync(out, JSON.stringify(after(), null, 1));
  await done(0);
}
console.error('version, eval, rendered or tryit'); await done(2);
