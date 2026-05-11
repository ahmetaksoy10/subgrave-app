//
//  Date+Extensions.swift
//  Subgrave
//
//  Tarih formatlama ve hesaplama yardımcıları.
//

import Foundation

extension Date {
    /// "8 Mayıs 2026" formatında uzun tarih.
    var subgraveLongFormat: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }

    /// "08.05.2026" formatında kısa tarih (mezar taşı için).
    var subgraveShortFormat: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }

    /// "Mayıs 2026" – mezar tarihleri için.
    var subgraveMonthYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    /// "2026" sadece yıl.
    var subgraveYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }

    /// İki tarih arasındaki gün sayısı.
    func days(until other: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        let end = calendar.startOfDay(for: other)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// İki tarih arasındaki ay sayısı (yaklaşık).
    func months(until other: Date) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.month], from: self, to: other).month ?? 0
    }

    /// Bu tarihin yılı (Int olarak).
    var yearValue: Int {
        Calendar.current.component(.year, from: self)
    }

    /// Bu tarihin ayı (Int olarak).
    var monthValue: Int {
        Calendar.current.component(.month, from: self)
    }

    /// Yarın mı?
    var isTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }

    /// Bugün mü?
    var isToday: Bool { Calendar.current.isDateInToday(self) }

    /// "3 gün kaldı" gibi göreli ifadeler.
    var relativeFromNow: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
