import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("หน้าหลัก", systemImage: "house.fill")
                }
                .tag(0)

            MedicationListView()
                .tabItem {
                    Label("ยา/วิตามิน", systemImage: "pill.fill")
                }
                .tag(1)

            HealthLogView()
                .tabItem {
                    Label("สุขภาพ", systemImage: "heart.fill")
                }
                .tag(2)

            ExerciseView()
                .tabItem {
                    Label("ออกกำลังกาย", systemImage: "figure.run")
                }
                .tag(3)

            StatisticsView()
                .tabItem {
                    Label("สถิติ", systemImage: "chart.bar.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}
