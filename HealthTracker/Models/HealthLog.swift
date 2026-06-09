import Foundation
import SwiftData

@Model
final class HealthLog {
    var id: UUID
    var date: Date
    var weight: Double?
    var bloodPressureSystolic: Int?
    var bloodPressureDiastolic: Int?
    var heartRate: Int?
    var bloodSugar: Double?
    var mood: Int?
    var sleepHours: Double?
    var waterIntake: Double?
    var notes: String

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.notes = ""
    }

    var bloodPressureText: String? {
        guard let s = bloodPressureSystolic, let d = bloodPressureDiastolic else { return nil }
        return "\(s)/\(d)"
    }

    var moodEmoji: String {
        switch mood {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "😄"
        default: return "—"
        }
    }
}

enum MoodLevel: Int, CaseIterable {
    case veryBad = 1
    case bad = 2
    case neutral = 3
    case good = 4
    case veryGood = 5

    var label: String {
        switch self {
        case .veryBad: return "แย่มาก"
        case .bad: return "แย่"
        case .neutral: return "ปานกลาง"
        case .good: return "ดี"
        case .veryGood: return "ดีมาก"
        }
    }

    var emoji: String {
        switch self {
        case .veryBad: return "😞"
        case .bad: return "😕"
        case .neutral: return "😐"
        case .good: return "😊"
        case .veryGood: return "😄"
        }
    }
}
