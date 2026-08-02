import SwiftUI

enum WidgetFamilySize {
    case small
    case medium
    case large
}

struct MandyDesktopWidgetView: View {
    let snapshot: WidgetMetricSnapshot
    let family: WidgetFamilySize

    var body: some View {
        switch family {
        case .small:
            smallWidget
        case .medium:
            mediumWidget
        case .large:
            largeWidget
        }
    }

    // MARK: - Small Widget (2x2)

    private var smallWidget: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.black)
                Text("MandyClean")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.black)
                Spacer()
            }

            Spacer()

            Text(snapshot.ramPercentFormatted)
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.black)

            Text("RAM USAGE")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.black.opacity(0.8))

            Spacer()
        }
        .padding(12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .offset(x: 3, y: 3)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.neoYellow)
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 2))
    }

    // MARK: - Medium Widget (4x2)

    private var mediumWidget: some View {
        HStack(spacing: 12) {
            smallWidget
                .frame(width: 140)

            VStack(alignment: .leading, spacing: 8) {
                widgetStatRow("CPU Load", snapshot.cpuPercentFormatted, .neoCyan)
                widgetStatRow("Free Disk", snapshot.diskFreeFormatted, .neoLime)
                widgetStatRow("Download", snapshot.downloadFormatted, .neoPink)
            }
            .padding(10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black)
                        .offset(x: 3, y: 3)
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black, lineWidth: 2))
        }
    }

    // MARK: - Large Widget (4x4)

    private var largeWidget: some View {
        VStack(spacing: 12) {
            mediumWidget

            VStack(alignment: .leading, spacing: 6) {
                Text("QUICK SYSTEM ACTIONS")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.black)

                HStack(spacing: 8) {
                    widgetActionButton("Clean RAM", icon: "memorychip", color: .neoYellow)
                    widgetActionButton("Flush DNS", icon: "network", color: .neoCyan)
                }
            }
            .padding(10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black)
                        .offset(x: 3, y: 3)
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black, lineWidth: 2))
        }
    }

    private func widgetStatRow(_ label: String, _ val: String, _ badgeColor: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.black)
            Spacer()
            Text(val)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.black)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(badgeColor))
                .overlay(Capsule().stroke(Color.black, lineWidth: 1))
        }
    }

    private func widgetActionButton(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .black))
            Text(title)
                .font(.system(size: 11, weight: .black))
        }
        .foregroundColor(.black)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 8).fill(color))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1.5))
    }
}
