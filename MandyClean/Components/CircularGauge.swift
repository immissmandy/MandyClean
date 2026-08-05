import SwiftUI

struct CircularGauge: View {
    let value: Double  // 0.0 – 1.0
    let label: String
    let detail: String
    var color: Color = .neoRed
    var size: CGFloat = 130
    var lineWidth: CGFloat = 12

    @Environment(\.colorScheme) var colorScheme
    @State private var animatedValue: Double = 0

    var body: some View {
        ZStack {
            // Track background
            Circle()
                .stroke(Color.neoBorder(colorScheme).opacity(0.12), lineWidth: lineWidth)

            // Progress segment
            Circle()
                .trim(from: 0, to: min(animatedValue, 1.0))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Outer border around track ring
            Circle()
                .stroke(Color.neoBorder(colorScheme), lineWidth: 2)
                .frame(width: size + lineWidth, height: size + lineWidth)

            // Center text container
            VStack(spacing: 2) {
                Text("\(Int(animatedValue * 100))%")
                    .font(.system(size: size * 0.22, weight: .black))
                    .foregroundStyle(Color.neoPrimaryText(colorScheme))

                Text(label)
                    .font(.system(size: size * 0.1, weight: .bold))
                    .foregroundStyle(Color.neoSecondaryText(colorScheme))

                if !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: size * 0.08, weight: .bold))
                        .foregroundStyle(Color.neoSecondaryText(colorScheme))
                }
            }
        }
        .frame(width: size + lineWidth + 4, height: size + lineWidth + 4)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedValue = newValue
            }
        }
    }
}
