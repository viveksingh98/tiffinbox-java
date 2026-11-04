package probe.map.one;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;

/** A customer with one wallet - the owning side: wallet_id is a column of this table. */
@Entity
public class WalletCustomer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private String name;
    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.PERSIST)
    @JoinColumn(name = "wallet_id")
    private Wallet wallet;

    protected WalletCustomer() { }
    public WalletCustomer(String name, Wallet wallet) { this.name = name; this.wallet = wallet; }
    public Long getId() { return id; }
    public String getName() { return name; }
    public Wallet getWallet() { return wallet; }
}
