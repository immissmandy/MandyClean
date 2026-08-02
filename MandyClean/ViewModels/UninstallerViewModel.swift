import Foundation

class UninstallerViewModel: ObservableObject {
    @Published var apps: [InstalledApp] = []
    @Published var selectedApp: InstalledApp?
    @Published var isLoading = false
    @Published var isUninstalling = false
    @Published var searchText = ""
    @Published var uninstallResult: String?

    private let service = AppUninstallerService()

    var filteredApps: [InstalledApp] {
        if searchText.isEmpty { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    init() {
        loadApps()
    }

    func loadApps() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var apps = self.service.getInstalledApps()

            for i in apps.indices {
                apps[i].appSize = self.service.calculateAppSize(at: apps[i].path)
            }

            DispatchQueue.main.async {
                self.apps = apps
                self.isLoading = false
            }
        }
    }

    func selectApp(_ app: InstalledApp) {
        var mutableApp = app
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            mutableApp.relatedFiles = self.service.findRelatedFiles(for: app)
            DispatchQueue.main.async {
                self.selectedApp = mutableApp
            }
        }
    }

    func toggleRelatedFile(id: UUID) {
        guard var app = selectedApp,
            let index = app.relatedFiles.firstIndex(where: { $0.id == id })
        else { return }
        app.relatedFiles[index].isSelected.toggle()
        selectedApp = app
    }

    func uninstallSelected() {
        guard let app = selectedApp else { return }
        isUninstalling = true
        uninstallResult = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let success = self.service.uninstallApp(app, removeRelatedFiles: true)
            DispatchQueue.main.async {
                self.isUninstalling = false
                if success {
                    self.uninstallResult = "\(app.name) moved to Trash"
                    self.selectedApp = nil
                    self.loadApps()
                } else {
                    self.uninstallResult = "Failed to uninstall \(app.name)"
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.uninstallResult = nil
                }
            }
        }
    }
}
