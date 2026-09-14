module tiffinbox.card {
    requires tiffinbox.api;
    provides com.tiffinbox.api.PaymentGateway with com.tiffinbox.card.CardGateway;
}
