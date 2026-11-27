-- Course 9, unit 04: the Idempotency-Key store (draft-ietf-httpapi-idempotency-key-header-09). One row per key.
-- status 0 = claimed: a request with this key is in flight; any other value = the stored answer's status.
-- claim_token = the claim's fence: the owner's random token while status is 0, NULL once the answer is stored.
-- claimed_at = the database's own clock (CURRENT_TIMESTAMP) at the claim or its reclaim, never a JVM's.
CREATE TABLE idempotency_key (
    idem_key     VARCHAR(255) PRIMARY KEY,
    request_hash VARCHAR(64)  NOT NULL,
    status       INT          NOT NULL,
    claim_token  VARCHAR(36),
    claimed_at   TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    location     VARCHAR(2048),
    content_type VARCHAR(255),
    body         TEXT
);
