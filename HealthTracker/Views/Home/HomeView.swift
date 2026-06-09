import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Medication.name) private var medications: [Medication]
    @Query(sort: \HealthLog.date, order: .reverse) private var healthLogs: [HealthLog]
    @Query(sort: \ExerciseLog.date, order: .reverse) private var exerciseLogs: [ExerciseLog]
    @Query(sort: \MedicationDose.scheduledTime) private var allDoses: [MedicationDose]

    private var todayDoses: [MedicationDose] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return allDoses.filter { $0.scheduledTime >= today && $0.scheduledTime < tomorrow }
    }

    private var todayExercise: ExerciseLog? {
        let today = Calendar.current.startOfDay(for: Date())
        return exerciseLogs.first { Calendar.current.startOfDay(for: $0.date) == today }
    }

    private var latestHealthLog: HealthLog? { healthLogs.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    greetingHeader
                    todayMedicationSection
                    healthSummarySection
                    exerciseSummarySection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("สุขภาพของฉัน")
        }
    }

    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(Date(), format: .dateTime.day().month(.wide).year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "person.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.blue)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "สวัสดีตอนเช้า"
        case 12..<17: return "สวัสดีตอนบ่าย"
        case 17..<21: return "สวัสดีตอนเย็น"
        default: return "สวัสดีตอนดึก"
        }
    }

    private var todayMedicationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "ยา/วิตามินวันนี้",
                icon: "pill.fill",
                color: .blue
            )

            let pending = todayDoses.filter { $0.isPending }
            let taken = todayDoses.filter { $0.isTaken }

            if todayDoses.isEmpty {
                EmptyStateRow(text: "ไม่มีรายการยาวันนี้", icon: "pill")
            } else {
                HStack {
                    StatBadge(value: "\(taken.count)/\(todayDoses.count)", label: "ทานแล้ว", color: .green)
                    StatBadge(value: "\(pending.count)", label: "รอทาน", color: .orange)
                }

                ForEach(todayDoses.prefix(3)) { dose in
                    DoseRowCompact(dose: dose)
                }

                if todayDoses.count > 3 {
                    Text("และอีก \(todayDoses.count - 3) รายการ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private var healthSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "สุขภาพล่าสุด", icon: "heart.fill", color: .red)

            if let log = latestHealthLog {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    if let w = log.weight {
                        HealthMetricCard(icon: "scalemass.fill", label: "น้ำหนัก", value: String(format: "%.1f", w), unit: "กก.", color: .blue)
                    }
                    if let bp = log.bloodPressureText {
                        HealthMetricCard(icon: "heart.fill", label: "ความดัน", value: bp, unit: "mmHg", color: .red)
                    }
                    if let hr = log.heartRate {
                        HealthMetricCard(icon: "waveform.path.ecg", label: "ชีพจร", value: "\(hr)", unit: "bpm", color: .pink)
                    }
                    if let mood = log.mood {
                        HealthMetricCard(icon: "face.smiling", label: "อารมณ์", value: log.moodEmoji, unit: MoodLevel(rawValue: mood)?.label ?? "", color: .yellow)
                    }
                }

                Text("บันทึกเมื่อ \(log.date, style: .relative)ที่แล้ว")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                EmptyStateRow(text: "ยังไม่มีข้อมูลสุขภาพ", icon: "heart")
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private var exerciseSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "ออกกำลังกายวันนี้", icon: "figure.run", color: .orange)

            if let exercise = todayExercise {
                HStack(spacing: 16) {
                    Image(systemName: exercise.type.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(Color(hex: exercise.type.color) ?? .orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.type.rawValue)
                            .font(.headline)
                        Text(exercise.durationText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let km = exercise.distanceKm {
                        VStack {
                            Text(String(format: "%.2f", km))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("กม.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            } else {
                EmptyStateRow(text: "ยังไม่มีการออกกำลังกายวันนี้", icon: "figure.run")
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
        }
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct DoseRowCompact: View {
    @Environment(\.modelContext) private var context
    let dose: MedicationDose

    var body: some View {
        HStack {
            Circle()
                .fill(dose.medication?.color ?? .blue)
                .frame(width: 10, height: 10)

            Text(dose.medication?.name ?? "—")
                .font(.subheadline)
            Text(dose.scheduledTime, format: .dateTime.hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            statusView
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusView: some View {
        switch dose.status {
        case .taken:
            Label("ทานแล้ว", systemImage: "checkmark.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.green)
        case .skipped:
            Label("ข้าม", systemImage: "minus.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.gray)
        case .missed:
            Label("พลาด", systemImage: "xmark.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.red)
        case .pending:
            Button {
                dose.status = .taken
                dose.takenTime = Date()
            } label: {
                Text("ทาน")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

struct HealthMetricCard: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct EmptyStateRow: View {
    let text: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 12)
    }
}
