import SwiftUI

struct MaintenanceView: View {
    @ObservedObject var viewModel: MaintenanceViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: MandySpacing.xl) {
                header
                taskList
                Spacer(minLength: MandySpacing.xl)
            }
            .padding(MandySpacing.xl)
        }
        .background(Color.neoBackground(colorScheme))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("1-Klick System-Wartung")
                    .mandySectionHeading()
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text("Execute macOS system maintenance scripts & flush caches")
                    .mandyBody()
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))
            }
            Spacer()
        }
    }

    private var taskList: some View {
        VStack(spacing: MandySpacing.lg) {
            ForEach(viewModel.tasks) { task in
                GlassCard(bg: Color.neoCardBackground(colorScheme)) {
                    HStack(spacing: MandySpacing.lg) {
                        Image(systemName: task.icon)
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(Color.neoPrimaryText(colorScheme))
                            .frame(width: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.name)
                                .font(.system(size: 16, weight: .black))
                                .foregroundStyle(Color.neoPrimaryText(colorScheme))
                            Text(task.description)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.neoSecondaryText(colorScheme))
                        }

                        Spacer()

                        if task.isExecuting {
                            ProgressView()
                                .scaleEffect(0.9)
                        } else if let success = task.isSuccess {
                            HStack(spacing: 6) {
                                Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(success ? Color.neoLime : Color.neoPink)
                                Text(success ? "Done" : "Failed")
                                    .font(.system(size: 12, weight: .black))
                            }
                        } else {
                            MandyPrimaryButton("Run Task", icon: "play.fill") {
                                viewModel.executeTask(task)
                            }
                        }
                    }
                    .padding(MandySpacing.lg)
                }
            }
        }
    }
}
