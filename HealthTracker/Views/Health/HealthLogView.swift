import SwiftUI
import SwiftData

struct HealthLogView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \HealthLog.date, order: .reverse) private var logs: [HealthLog]
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "ยังไม่มีข้อมูลสุขภาพ",
                        systemImage: "heart.text.square",
                        description: Text("กดปุ่ม + เพื่อบันทึกข้อมูลสุขภาพ")
                    )
                } else {
                    ForEach(logs) { log in
                        HealthLogRow(log: log)
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            context.delete(logs[index])
                        }
                    }
                }
            }
            .navigationTitle("บันทึกสุขภาพ")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddHealthLogView()
            }
        }
    }
}

struct HealthLogRow: View {
    let log: HealthLog

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(log.date, format: .dateTime.day().month().year())
                    .font(.headline)
                Spacer()
                Text(log.moodEmoji)
                    .font(.title2)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                if let w = log.weight {
                    MetricPill(icon: "scalemass", label: "น้ำหนัก", value: String(format: "%.1f กก.", w))
                }
                if let bp = log.bloodPressureText {
                    MetricPill(icon: "heart", label: "ความดัน", value: "\(bp) mmHg")
                }
                if let hr = log.heartRate {
                    MetricPill(icon: "waveform.path.ecg", label: "ชีพจร", value: "\(hr) bpm")
                }
                if let bs = log.bloodSugar {
                    MetricPill(icon: "drop", label: "น้ำตาล", value: String(format: "%.0f mg/dL", bs))
                }
                if let sleep = log.sleepHours {
                    MetricPill(icon: "moon.zzz", label: "นอน", value: String(format: "%.1f ชม.", sleep))
                }
                if let water = log.waterIntake {
                    MetricPill(icon: "drop.fill", label: "น้ำ", value: String(format: "%.1f ล.", water))
                }
            }

            if !log.notes.isEmpty {
                Text(log.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MetricPill: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}
