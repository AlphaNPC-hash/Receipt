import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Medication.name) private var medications: [Medication]
    @State private var showAddSheet = false
    @State private var selectedMedication: Medication?
    @State private var showTodayOnly = true

    private var activeMedications: [Medication] {
        medications.filter { $0.isActive }
    }

    var body: some View {
        NavigationStack {
            List {
                if activeMedications.isEmpty {
                    ContentUnavailableView(
                        "ยังไม่มีรายการยา",
                        systemImage: "pill",
                        description: Text("กดปุ่ม + เพื่อเพิ่มยาหรือวิตามิน")
                    )
                } else {
                    ForEach(activeMedications) { medication in
                        MedicationRowView(medication: medication)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedMedication = medication
                            }
                    }
                    .onDelete(perform: deleteMedications)
                }
            }
            .navigationTitle("ยา / วิตามิน")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddMedicationView()
            }
            .sheet(item: $selectedMedication) { med in
                AddMedicationView(medication: med)
            }
        }
    }

    private func deleteMedications(at offsets: IndexSet) {
        for index in offsets {
            let med = activeMedications[index]
            NotificationManager.shared.cancelNotifications(for: med.id)
            context.delete(med)
        }
    }
}

struct MedicationRowView: View {
    let medication: Medication

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(medication.color)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "pill.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.headline)
                Text("\(medication.dosage) \(medication.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !medication.scheduledTimes.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(medication.scheduledTimes.sorted(), id: \.self) { time in
                            Text(time, format: .dateTime.hour().minute())
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(medication.color.opacity(0.15))
                                .foregroundStyle(medication.color)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()

            if let next = medication.nextDoseTime {
                VStack(alignment: .trailing) {
                    Text("ถัดไป")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(next, format: .dateTime.hour().minute())
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
