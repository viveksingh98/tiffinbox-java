package probe.b.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import probe.b.ent.XSeq;

/** Spring Data's saveAll over the SEQUENCE harness entity: SimpleJpaRepository's own transaction, the caller none. */
public interface XSeqRepo extends JpaRepository<XSeq, Long> {
}
