import SwiftUI
import SwiftData

@main
struct HealthTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    Medication.self,
                    MedicationDose.self,
                    HealthLog.self,
                    ExerciseLog.self
                ])
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
