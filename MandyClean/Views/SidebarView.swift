import SwiftUI

enum NavigationCategory: String, CaseIterable {
    case overview = "ÜBERSICHT & SYSTEM"
    case cleanup = "REINIGUNG & SPEICHER"
    case tools = "WERKZEUGE & WARTUNG"
}

enum NavigationItem: String, CaseIterable, Identifiable {
    // Overview
    case dashboard = "Dashboard"
    case ram = "RAM Monitor"
    case diskMap = "Speicher-Map"
    case hardware = "Hardware Diagnose"
    case network = "Netzwerk Monitor"
    case benchmark = "Performance Test"

    // Cleanup
    case cleanup = "System Cleanup"
    case largeFiles = "Large Files"
    case duplicates = "Duplicate Finder"
    case developer = "Developer Suite"
    case languages = "Language Stripper"
    case shredder = "Dateivernichter"

    // Tools
    case autostart = "Autostart Manager"
    case uninstaller = "App Uninstaller"
    case extensions = "Extensions Manager"
    case privacy = "Privacy Cleaner"
    case maintenance = "System-Wartung"
    case organizer = "Auto-Organiser"
    case theme = "Theme Customizer"

    var id: String { rawValue }

    var category: NavigationCategory {
        switch self {
        case .dashboard, .ram, .diskMap, .hardware, .network, .benchmark:
            return .overview
        case .cleanup, .largeFiles, .duplicates, .developer, .languages, .shredder:
            return .cleanup
        case .autostart, .uninstaller, .extensions, .privacy, .maintenance, .organizer, .theme:
            return .tools
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.bottom.50percent"
        case .ram: return "memorychip"
        case .diskMap: return "square.grid.3x3.fill"
        case .hardware: return "cpu"
        case .network: return "network"
        case .benchmark: return "speedometer"
        case .cleanup: return "sparkles"
        case .largeFiles: return "folder.badge.plus"
        case .duplicates: return "doc.on.doc"
        case .developer: return "hammer.fill"
        case .languages: return "globe"
        case .shredder: return "trash.slash.fill"
        case .autostart: return "arrow.triangle.2.circlepath"
        case .uninstaller: return "xmark.app"
        case .extensions: return "puzzlepiece.fill"
        case .privacy: return "hand.raised.fill"
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .organizer: return "folder.badge.gearshape"
        case .theme: return "paintpalette.fill"
        }
    }
}

struct SidebarView: View {
    @Binding var selection: NavigationItem
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // App Title Badge
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: MandyRadius.micro)
                        .fill(Color.neoYellow)
                        .frame(width: 30, height: 30)
                        .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.neoBorder(colorScheme), lineWidth: 2))
                    Image(systemName: "sparkles")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(.black)
                }

                Text("MandyClean")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.neoBorder(colorScheme))
                .frame(height: 2)
                .padding(.horizontal, 14)

            // Categorized Navigation Items
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(NavigationCategory.allCases, id: \.rawValue) { cat in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cat.rawValue)
                                .font(.system(size: 9.5, weight: .black))
                                .foregroundStyle(Color.neoSecondaryText(colorScheme))
                                .padding(.horizontal, 10)
                                .padding(.top, 4)

                            ForEach(NavigationItem.allCases.filter { $0.category == cat }) { item in
                                SidebarRow(
                                    item: item,
                                    isSelected: selection == item
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                        selection = item
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 6)
                .padding(.horizontal, 10)
                .padding(.bottom, 12)
            }

            Spacer()

            // Version Tag
            HStack {
                Text("v1.0.0 MANDY PRO")
                    .font(.system(size: 9.5, weight: .black))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: MandyRadius.micro)
                                .fill(Color.neoShadowColor(colorScheme))
                                .offset(x: 2, y: 2)
                            RoundedRectangle(cornerRadius: MandyRadius.micro)
                                .fill(Color.neoLime)
                        }
                    )
                    .overlay(RoundedRectangle(cornerRadius: MandyRadius.micro).stroke(Color.neoBorder(colorScheme), lineWidth: 1.5))
            }
            .padding(.bottom, 10)
        }
        .frame(minWidth: 230)
        .background(Color.neoBackground(colorScheme))
        .overlay(
            Rectangle()
                .fill(Color.neoBorder(colorScheme))
                .frame(width: 2),
            alignment: .trailing
        )
    }
}

struct SidebarRow: View {
    let item: NavigationItem
    let isSelected: Bool

    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.icon)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(isSelected ? .black : Color.neoPrimaryText(colorScheme))
                .frame(width: 18)

            Text(item.rawValue)
                .font(.system(size: 12, weight: isSelected ? .black : .bold))
                .foregroundStyle(isSelected ? .black : Color.neoPrimaryText(colorScheme))

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5.5)
        .background(
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(Color.neoShadowColor(colorScheme))
                        .offset(x: 2, y: 2)

                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(Color.neoYellow)
                } else if isHovered {
                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .fill(Color.neoCyan.opacity(0.2))
                }
            }
        )
        .overlay(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .stroke(Color.neoBorder(colorScheme), lineWidth: 2)
                } else if isHovered {
                    RoundedRectangle(cornerRadius: MandyRadius.standard)
                        .stroke(Color.neoBorder(colorScheme), lineWidth: 1.5)
                }
            }
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .animation(.spring(response: 0.15, dampingFraction: 0.7), value: isHovered)
    }
}
