import SwiftUI

struct ContentView: View {
    @State private var selection: NavigationItem = .dashboard

    @StateObject private var ramVM = RAMViewModel()
    @StateObject private var autostartVM = AutostartViewModel()
    @StateObject private var largeFilesVM = LargeFilesViewModel()
    @StateObject private var duplicatesVM = DuplicatesViewModel()
    @StateObject private var privacyVM = PrivacyViewModel()
    @StateObject private var diskMapVM = DiskMapViewModel()
    @StateObject private var hardwareVM = HardwareViewModel()
    @StateObject private var extensionsVM = ExtensionsViewModel()
    @StateObject private var shredderVM = ShredderViewModel()
    @StateObject private var developerVM = DeveloperCleanViewModel()
    @StateObject private var maintenanceVM = MaintenanceViewModel()
    @StateObject private var networkVM = NetworkViewModel()
    @StateObject private var organizerVM = OrganizerViewModel()
    @StateObject private var benchmarkVM = BenchmarkViewModel()
    @StateObject private var languagesVM = LanguageStripperViewModel()
    @StateObject private var cleanupVM = CleanupViewModel()
    @StateObject private var uninstallerVM = UninstallerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Modern Red Neobrutalism Top Navigation Bar
            TopBarView(selection: $selection)

            // Main Full-Width Content Area
            ZStack {
                switch selection {
                case .dashboard:
                    DashboardView()
                case .ram:
                    RAMView(viewModel: ramVM)
                case .autostart:
                    AutostartView(viewModel: autostartVM)
                case .largeFiles:
                    LargeFilesView(viewModel: largeFilesVM)
                case .duplicates:
                    DuplicatesView(viewModel: duplicatesVM)
                case .privacy:
                    PrivacyView(viewModel: privacyVM)
                case .diskMap:
                    DiskMapView(viewModel: diskMapVM)
                case .hardware:
                    HardwareView(viewModel: hardwareVM)
                case .extensions:
                    ExtensionsView(viewModel: extensionsVM)
                case .shredder:
                    ShredderView(viewModel: shredderVM)
                case .developer:
                    DeveloperCleanView(viewModel: developerVM)
                case .maintenance:
                    MaintenanceView(viewModel: maintenanceVM)
                case .network:
                    NetworkView(viewModel: networkVM)
                case .organizer:
                    OrganizerView(viewModel: organizerVM)
                case .theme:
                    ThemeCustomizerView()
                case .benchmark:
                    BenchmarkView(viewModel: benchmarkVM)
                case .languages:
                    LanguageStripperView(viewModel: languagesVM)
                case .cleanup:
                    CleanupView(viewModel: cleanupVM)
                case .uninstaller:
                    UninstallerView(viewModel: uninstallerVM)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 980, minHeight: 660)
    }
}
