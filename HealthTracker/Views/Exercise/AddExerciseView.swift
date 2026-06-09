import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var selectedType: ExerciseType = .running
    @State private var hours = 0
    @State private var minutes = 30
    @State private var distance = ""
    @State private var steps = ""
    @State private var calories = ""
    @State private var averageHeartRate = ""
    @State private var notes = ""

    private var showDistance: Bool {
        [.running, .walking, .indoorWalking, .cycling].contains(selectedType)
    }

    private var showSteps: Bool {
        [.running, .walking, .indoorWalking].contains(selectedType)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("รายละเอียด") {
                    DatePicker("วัน/เวลา", selection: $date)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("ประเภท")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 10) {
                            ForEach(ExerciseType.allCases, id: \.rawValue) { type in
                                ExerciseTypeButton(type: type, isSelected: selectedType == type) {
                                    selectedType = type
                                }
                            }
                        }
                    }
                }

                Section("ระยะเวลา") {
                    HStack(spacing: 20) {
                        Picker("ชั่วโมง", selection: $hours) {
                            ForEach(0..<24) { Text("\($0) ชม.").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()

                        Picker("นาที", selection: $minutes) {
                            ForEach(0..<60) { Text("\($0) น.").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                    .frame(height: 100)
                }

                Section("ข้อมูลเพิ่มเติม") {
                    if showDistance {
                        HStack {
                            Label("ระยะทาง", systemImage: "map.fill")
                            Spacer()
                            TextField("0.00", text: $distance)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("กม.")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if showSteps {
                        HStack {
                            Label("ก้าว", systemImage: "figure.walk")
                            Spacer()
                            TextField("0", text: $steps)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("ก้าว")
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Label("แคลอรี่", systemImage: "flame.fill")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kcal")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("ชีพจรเฉลี่ย", systemImage: "heart.fill")
                        Spacer()
                        TextField("0", text: $averageHeartRate)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("bpm")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("หมายเหตุ") {
                    TextField("บันทึกเพิ่มเติม...", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("บันทึกการออกกำลังกาย")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("บันทึก") { save() }
                        .fontWeight(.semibold)
                        .disabled(hours == 0 && minutes == 0)
                }
            }
        }
    }

    private func save() {
        let log = ExerciseLog(date: date, type: selectedType)
        log.durationMinutes = hours * 60 + minutes
        log.distanceKm = Double(distance)
        log.steps = Int(steps)
        log.caloriesBurned = Double(calories)
        log.averageHeartRate = Int(averageHeartRate)
        log.notes = notes
        context.insert(log)
        dismiss()
    }
}

struct ExerciseTypeButton: View {
    let type: ExerciseType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? .white : (Color(hex: type.color) ?? .orange))
                Text(type.rawValue)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? (Color(hex: type.color) ?? .orange)
                    : Color(.secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
