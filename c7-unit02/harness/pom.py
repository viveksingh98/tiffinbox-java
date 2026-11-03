# Course 7 · JPA, Hibernate, Spring Data: Three Different Things - reads a POM as the POM says it, nothing resolved, nothing inherited.
#   deps POM            each <dependency> directly under <project><dependencies>: groupId:artifactId scope[ optional]
#                       (no <scope>: compile, Maven's default); <dependencyManagement> and the build's plugins are not read
#   where POM NAME      every element whose text is NAME: its line in the file and its path from <project>
#   prop POM NAME       the text of <project><properties><NAME>
import sys, xml.parsers.expat, xml.etree.ElementTree as ET

def strip(t):
    return t.split('}', 1)[1] if t.startswith('{') else t

def deps(pom):
    root = ET.parse(pom).getroot()
    ds = [c for c in root if strip(c.tag) == 'dependencies']
    for block in ds:
        for d in block:
            if strip(d.tag) != 'dependency':
                continue
            f = {strip(c.tag): (c.text or '').strip() for c in d}
            print('%s:%s %s%s' % (f.get('groupId', ''), f.get('artifactId', ''), f.get('scope') or 'compile',
                                  ' optional' if f.get('optional') == 'true' else ''))

def where(pom, name):
    stack, text, out = [], [], []
    p = xml.parsers.expat.ParserCreate()
    def start(tag, attrs):
        stack.append((tag, p.CurrentLineNumber)); text.append('')
    def end(tag):
        t, line = stack.pop(); s = text.pop()
        if s.strip() == name:
            out.append('line %d: %s' % (line, '/'.join([x for x, _ in stack] + [t])))
    def data(s):
        if text:
            text[-1] += s
    p.StartElementHandler, p.EndElementHandler, p.CharacterDataHandler = start, end, data
    with open(pom, 'rb') as fh:
        p.ParseFile(fh)
    for o in out:
        print(o)

def prop(pom, name):
    root = ET.parse(pom).getroot()
    for c in root:
        if strip(c.tag) == 'properties':
            for q in c:
                if strip(q.tag) == name:
                    print((q.text or '').strip())

if __name__ == '__main__':
    m = sys.argv[1]
    if m == 'deps':
        deps(sys.argv[2])
    elif m == 'where':
        where(sys.argv[2], sys.argv[3])
    elif m == 'prop':
        prop(sys.argv[2], sys.argv[3])
    else:
        sys.exit('pom.py: deps POM | where POM NAME | prop POM NAME')
