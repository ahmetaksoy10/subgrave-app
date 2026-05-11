//
//  Double+Currency.swift
//  Subgrave
//
//  TL para birimi formatlama yardımcıları.
//

import Foundation

extension Double {
    /// "₺59,99" formatında TL.
    var subgraveCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.currencySymbol = "₺"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "₺0,00"
    }

    /// Kuruşları yuvarlamış kısa hali ("₺60").
    var subgraveCurrencyShort: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.currencySymbol = "₺"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "₺0"
    }
}
