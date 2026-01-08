//
//  SubscriptionSummaryView.swift
//  SubzilloChart
//

import SwiftUI

// -------------------------------------------------
// MARK: - Model
// -------------------------------------------------
//struct SubscriptionData: Identifiable {
//    let id = UUID()
//    let title: String
//    let amount: Double
//    let color: Color
//}

// -------------------------------------------------
// MARK: - Donut Slice Shape
// -------------------------------------------------


struct DonutSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var thickness: CGFloat

    // 🔥 THIS ENABLES ANIMATION OF ANGLES
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.degrees, endAngle.degrees) }
        set {
            startAngle = .degrees(newValue.first)
            endAngle = .degrees(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius - thickness

        var p = Path()

        p.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        p.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )

        p.closeSubpath()
        return p
    }
}


// -------------------------------------------------
// MARK: - ViewModels
// -------------------------------------------------
class DonutChartViewModel: ObservableObject {
    @Published var progress: CGFloat = 0.0
}

class SliceAnimationModel: ObservableObject {
    @Published var progresses: [CGFloat]

    init(count: Int) {
        self.progresses = Array(repeating: 0, count: count)
    }
}

// -------------------------------------------------
// MARK: - Actual Android-accurate Donut Chart
// -------------------------------------------------

struct DonutChartView: View {

    var data: [SubscriptionData]
    @State private var progresses: [CGFloat]

    init(data: [SubscriptionData]) {
        self.data = data
        _progresses = State(initialValue: Array(repeating: 0, count: data.count))
    }

    private var totalAmount: Double {
      data.compactMap { $0.amount }.reduce(0, +)
    }

    private var sliceAngles: [(start: Angle, end: Angle, sweep: Double)] {
        var result: [(Angle, Angle, Double)] = []
        var current = Angle(degrees: -90)

        for item in data {
            let value = item.amount ?? 0
            let percent = totalAmount == 0 ? 0 : value / totalAmount
            let sweep = 360 * percent
            let end = current + .degrees(sweep)
            result.append((current, end, sweep))
            current = end
        }
        return result
    }

    var body: some View {
        ZStack {
            GeometryReader { _ in
                let thickness: CGFloat = 37

                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let s = sliceAngles[index]
                    let animatedEnd = s.start + .degrees(s.sweep * progresses[index])

                    DonutSlice(
                        startAngle: s.start,
                        endAngle: animatedEnd,
                        thickness: thickness
                    )
//                    .glossyFill(color: item.color)
                    .glossyFill(color: item.uiColor)
                }
            }

            // center text
            VStack(spacing: 4) {
                Text("\(data.count)")
                    .font(.appBold(32)) // Matches 16 bold
                    .foregroundColor(.blueMain700) // Blue color

                Text("Subscriptions")
                    .foregroundColor(.neutral500)
                    .font(.appMedium(14))

                Text("$\(String(format: "%.2f", totalAmount))")
                    .font(.appBold(24)) // $124.99
                    .foregroundColor(.blueMain700)
            }
        }
        .frame(height: 220) // Adjusted height
        .onAppear { animateSequentially() }
    }

    private func animateSequentially() {
        for i in progresses.indices {
            let delay = Double(i) * 0.25  // 0.25 sec between slices
            withAnimation(.easeOut(duration: 1).delay(delay)) {
                progresses[i] = 1
            }
        }
    }
}



// -------------------------------------------------
// MARK: - Inner Shadow (Android-accurate)
// -------------------------------------------------
struct InnerRingShadow: ViewModifier {
    let color: Color
    let blur: CGFloat
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
                    .blur(radius: blur)
                    .offset(x: 0, y: offset)
                    .mask(Circle())
            )
    }
}

extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}

// -------------------------------------------------
// MARK: - Legend Item
// -------------------------------------------------
struct LegendItemView: View {
    let item: SubscriptionData

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Circle()
                .fill(item.uiColor)
                .frame(width: 12, height: 12)

            Text(item.title ?? "")
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
                .lineLimit(1)
            
            // Dotted Leader
            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
                }
                .stroke(Color.neutral300Border, style: StrokeStyle(lineWidth: 1, dash: [2]))
            }
            .frame(height: 1)

            Text("$\(String(format: "%.2f", item.amount ?? 0.00))")
                .font(.appSemiBold(14))
                .foregroundColor(.neutralMain700)
        }
        .padding(.vertical, 4)
    }
}

// -------------------------------------------------
// MARK: - Final Summary View
// -------------------------------------------------
struct SubscriptionSummaryView: View {

    let subscriptions = [
      SubscriptionData(amount: 10.00, color: "red", title: "Netflix"),
      SubscriptionData(amount: 20.00, color: "blue", title: "Prime"),
      SubscriptionData(amount: 5.32, color: "purple", title: "iCloud"),
      SubscriptionData(amount: 21.99, color: "indigo", title: "Spotify"),
      SubscriptionData(amount: 66.68, color: "cyan", title: "YouTube")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Top spending subscriptions")
                    .font(.appSemiBold(16))
                    .foregroundColor(.neutralMain700)
                Spacer()
            }
            .padding(16)
            
            Divider()
                .background(Color.neutral300Border)
            
            // Chart
            DonutChartView(data: subscriptions)
                .padding(.vertical, 24)
                .padding(.horizontal, 40) // Add padding to constrain width if needed
            
            // Stats & List Container
            VStack(spacing: 16) {
                // Active/Inactive Stats
                HStack(spacing: 4) {
                    Text("Active - 10")
                        .font(.appSemiBold(14))
                        .foregroundColor(.green) // Need to verify correct green color
                    Text("|")
                        .font(.appRegular(14))
                        .foregroundColor(.neutral400)
                    Text("Inactive - 06")
                        .font(.appSemiBold(14))
                        .foregroundColor(.disCardRed)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                // Background for this section? Mockup shows it inside the white card.
                
                // Legend List
                VStack(spacing: 8) {
                    ForEach(subscriptions.indices, id: \.self) { index in
                        LegendItemView(item: subscriptions[index])
                    }
                }
                .padding(.horizontal, 16)
                
                // Show More
                Button {
                    // Action
                } label: {
                    HStack(spacing: 4) {
                        Text("Show More")
                            .font(.appRegular(14))
                            .foregroundColor(.blueMain700)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.blueMain700)
                    }
                    .padding(.bottom, 16)
                }
            }
            .background(Color.neutralBg100.opacity(0.5)) // Slightly different bg? Mockup looks consistent white, but let's check.
            // Actually mockup shows a greyish box surrounding the list area?
            // "Active - 10 | Inactive - 06" is sitting on top of a light grey box that contains the list?
            // Looking closely at image:
            // There is a rounded rect container inside the main card.
            // It contains "Active...", the list, and "Show More".
            // Let's implement that internal container.
        }
        .background(Color.white)
        .cornerRadius(12)
        // .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

extension Shape {
    func glossyFill(color: Color) -> some View {
        self.fill(
            RadialGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.95),
                    color.opacity(0.70),
                    color.opacity(0.95)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 200     // adjust based on frame
            )
        )
    }
}

extension SubscriptionData {
    var uiColor: Color {
        // Map colors to design system or standard colors
        // Mockup uses a specific palette
        switch color?.lowercased() {
        case "red": return Color(hex: "FF5C5C") // Estimate
        case "blue": return Color(hex: "2E5BFF")
        case "purple": return .purple
        case "indigo": return .indigo
        case "cyan": return .cyan
        default: return .gray
        }
    }
  
}







