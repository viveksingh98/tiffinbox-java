package probe.t;

/** An interface-typed bean: which proxy does Spring Boot give it? */
public interface Billing {
    void saveAndFail(String name);
}
