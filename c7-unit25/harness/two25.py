"""Two live psql sessions, A and B, driven one statement at a time in a fixed order (S4.12; the probe's third driver, made the
unit's). Each session is a /opt/homebrew/bin/psql -X -q -At process whose standard output and error are a pseudo-terminal, read
here as raw bytes (os.read on the terminal's descriptor, never a buffered reader: a buffered reader hides lines from select, the
markers drift, and three runs differ - RED #1212). After each statement the driver sends a \\echo marker and prints every line the
session wrote before the marker came back. A statement whose marker does not come back within the read bound is printed
"(waiting: no answer yet)" - no answer within the configured bound, the bounds printed in the header - and the driver goes on.
Every scene starts on a fresh database copied from the template the receipt seeded with the shipped Database (RE-MEASURE 3: no DDL
text here). The password: read from the file named by argv[2], handed to the two children in their environment only (PGPASSWORD),
never printed, never on a command line. Arguments: port, password file, template database, the three read bounds."""
import itertools, os, pty, select, subprocess, sys
PORT, PWFILE, TPL = sys.argv[1], sys.argv[2], sys.argv[3]
BOUND, BLOCKED, RELEASE = float(sys.argv[4]), float(sys.argv[5]), float(sys.argv[6])
PSQL = ['/opt/homebrew/bin/psql', '-X', '-q', '-At', '-P', 'pager=off', '-v', 'ON_ERROR_STOP=0', '-h', '127.0.0.1', '-p', PORT, '-U', 'sa', '-d', 'postgres']
env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C', 'PGPASSWORD': open(PWFILE).read().strip(), 'PGOPTIONS': '-c client_min_messages=warning'}
out = sys.stdout
def say(s):
    out.write(s + '\n'); out.flush()
def start():
    mfd, sfd = pty.openpty()
    p = subprocess.Popen(PSQL, stdin=subprocess.PIPE, stdout=sfd, stderr=sfd, env=env, text=True, bufsize=1)
    os.close(sfd)
    p.fd = mfd; p.buf = b''
    return p
say('# two live psql sessions, A and B: %s (each its own process; output on a pseudo-terminal, read as raw bytes)' % ' '.join(PSQL))
say('# the children\'s environment: PGPASSWORD (from the 0600 file, never printed) · PGOPTIONS=-c client_min_messages=warning · LC_ALL=C')
say('# read bounds, as configured: %.1f for each answer · %.1f for a statement expected to block · %.1f for the answer after a release and for the lock_timeout statement' % (BOUND, BLOCKED, RELEASE))
say('# "(waiting: no answer yet)" = no answer within the bound printed above; nothing here measures a time')
S = {'A': start(), 'B': start()}
ctr = itertools.count()
pending = {}
def send(n, sql, timeout=None):
    m = '__M%d__' % next(ctr)
    say('%s> %s' % (n, sql))
    S[n].stdin.write(sql + '\n\\echo ' + m + '\n'); S[n].stdin.flush()
    pending[n] = m
    return drain(n, BOUND if timeout is None else timeout)
def drain(n, timeout):
    p = S[n]; m = pending[n]
    while True:
        while b'\n' in p.buf:
            line, p.buf = p.buf.split(b'\n', 1)
            line = line.decode(errors='replace').rstrip('\r')
            if line == m:
                pending.pop(n); return True
            say('%s  %s' % (n, line))
        r, _, _ = select.select([p.fd], [], [], timeout)
        if not r:
            say('%s  (waiting: no answer yet)' % n); return False
        p.buf += os.read(p.fd, 65536)
k = itertools.count(1)
def scene(t):
    i = next(k)
    say('')
    say('## %d %s' % (i, t))
    for n in 'AB': send(n, '\\c postgres')
    send('A', 'drop database if exists u25s%d with (force);' % i)
    send('A', 'create database u25s%d template %s;' % (i, TPL))
    for n in 'AB': send(n, '\\c u25s%d' % i)
RV = "select meals_per_day from customer where name = 'Ravi';"
VEGN = "select count(*) from customer where meal_type = 'VEG';"
VEGS = "select sum(meals_per_day) from customer where meal_type = 'VEG';"
scene('a dirty read? B at READ UNCOMMITTED')
send('B', 'begin isolation level read uncommitted;'); send('B', 'show transaction_isolation;'); send('B', RV)
send('A', 'begin;'); send('A', "update customer set meals_per_day = 9 where name = 'Ravi';"); send('A', RV)
send('B', RV); send('A', 'rollback;'); send('B', 'commit;')
for lvl in ('read committed', 'repeatable read'):
    scene('a non-repeatable read? B at ' + lvl.upper())
    send('B', 'begin isolation level %s;' % lvl); send('B', RV)
    send('A', "update customer set meals_per_day = 9 where name = 'Ravi';"); send('A', RV)
    send('B', RV); send('B', 'commit;')
for lvl in ('read committed', 'repeatable read'):
    scene('a phantom? B at ' + lvl.upper())
    send('B', 'begin isolation level %s;' % lvl); send('B', VEGN)
    send('A', "insert into customer (name, meals_per_day, price_per_meal, meal_type) values ('Asha', 1, 100, 'VEG');"); send('A', VEGN)
    send('B', VEGN); send('B', 'commit;')
scene('a lost update? both at REPEATABLE READ')
send('B', 'begin isolation level repeatable read;'); send('B', RV)
send('A', 'begin isolation level repeatable read;'); send('A', RV); send('A', "update customer set meals_per_day = 3 where name = 'Ravi';"); send('A', 'commit;')
send('B', "update customer set meals_per_day = 3 where name = 'Ravi';"); send('B', '\\echo SQLSTATE :LAST_ERROR_SQLSTATE'); send('B', 'rollback;')
send('A', RV)
scene('write skew? both at SERIALIZABLE')
send('A', 'begin isolation level serializable;'); send('A', VEGS)
send('B', 'begin isolation level serializable;'); send('B', VEGS)
send('A', "update customer set meals_per_day = 1 where name = 'Ravi';"); send('B', "update customer set meals_per_day = 1 where name = 'Sunil';")
send('A', 'commit;'); send('B', 'commit;'); send('B', '\\echo SQLSTATE :LAST_ERROR_SQLSTATE')
send('A', VEGS)
scene('a lock wait at READ COMMITTED, no lock_timeout')
send('A', 'begin;'); send('A', "update customer set meals_per_day = 9 where name = 'Ravi';")
send('B', 'begin;'); send('B', "update customer set meals_per_day = 5 where name = 'Ravi';", BLOCKED)
send('A', 'commit;')
if drain('B', RELEASE): say('B  (answered: the blocked statement\'s marker came back)')
send('B', 'commit;'); send('B', RV)
scene('the same wait with lock_timeout set (a configured value)')
send('A', 'begin;'); send('A', "update customer set meals_per_day = 9 where name = 'Ravi';")
send('B', 'begin;'); send('B', "set local lock_timeout = '1s';"); send('B', 'show lock_timeout;')
send('B', "update customer set meals_per_day = 5 where name = 'Ravi';", RELEASE); send('B', '\\echo SQLSTATE :LAST_ERROR_SQLSTATE')
send('B', 'rollback;'); send('A', 'commit;'); send('B', RV)
for n in 'AB':
    S[n].stdin.close(); S[n].wait(); os.close(S[n].fd)
say('')
say('sessions closed: A exit %d · B exit %d' % (S['A'].returncode, S['B'].returncode))
