import Foundation
import SwiftData

@Model
final class ExerciseLog {
    var id: UUID
    var date: Date
    var type: ExerciseType
    var durationMinutes: Int
    var distanceKm: Double?
    var steps: Int?
    var caloriesBurned: Double?
    var averageHeartRate: Int?
    var notes: String

    init(date: Date = Date(), type: ExerciseType = .running) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.durationMinutes = 0
        self.notes = ""
    }

    var durationText: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return "\(hours) ชม. \(minutes) น."
        }
        return "\(minutes) นาที"
    }

    var paceText: String? {
        guard let km = distanceKm, km > 0, durationMinutes > 0 else { return nil }
        let paceMinPerKm = Double(durationMinutes) / km
        let paceMin = Int(paceMinPerKm)
        let paceSec = Int((paceMinPerKm - Double(paceMin)) * 60)
        return "\(paceMin):\(String(format: "%02d", paceSec)) น./กม."
    }
}

enum ExerciseType: String, Codable, CaseIterable {
    case running = "วิ่ง"
    case indoorWalking = "เดินในร่ม"
    case walking = "เดิน"
    case cycling = "ปั่นจักรยาน"
    case swimming = "ว่ายน้ำ"
    case yoga = "โยคะ"
    case hiit = "HIIT"
    case gym = "ยิม"
    case other = "อื่นๆ"

    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .indoorWalking: return "figure.walk"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .yoga: return "figure.yoga"
        case .hiit: return "figure.highintensity.intervaltraining"
        case .gym: return "dumbbell.fill"
        case .other: return "figure.mixed.cardio"
        }
    }

    var color: String {
        switch self {
        case .running: return "#FF6B35"
        case .indoorWalking: return "#4ECDC4"
        case .walking: return "#45B7D1"
        case .cycling: return "#96CEB4"
        case .swimming: return "#74B9FF"
        case .yoga: return "#A29BFE"
        case .hiit: return "#FD79A8"
        case .gym: return "#6C5CE7"
        case .other: return "#FDCB6E"
        }
    }
}
