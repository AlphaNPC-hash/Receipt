import SwiftUI
import SwiftData

struct AddMedicationView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var medication: Medication?

    @State private var name = ""
    @State private var dosage = ""
    @State private var unit = "mg"
    @State private var selectedColor = "#4A90E2"
    @State private var notes = ""
    @State private var scheduledTimes: [Date] = []
    @State private var showTimePicker = false
    @State private var newTime = Date()

    let colorOptions = [
        "#4A90E2", "#7ED321", "#F5A623", "#D0021B",
        "#9013FE", "#50E3C2", "#B8E986", "#FF6B6B"
    ]

    init(medication: Medication? = nil) {
        self.medication = medication
        if let med = medication {
            _name = State(initialValue: med.name)
            _dosage = State(initialValue: med.dosage)
            _unit = State(initialValue: med.unit)
            _selectedColor = State(initialValue: med.colorHex)
            _notes = State(initialValue: med.notes)
            _scheduledTimes = State(initialValue: med.scheduledTimes)
        }
    }

    var isEditing: Bool { medication != nil }
    var isValid: Bool { !name.isEmpty && !dosage.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("รายละเอียด") {
                    TextField("ชื่อยา / วิตามิน", text: $name)
                    HStack {
                        TextField("ขนาด", text: $dosage)
                            .keyboardType(.decimalPad)
                        Picker("หน่วย", selection: $unit) {
                            ForEach(MedicationUnit.allCases, id: \.rawValue) { u in
                                Text(u.rawValue).tag(u.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    TextField("หมายเหตุ", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("สีแสดง") {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 8), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex) ?? .blue)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    if hex == selectedColor {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                                .onTapGesture { selectedColor = hex }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("เวลาที่ต้องทาน") {
                    ForEach(scheduledTimes.sorted(), id: \.self) { time in
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.blue)
                            Text(time, format: .dateTime.hour().minute())
                            Spacer()
                            Button(role: .destructive) {
                                scheduledTimes.removeAll { $0 == time }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                        }
                    }

                    if showTimePicker {
                        DatePicker("เลือกเวลา", selection: $newTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                        Button("เพิ่มเวลานี้") {
                            scheduledTimes.append(newTime)
                            showTimePicker = false
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Button {
                        showTimePicker.toggle()
                    } label: {
                        Label("เพิ่มเวลา", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle(isEditing ? "แก้ไขยา" : "เพิ่มยา / วิตามิน")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("บันทึก") { save() }
                        .disabled(!isValid)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        if let med = medication {
            med.name = name
            med.dosage = dosage
            med.unit = unit
            med.colorHex = selectedColor
            med.notes = notes
            med.scheduledTimes = scheduledTimes
            NotificationManager.shared.scheduleMedicationNotifications(for: med)
        } else {
            let med = Medication(
                name: name,
                dosage: dosage,
                unit: unit,
                colorHex: selectedColor,
                notes: notes,
                scheduledTimes: scheduledTimes
            )
            context.insert(med)
            NotificationManager.shared.scheduleMedicationNotifications(for: med)
            generateTodayDoses(for: med)
        }
        dismiss()
    }

    private func generateTodayDoses(for medication: Medication) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for time in medication.scheduledTimes {
            let components = calendar.dateComponents([.hour, .minute], from: time)
            if let doseTime = calendar.date(bySettingHour: components.hour ?? 0,
                                             minute: components.minute ?? 0,
                                             second: 0, of: today) {
                let dose = MedicationDose(scheduledTime: doseTime, medication: medication)
                context.insert(dose)
            }
        }
    }
}
