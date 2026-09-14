// A verified negative: en-IN does NOT group in lakh and crore on this JDK.
// Run:  java NumFmt.java
import java.text.NumberFormat;

void main() {
    long paise = 2_148_120L;
    Locale us = Locale.forLanguageTag("en-US");
    Locale in = Locale.forLanguageTag("en-IN");
    IO.println("getInstance(en-US)         : " + NumberFormat.getInstance(us).format(paise));
    IO.println("getInstance(en-IN)         : " + NumberFormat.getInstance(in).format(paise));
    IO.println("getCurrencyInstance(en-US) : " + NumberFormat.getCurrencyInstance(us).format(paise));
    IO.println("getCurrencyInstance(en-IN) : " + NumberFormat.getCurrencyInstance(in).format(paise));
}
