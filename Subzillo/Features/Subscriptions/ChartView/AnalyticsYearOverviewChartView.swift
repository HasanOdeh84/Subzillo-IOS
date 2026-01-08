
import SwiftUI

struct AnalyticsYearOverviewChartView: View {
    let year = "2024"
    let years = ["2023", "2024", "2025"]
    @State private var selectedYear = "2024"
    
    // Mock Data based on image
    // Jan~80, Feb~60, Mar~200, Apr~80, May~60, Jun~40, Jul~80, Aug~120, Sep~80, Oct~80, Nov~80, Dec~90
    let monthlyData: [Double] = [80, 60, 200, 80, 60, 40, 80, 120, 80, 80, 80, 90]
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Year Overview")
                    .font(.appSemiBold(16))
                    .foregroundColor(.neutralMain700)
                
                Spacer()
                
                Menu {
                    ForEach(years, id: \.self) { y in
                        Button(y) { selectedYear = y }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedYear)
                            .font(.appRegular(14))
                            .foregroundColor(.neutralMain700)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.neutral500)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.neutral300Border, lineWidth: 1)
                    )
                }
            }
            
            // Chart Content
            VStack(alignment: .leading, spacing: 12) {
                // X-Axis Labels (Top)
                GeometryReader { geo in
                    HStack {
                        Text("0")
                        Spacer()
                        Text("100")
                        Spacer()
                        Text("200")
                    }
                    .font(.appRegular(12))
                    .foregroundColor(.neutralMain700)
                    // Adjust padding to align with bars content if needed
                    .padding(.leading, 35) // Approximate width of month labels
                }
                .frame(height: 20)
                
                // Bars
                ForEach(0..<12, id: \.self) { index in
                    HStack(spacing: 12) {
                        Text(months[index])
                            .font(.appRegular(14))
                            .foregroundColor(.neutralMain700)
                            .frame(width: 30, alignment: .leading)
                        
                        GeometryReader { geo in
                            let maxWidth = geo.size.width
                            let value = monthlyData[index]
                            let barWidth = (value / 200.0) * maxWidth
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "8A4FFF"), Color(hex: "4FAAFF")]), // Purple to Blue gradient approximation
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: barWidth, height: 16)
                        }
                        .frame(height: 16)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        // .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // Optional shadow based on style
    }
}


