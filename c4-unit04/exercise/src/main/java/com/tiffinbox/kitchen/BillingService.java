package com.tiffinbox.kitchen;

import com.tiffinbox.menu.MenuRepository;
import org.springframework.stereotype.Service;

@org.springframework.context.annotation.Lazy
@Service
public class BillingService {
    static { System.out.println("  CLASS LOADED  BillingService"); }

    private final MenuRepository menu;

    BillingService(MenuRepository menu) { this.menu = menu; }

    public int dishes() { return menu.dishCount(); }
}
