import Foundation
import SwiftData
import SwiftUI

@Model
final class Medication {
    var id: UUID
    var name: String
    var dosage: String
    var unit: String
    var colorHex: String
    var notes: String
    var isActive: Bool
    var scheduledTimes: [Date]

    @Relationship(deleteRule: .cascade, inverse: \MedicationDose.medication)
    var doses: [MedicationDose] = []

    init(
        name: String,
        dosage: String,
        unit: String = "mg",
        colorHex: String = "#4A90E2",
        notes: String = "",
        scheduledTimes: [Date] = []
    ) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.unit = unit
        self.colorHex = colorHex
        self.notes = notes
        self.isActive = true
        self.scheduledTimes = scheduledTimes
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    var nextDoseTime: Date? {
        let now = Date()
        let calendar = Calendar.current
        return scheduledTimes
            .compactMap { time -> Date? in
                let components = calendar.dateComponents([.hour, .minute], from: time)
                var next = calendar.nextDate(
                    after: now,
                    matching: components,
                    matchingPolicy: .nextTime
                )
                return next
            }
            .sorted()
            .first
    }
}

enum MedicationUnit: String, CaseIterable {
    case mg = "mg"
    case mcg = "mcg"
    case g = "g"
    case iu = "IU"
    case ml = "ml"
    case tablet = "เม็ด"
    case capsule = "แคปซูล"
    case drop = "หยด"
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255,
            green: Double((rgb & 0x00FF00) >> 8) / 255,
            blue: Double(rgb & 0x0000FF) / 255
        )
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
