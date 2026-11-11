package probe.t;

import org.springframework.stereotype.Component;

/** Another bean: its calls into Svc23 go through the reference the context gave it - Svc23's proxy. */
@Component
public class Caller23 {
    final Svc23 svc;

    Caller23(Svc23 svc) { this.svc = svc; }

    public void viaProxy(String name) { svc.inner(name); }
    public void callProtected(String name) { svc.protInner(name); }
    public void callPackage(String name) { svc.pkgInner(name); }
    public void callPrivate(String name) { Svc23.callPrivateOn(svc, name); }
}
