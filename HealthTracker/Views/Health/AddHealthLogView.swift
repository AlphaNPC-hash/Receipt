import SwiftUI
import SwiftData

struct AddHealthLogView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var weight = ""
    @State private var systolic = ""
    @State private var diastolic = ""
    @State private var heartRate = ""
    @State private var bloodSugar = ""
    @State private var mood: Int = 3
    @State private var sleepHours = ""
    @State private var waterIntake = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("วันที่") {
                    DatePicker("วันที่", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                Section("การวัดร่างกาย") {
                    HStack {
                        Label("น้ำหนัก", systemImage: "scalemass.fill")
                        Spacer()
                        TextField("0.0", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("กก.")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("ความดันโลหิต", systemImage: "heart.fill")
                        HStack {
                            TextField("SYS", text: $systolic)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .padding(8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text("/")
                                .font(.title2)
                                .foregroundStyle(.secondary)

                            TextField("DIA", text: $diastolic)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .padding(8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text("mmHg")
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Label("ชีพจร", systemImage: "waveform.path.ecg")
                        Spacer()
                        TextField("0", text: $heartRate)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("bpm")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("น้ำตาลในเลือด", systemImage: "drop.fill")
                        Spacer()
                        TextField("0", text: $bloodSugar)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("mg/dL")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("ความเป็นอยู่") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("อารมณ์วันนี้", systemImage: "face.smiling")
                        HStack {
                            ForEach(MoodLevel.allCases, id: \.rawValue) { level in
                                Button {
                                    mood = level.rawValue
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(level.emoji)
                                            .font(.system(size: 28))
                                        Text(level.label)
                                            .font(.caption2)
                                            .foregroundStyle(mood == level.rawValue ? .primary : .secondary)
                                    }
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                                    .background(mood == level.rawValue ? Color.yellow.opacity(0.2) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    HStack {
                        Label("ชั่วโมงนอน", systemImage: "moon.zzz.fill")
                        Spacer()
                        TextField("0.0", text: $sleepHours)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("ชม.")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("น้ำที่ดื่ม", systemImage: "drop.fill")
                        Spacer()
                        TextField("0.0", text: $waterIntake)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("ลิตร")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("หมายเหตุ") {
                    TextField("บันทึกเพิ่มเติม...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("บันทึกสุขภาพ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("ยกเลิก") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("บันทึก") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        let log = HealthLog(date: date)
        log.weight = Double(weight)
        log.bloodPressureSystolic = Int(systolic)
        log.bloodPressureDiastolic = Int(diastolic)
        log.heartRate = Int(heartRate)
        log.bloodSugar = Double(bloodSugar)
        log.mood = mood
        log.sleepHours = Double(sleepHours)
        log.waterIntake = Double(waterIntake)
        log.notes = notes
        context.insert(log)
        dismiss()
    }
}
