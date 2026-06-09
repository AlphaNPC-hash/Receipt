import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query(sort: \HealthLog.date, order: .reverse) private var healthLogs: [HealthLog]
    @Query(sort: \ExerciseLog.date, order: .reverse) private var exerciseLogs: [ExerciseLog]
    @Query private var allDoses: [MedicationDose]

    @State private var selectedPeriod: StatPeriod = .week

    private var periodDays: Int { selectedPeriod.days }

    private var cutoffDate: Date {
        Calendar.current.date(byAdding: .day, value: -periodDays, to: Date())!
    }

    private var recentHealthLogs: [HealthLog] {
        healthLogs.filter { $0.date >= cutoffDate }
    }

    private var recentExerciseLogs: [ExerciseLog] {
        exerciseLogs.filter { $0.date >= cutoffDate }
    }

    private var recentDoses: [MedicationDose] {
        allDoses.filter { $0.scheduledTime >= cutoffDate }
    }

    private var adherenceRate: Double {
        guard !recentDoses.isEmpty else { return 0 }
        let taken = recentDoses.filter { $0.isTaken }.count
        return Double(taken) / Double(recentDoses.count) * 100
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    periodPicker

                    medicationAdherenceCard
                    weightChartCard
                    exerciseSummaryCard
                    exerciseTypeBreakdown
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("สถิติ")
        }
    }

    private var periodPicker: some View {
        Picker("ช่วงเวลา", selection: $selectedPeriod) {
            ForEach(StatPeriod.allCases, id: \.self) { period in
                Text(period.label).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private var medicationAdherenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "การทานยา", icon: "pill.fill", color: .blue)

            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)
                        .frame(width: 90, height: 90)
                    Circle()
                        .trim(from: 0, to: adherenceRate / 100)
                        .stroke(adherenceColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 90, height: 90)
                        .animation(.easeOut, value: adherenceRate)
                    Text(String(format: "%.0f%%", adherenceRate))
                        .font(.headline)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 8) {
                    AdherenceStat(
                        label: "ทานแล้ว",
                        count: recentDoses.filter { $0.isTaken }.count,
                        color: .green
                    )
                    AdherenceStat(
                        label: "ข้าม",
                        count: recentDoses.filter { $0.isSkipped }.count,
                        color: .gray
                    )
                    AdherenceStat(
                        label: "พลาด",
                        count: recentDoses.filter { $0.isMissed }.count,
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private var adherenceColor: Color {
        switch adherenceRate {
        case 80...100: return .green
        case 60..<80: return .yellow
        default: return .red
        }
    }

    private var weightChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "น้ำหนัก", icon: "scalemass.fill", color: .purple)

            let weightData = recentHealthLogs
                .filter { $0.weight != nil }
                .sorted { $0.date < $1.date }

            if weightData.isEmpty {
                EmptyStateRow(text: "ยังไม่มีข้อมูลน้ำหนัก", icon: "scalemass")
            } else {
                Chart(weightData, id: \.id) { log in
                    LineMark(
                        x: .value("วันที่", log.date),
                        y: .value("น้ำหนัก", log.weight!)
                    )
                    .foregroundStyle(.purple)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("วันที่", log.date),
                        y: .value("น้ำหนัก", log.weight!)
                    )
                    .foregroundStyle(.purple)
                }
                .frame(height: 160)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private var exerciseSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "การออกกำลังกาย", icon: "figure.run", color: .orange)

            let totalMin = recentExerciseLogs.reduce(0) { $0 + $1.durationMinutes }
            let totalKm = recentExerciseLogs.compactMap(\.distanceKm).reduce(0, +)
            let totalCal = recentExerciseLogs.compactMap(\.caloriesBurned).reduce(0, +)

            HStack {
                ExerciseStat(value: "\(recentExerciseLogs.count)", label: "ครั้ง", icon: "flame.fill", color: .orange)
                ExerciseStat(
                    value: totalMin >= 60 ? "\(totalMin/60)ชม.\(totalMin%60)น." : "\(totalMin)น.",
                    label: "เวลารวม",
                    icon: "clock.fill",
                    color: .blue
                )
                ExerciseStat(value: String(format: "%.1f", totalKm), label: "กม.", icon: "map.fill", color: .green)
                ExerciseStat(value: String(format: "%.0f", totalCal), label: "kcal", icon: "bolt.fill", color: .yellow)
            }

            if !recentExerciseLogs.isEmpty {
                Chart(recentExerciseLogs.sorted { $0.date < $1.date }, id: \.id) { log in
                    BarMark(
                        x: .value("วันที่", log.date, unit: .day),
                        y: .value("นาที", log.durationMinutes)
                    )
                    .foregroundStyle(Color(hex: log.type.color) ?? .orange)
                }
                .frame(height: 120)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private var exerciseTypeBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "ประเภทการออกกำลังกาย", icon: "chart.pie.fill", color: .teal)

            if recentExerciseLogs.isEmpty {
                EmptyStateRow(text: "ยังไม่มีข้อมูล", icon: "figure.run")
            } else {
                let grouped = Dictionary(grouping: recentExerciseLogs, by: \.type)
                ForEach(grouped.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.rawValue) { type in
                    let typeLogs = grouped[type] ?? []
                    let totalMin = typeLogs.reduce(0) { $0 + $1.durationMinutes }
                    let percent = Double(totalMin) / Double(recentExerciseLogs.reduce(0) { $0 + $1.durationMinutes }) * 100

                    HStack {
                        Image(systemName: type.icon)
                            .foregroundStyle(Color(hex: type.color) ?? .orange)
                            .frame(width: 24)
                        Text(type.rawValue)
                            .font(.subheadline)
                        Spacer()
                        Text("\(typeLogs.count) ครั้ง")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.0f%%", percent))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct AdherenceStat: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

struct ExerciseStat: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.caption)
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

enum StatPeriod: CaseIterable {
    case week, month, threeMonths

    var label: String {
        switch self {
        case .week: return "7 วัน"
        case .month: return "30 วัน"
        case .threeMonths: return "90 วัน"
        }
    }

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        }
    }
}
