#!/bin/bash
set -e
mkdir -p build/MandyClean.app/Contents/MacOS
mkdir -p build/MandyClean.app/Contents/Resources
mkdir -p build/MandyCleanIntel.app/Contents/MacOS
mkdir -p build/MandyCleanIntel.app/Contents/Resources

echo "1. Compiling macOS 13.0+ Apple Silicon (arm64)..."
xcrun swiftc -emit-executable -parse-as-library -target arm64-apple-macos13.0 \
  -vfsoverlay vfs.yaml -Xcc -ivfsoverlay -Xcc vfs.yaml \
  MandyClean/App/MandyCleanApp.swift MandyClean/ContentView.swift MandyClean/Theme/AppTheme.swift \
  MandyClean/Models/RAMInfo.swift MandyClean/Models/SystemProcess.swift MandyClean/Models/CleanupItem.swift \
  MandyClean/Models/InstalledApp.swift MandyClean/Models/LaunchItem.swift MandyClean/Models/LargeFileItem.swift \
  MandyClean/Models/MetricDataPoint.swift MandyClean/Models/DuplicateGroup.swift MandyClean/Models/PrivacyItem.swift \
  MandyClean/Models/DiskNode.swift MandyClean/Models/HardwareInfo.swift MandyClean/Models/SystemExtensionItem.swift \
  MandyClean/Models/ShredderItem.swift MandyClean/Models/DeveloperItem.swift MandyClean/Models/MaintenanceTask.swift \
  MandyClean/Models/NetworkStats.swift MandyClean/Models/OrganizeItem.swift MandyClean/Models/WidgetDataStore.swift \
  MandyClean/Models/NeoTheme.swift MandyClean/Models/BenchmarkResult.swift MandyClean/Models/LanguagePackItem.swift \
  MandyClean/Services/SystemMonitorService.swift MandyClean/Services/ProcessService.swift MandyClean/Services/CleanupService.swift \
  MandyClean/Services/AppUninstallerService.swift MandyClean/Services/AutostartService.swift MandyClean/Services/LargeFilesService.swift \
  MandyClean/Services/NotificationService.swift MandyClean/Services/AudioService.swift MandyClean/Services/DuplicatesService.swift \
  MandyClean/Services/PrivacyService.swift MandyClean/Services/DiskMapService.swift MandyClean/Services/HardwareService.swift \
  MandyClean/Services/ExtensionsService.swift MandyClean/Services/ShredderService.swift MandyClean/Services/DeveloperCleanService.swift \
  MandyClean/Services/MaintenanceService.swift MandyClean/Services/NetworkService.swift MandyClean/Services/OrganizerService.swift \
  MandyClean/Services/AutoPilotService.swift MandyClean/Services/BenchmarkService.swift MandyClean/Services/LanguageStripperService.swift \
  MandyClean/ViewModels/RAMViewModel.swift MandyClean/ViewModels/CleanupViewModel.swift MandyClean/ViewModels/UninstallerViewModel.swift \
  MandyClean/ViewModels/AutostartViewModel.swift MandyClean/ViewModels/LargeFilesViewModel.swift MandyClean/ViewModels/DuplicatesViewModel.swift \
  MandyClean/ViewModels/PrivacyViewModel.swift MandyClean/ViewModels/DiskMapViewModel.swift MandyClean/ViewModels/HardwareViewModel.swift \
  MandyClean/ViewModels/ExtensionsViewModel.swift MandyClean/ViewModels/ShredderViewModel.swift MandyClean/ViewModels/DeveloperCleanViewModel.swift \
  MandyClean/ViewModels/MaintenanceViewModel.swift MandyClean/ViewModels/NetworkViewModel.swift MandyClean/ViewModels/OrganizerViewModel.swift \
  MandyClean/ViewModels/BenchmarkViewModel.swift MandyClean/ViewModels/LanguageStripperViewModel.swift MandyClean/Views/SidebarView.swift \
  MandyClean/Views/TopBarView.swift MandyClean/Views/DashboardView.swift MandyClean/Views/RAMView.swift MandyClean/Views/CleanupView.swift \
  MandyClean/Views/UninstallerView.swift MandyClean/Views/AutostartView.swift MandyClean/Views/LargeFilesView.swift \
  MandyClean/Views/DuplicatesView.swift MandyClean/Views/PrivacyView.swift MandyClean/Views/DiskMapView.swift MandyClean/Views/HardwareView.swift \
  MandyClean/Views/ExtensionsView.swift MandyClean/Views/ShredderView.swift MandyClean/Views/DeveloperCleanView.swift \
  MandyClean/Views/MaintenanceView.swift MandyClean/Views/NetworkView.swift MandyClean/Views/OrganizerView.swift \
  MandyClean/Views/MandyDesktopWidgetView.swift MandyClean/Views/ThemeCustomizerView.swift MandyClean/Views/BenchmarkView.swift \
  MandyClean/Views/LanguageStripperView.swift MandyClean/Components/GlassCard.swift MandyClean/Components/CircularGauge.swift \
  MandyClean/Components/AnimatedButton.swift \
  -o bin_arm64

echo "2. Compiling macOS 13.0+ Intel (x86_64)..."
xcrun swiftc -emit-executable -parse-as-library -target x86_64-apple-macos13.0 \
  -vfsoverlay vfs.yaml -Xcc -ivfsoverlay -Xcc vfs.yaml \
  MandyClean/App/MandyCleanApp.swift MandyClean/ContentView.swift MandyClean/Theme/AppTheme.swift \
  MandyClean/Models/RAMInfo.swift MandyClean/Models/SystemProcess.swift MandyClean/Models/CleanupItem.swift \
  MandyClean/Models/InstalledApp.swift MandyClean/Models/LaunchItem.swift MandyClean/Models/LargeFileItem.swift \
  MandyClean/Models/MetricDataPoint.swift MandyClean/Models/DuplicateGroup.swift MandyClean/Models/PrivacyItem.swift \
  MandyClean/Models/DiskNode.swift MandyClean/Models/HardwareInfo.swift MandyClean/Models/SystemExtensionItem.swift \
  MandyClean/Models/ShredderItem.swift MandyClean/Models/DeveloperItem.swift MandyClean/Models/MaintenanceTask.swift \
  MandyClean/Models/NetworkStats.swift MandyClean/Models/OrganizeItem.swift MandyClean/Models/WidgetDataStore.swift \
  MandyClean/Models/NeoTheme.swift MandyClean/Models/BenchmarkResult.swift MandyClean/Models/LanguagePackItem.swift \
  MandyClean/Services/SystemMonitorService.swift MandyClean/Services/ProcessService.swift MandyClean/Services/CleanupService.swift \
  MandyClean/Services/AppUninstallerService.swift MandyClean/Services/AutostartService.swift MandyClean/Services/LargeFilesService.swift \
  MandyClean/Services/NotificationService.swift MandyClean/Services/AudioService.swift MandyClean/Services/DuplicatesService.swift \
  MandyClean/Services/PrivacyService.swift MandyClean/Services/DiskMapService.swift MandyClean/Services/HardwareService.swift \
  MandyClean/Services/ExtensionsService.swift MandyClean/Services/ShredderService.swift MandyClean/Services/DeveloperCleanService.swift \
  MandyClean/Services/MaintenanceService.swift MandyClean/Services/NetworkService.swift MandyClean/Services/OrganizerService.swift \
  MandyClean/Services/AutoPilotService.swift MandyClean/Services/BenchmarkService.swift MandyClean/Services/LanguageStripperService.swift \
  MandyClean/ViewModels/RAMViewModel.swift MandyClean/ViewModels/CleanupViewModel.swift MandyClean/ViewModels/UninstallerViewModel.swift \
  MandyClean/ViewModels/AutostartViewModel.swift MandyClean/ViewModels/LargeFilesViewModel.swift MandyClean/ViewModels/DuplicatesViewModel.swift \
  MandyClean/ViewModels/PrivacyViewModel.swift MandyClean/ViewModels/DiskMapViewModel.swift MandyClean/ViewModels/HardwareViewModel.swift \
  MandyClean/ViewModels/ExtensionsViewModel.swift MandyClean/ViewModels/ShredderViewModel.swift MandyClean/ViewModels/DeveloperCleanViewModel.swift \
  MandyClean/ViewModels/MaintenanceViewModel.swift MandyClean/ViewModels/NetworkViewModel.swift MandyClean/ViewModels/OrganizerViewModel.swift \
  MandyClean/ViewModels/BenchmarkViewModel.swift MandyClean/ViewModels/LanguageStripperViewModel.swift MandyClean/Views/SidebarView.swift \
  MandyClean/Views/TopBarView.swift MandyClean/Views/DashboardView.swift MandyClean/Views/RAMView.swift MandyClean/Views/CleanupView.swift \
  MandyClean/Views/UninstallerView.swift MandyClean/Views/AutostartView.swift MandyClean/Views/LargeFilesView.swift \
  MandyClean/Views/DuplicatesView.swift MandyClean/Views/PrivacyView.swift MandyClean/Views/DiskMapView.swift MandyClean/Views/HardwareView.swift \
  MandyClean/Views/ExtensionsView.swift MandyClean/Views/ShredderView.swift MandyClean/Views/DeveloperCleanView.swift \
  MandyClean/Views/MaintenanceView.swift MandyClean/Views/NetworkView.swift MandyClean/Views/OrganizerView.swift \
  MandyClean/Views/MandyDesktopWidgetView.swift MandyClean/Views/ThemeCustomizerView.swift MandyClean/Views/BenchmarkView.swift \
  MandyClean/Views/LanguageStripperView.swift MandyClean/Components/GlassCard.swift MandyClean/Components/CircularGauge.swift \
  MandyClean/Components/AnimatedButton.swift \
  -o bin_x86_64

echo "3. Creating Standalone Intel App (MandyCleanIntel.app)..."
cp bin_x86_64 build/MandyCleanIntel.app/Contents/MacOS/MandyCleanIntel
chmod +x build/MandyCleanIntel.app/Contents/MacOS/MandyCleanIntel

echo "4. Creating Universal 2 App (MandyClean.app)..."
lipo -create bin_arm64 bin_x86_64 -output build/MandyClean.app/Contents/MacOS/MandyClean
chmod +x build/MandyClean.app/Contents/MacOS/MandyClean

echo "MANDYCLEAN_MACOS13_BUILD_SUCCESS"
