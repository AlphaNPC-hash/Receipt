import Foundation
import SwiftData

@Model
final class MedicationDose {
    var id: UUID
    var scheduledTime: Date
    var takenTime: Date?
    var status: DoseStatus
    var medication: Medication?

    init(scheduledTime: Date, medication: Medication? = nil) {
        self.id = UUID()
        self.scheduledTime = scheduledTime
        self.takenTime = nil
        self.status = .pending
        self.medication = medication
    }

    var isTaken: Bool { status == .taken }
    var isSkipped: Bool { status == .skipped }
    var isPending: Bool { status == .pending }
    var isMissed: Bool { status == .missed }
}

enum DoseStatus: String, Codable {
    case pending = "รอ"
    case taken = "ทาน"
    case skipped = "ข้าม"
    case missed = "พลาด"
}
