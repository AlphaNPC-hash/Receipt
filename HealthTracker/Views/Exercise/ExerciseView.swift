import SwiftUI
import SwiftData

struct ExerciseView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ExerciseLog.date, order: .reverse) private var logs: [ExerciseLog]
    @State private var showAddSheet = false
    @State private var selectedType: ExerciseType? = nil

    private var filteredLogs: [ExerciseLog] {
        guard let type = selectedType else { return logs }
        return logs.filter { $0.type == type }
    }

    private var weeklyStats: (totalMinutes: Int, totalKm: Double, sessions: Int) {
        let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let weekLogs = logs.filter { $0.date >= oneWeekAgo }
        let totalMin = weekLogs.reduce(0) { $0 + $1.durationMinutes }
        let totalKm = weekLogs.compactMap(\.distanceKm).reduce(0, +)
        return (totalMin, totalKm, weekLogs.count)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    WeeklyStatsCard(stats: weeklyStats)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "ทั้งหมด", isSelected: selectedType == nil) {
                                selectedType = nil
                            }
                            ForEach(ExerciseType.allCases, id: \.rawValue) { type in
                                FilterChip(
                                    label: type.rawValue,
                                    icon: type.icon,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = selectedType == type ? nil : type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                if filteredLogs.isEmpty {
                    ContentUnavailableView(
                        "ยังไม่มีข้อมูลการออกกำลังกาย",
                        systemImage: "figure.run",
                        description: Text("กดปุ่ม + เพื่อบันทึก")
                    )
                } else {
                    ForEach(filteredLogs) { log in
                        ExerciseRowView(log: log)
                    }
                    .onDelete { offsets in
                        let source = filteredLogs
                        for index in offsets {
                            context.delete(source[index])
                        }
                    }
                }
            }
            .navigationTitle("ออกกำลังกาย")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddExerciseView()
            }
        }
    }
}

struct WeeklyStatsCard: View {
    let stats: (totalMinutes: Int, totalKm: Double, sessions: Int)

    private var hoursText: String {
        let h = stats.totalMinutes / 60
        let m = stats.totalMinutes % 60
        if h > 0 { return "\(h) ชม. \(m) น." }
        return "\(m) น."
    }

    var body: some View {
        HStack {
            StatColumn(value: "\(stats.sessions)", label: "ครั้ง", icon: "flame.fill", color: .orange)
            Divider()
            StatColumn(value: hoursText, label: "เวลารวม", icon: "clock.fill", color: .blue)
            Divider()
            StatColumn(
                value: String(format: "%.1f", stats.totalKm),
                label: "กม.",
                icon: "map.fill",
                color: .green
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct StatColumn: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseRowView: View {
    let log: ExerciseLog

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: log.type.color) ?? .orange)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: log.type.icon)
                        .foregroundStyle(.white)
                        .font(.system(size: 22))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(log.type.rawValue)
                    .font(.headline)
                Text(log.date, format: .dateTime.day().month().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(log.durationText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                if let km = log.distanceKm {
                    Text(String(format: "%.2f กม.", km))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let pace = log.paceText {
                    Text(pace)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct FilterChip: View {
    let label: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(label)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
