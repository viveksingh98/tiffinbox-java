package probe.map.one;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;

/** A customer's wallet - the inverse side: its table has no column that names the customer (mappedBy = "wallet"). */
@Entity
public class Wallet {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    private int balance;
    @OneToOne(mappedBy = "wallet", fetch = FetchType.LAZY)
    private WalletCustomer customer;

    protected Wallet() { }
    public Wallet(int balance) { this.balance = balance; }
    public Long getId() { return id; }
    public int getBalance() { return balance; }
    public WalletCustomer getCustomer() { return customer; }
}
