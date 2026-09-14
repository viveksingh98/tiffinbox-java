module tiffinbox.wallet {
    requires tiffinbox.api;
    provides com.tiffinbox.api.PaymentGateway with com.tiffinbox.wallet.WalletGateway;
}
