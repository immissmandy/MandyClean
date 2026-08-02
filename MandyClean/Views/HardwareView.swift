import SwiftUI

struct HardwareView: View {
    @ObservedObject var viewModel: HardwareViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header
                batteryCard
                systemDiagnostics
                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Akku- & Hardware-Diagnose")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Real-time battery health, thermal status, and hardware specs")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }

            Spacer()

            MandyPrimaryButton("Refresh Data", icon: "arrow.clockwise") {
                viewModel.loadInfo()
            }
        }
    }

    private var batteryCard: some View {
        GlassCard(bg: Color.neoCardBackground(colorScheme)) {
            VStack(alignment: .leading, spacing: MandySpacing.md) {
                HStack {
                    Label("Battery & Power Status", systemImage: "battery.100")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))
                    Spacer()
                    if viewModel.info.isCharging {
                        Text("CHARGING")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.neoLime))
                            .overlay(Capsule().stroke(Color.black, lineWidth: 1.5))
                    }
                }

                Rectangle()
                    .fill(Color.neoBorder(colorScheme))
                    .frame(height: 2)

                HStack(spacing: MandySpacing.xxl) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewModel.info.batteryPercentage)%")
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(Color.neoLime)

                        Text("Current Capacity")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.neoSecondaryText(colorScheme))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        diagRow("Power Source", viewModel.info.powerSource)
                        diagRow("Charging State", viewModel.info.isCharging ? "Connected to AC" : "Discharging")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(MandySpacing.lg)
        }
    }

    private var systemDiagnostics: some View {
        HStack(spacing: MandySpacing.lg) {
            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(alignment: .leading, spacing: MandySpacing.md) {
                    Label("Thermal State", systemImage: "thermometer.medium")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Rectangle()
                        .fill(Color.neoBorder(colorScheme))
                        .frame(height: 2)

                    Text(viewModel.info.thermalState)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(Color.neoCyan)

                    Text("System Temperature Status")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                }
                .padding(MandySpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                VStack(alignment: .leading, spacing: MandySpacing.md) {
                    Label("Processor & Cores", systemImage: "cpu")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color.neoPrimaryText(colorScheme))

                    Rectangle()
                        .fill(Color.neoBorder(colorScheme))
                        .frame(height: 2)

                    Text("\(viewModel.info.cpuCores) Cores")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(Color.neoYellow)

                    Text(viewModel.info.cpuName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                }
                .padding(MandySpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func diagRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.neoSecondaryText(colorScheme))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.neoPrimaryText(colorScheme))
        }
    }
}
