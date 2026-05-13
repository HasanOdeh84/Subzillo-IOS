//
//  OnboardingView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/09/25.
//

import SwiftUI

struct OnboardingPage {
    let lottie      : String
    let subtitle    : String
    let title       : String
    let styledPart  : String?
    let description : String
}

struct OnboardingView: View {
    
    //MARK: - Properties
    @State private var currentPage                      = 0
    @State private var selectedSubscriptions            : Int? = nil
    @State private var selectedSpending                 : Int? = nil
    private let subscriptionOptions                     = ["<5", "6-15", "16-30", "30+"]
    private let spendingOptions                         = ["$50-$100", "$100-$200", "$200+"]
    @State private var selectedCurrency                 : Currency?
    @State private var selectedCountry                  : Country?
    @State private var showCountrySheet                 = false
    @EnvironmentObject var commonApiVM                  : CommonAPIViewModel
    @StateObject private var onboardingVM               = OnboardingViewModel()
    @State private var animateIn                        = false
    var appearDelay: Double                             = 0.12
    var moveDistance: CGFloat                           = 280
    @EnvironmentObject var router                       : AppIntentRouter
    @EnvironmentObject var themeManager                 : ThemeManager
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            lottie      : "onboarding",
            subtitle    : "SUBZILLO • AI FINANCE",
            title       : "Your subscriptions,\nfinally under control.",
            styledPart  : "finally",
            description : "An AI copilot that tracks, analyzes and cancels the ones you don't need."
        ),
        OnboardingPage(
            lottie      : "onboarding",
            subtitle    : "",
            title       : "Just say it.\nWe'll add it.",
            styledPart  : "",
            description : "Talk to Subzillo like a friend. Our AI parses the price, the provider, the renewal date."
        ),
        OnboardingPage(
            lottie      : "onboarding2",
            subtitle    : "",
            title       : "Scan your inbox.\nZero typing.",
            styledPart  : "Zero typing.",
            description : "Connect Gmail or Outlook. We'll detect recurring charges in seconds — securely and read-only."
        ),
        OnboardingPage(
            lottie      : "onboarding3",
            subtitle    : "",
            title       : "Meet your\nmoney agent.",
            styledPart  : "money agent.",
            description : "Ask anything. Cancel subs, pause, compare plans — all from a chat."
        )
    ]
    
    //MARK: - Body
    var body: some View {
        VStack {
            // Top Navigation Bar
            HStack {
                if currentPage > 0 {
                    Button {
                        withAnimation { currentPage -= 1 }
                    } label: {
                        Image("backGray")
                            .frame(width: 20, height: 20)
                    }
                }
                
                Spacer()
                
                if currentPage < pages.count {
                    Button {
                        router.navigate(to: .login)
                    } label: {
                        Text("Skip")
                            .font(.geistSemiBold(14))
                            .foregroundColor(Color.textDim60637AA8A4C0)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            if currentPage < pages.count {
                // Onboarding Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        GeometryReader { geometry in
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 0) {
                                    Spacer(minLength: 20)
                                    
                                    // Lottie Animation
                                    LottieView(name: pages[index].lottie, loopMode: .loop)
                                        .frame(height: 280)
                                        .padding(.bottom, 20)
                                    
                                    // Subtitle
                                    Text(pages[index].subtitle)
                                        .font(.jetBrainsMedium(11))
                                        .kerning(2.0)
                                        .foregroundColor(themeManager.accentTextColor)
                                        .padding(.bottom, 16)
                                    
                                    // Title with Styled Part
                                    titleView(for: pages[index])
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                        .padding(.bottom, 20)
                                    
                                    // Description
                                    Text(pages[index].description)
                                        .font(.appRegular(16))
                                        .lineSpacing(4)
                                        .foregroundColor(Color.textDim60637AA8A4C0)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                    
                                    Spacer()
                                }
                                .frame(minWidth: geometry.size.width)
                                .frame(minHeight: geometry.size.height)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom Page Control
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentPage ? themeManager.accentGradient : LinearGradient(
                                colors: [Color.grayCBD5E1475569],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 28)
                
                //Button
                GradientBgButton(
                    title       : currentPage == 0 ? "Get started" : "Continue",
                    isSolid     : true,
                    showChevron : true
                ) {
                    withAnimation {
                        currentPage += 1
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            } else {
                // Setup View (5th Step)
                tellUsAbtYourselfView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                
                GradientBgButton(
                    title       : "Start tracking",
                    isSolid     : true,
                    showChevron : true
                ) {
                    // Final API Call and navigation
                    // updateOnboardingApi()
                    AppState.shared.login()
                    router.navigate(to: .home)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
        .applyAppBackground()
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func titleView(for page: OnboardingPage) -> some View {
        let styledPart = page.styledPart ?? ""
        let title = page.title
        
        if !styledPart.isEmpty && title.contains(styledPart) {
            ZStack {
                buildLine(line: title, styledPart: styledPart, isMask: false)
                    .multilineTextAlignment(.center)
                
                themeManager.accentGradient
                    .mask(
                        buildLine(line: title, styledPart: styledPart, isMask: true)
                            .multilineTextAlignment(.center)
                    )
            }
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(title)
                .font(.geistSemiBold(34))
                .foregroundColor(Color.textPrimary0E101AF4F1FB)
                .multilineTextAlignment(.center)
        }
    }
    
    private func buildLine(line: String, styledPart: String, isMask: Bool) -> Text {
        let parts = line.components(separatedBy: styledPart)
        var result = Text("")
        for (index, part) in parts.enumerated() {
            result = result + Text(part)
                .font(.geistSemiBold(34))
                .foregroundColor(isMask ? .clear : Color.textPrimary0E101AF4F1FB)
            
            if index < parts.count - 1 {
                result = result + Text(styledPart)
                    .font(.appRegular(34))
                    .italic()
                    .foregroundColor(isMask ? .black : Color.textPrimary0E101AF4F1FB)
            }
        }
        return result
    }
    
    //MARK: - User defined methods
    //MARK: Tell us about yourself view
    func tellUsAbtYourselfView() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("One last thing.")
                        .font(.geistSemiBold(34))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB)
                    
                    Text("Helps us tune your dashboard.")
                        .font(.appRegular(16))
                        .foregroundColor(Color.textDim60637AA8A4C0)
                }
                .padding(.top, 20)
                .padding(.horizontal, 4)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("HOW MANY SUBS?")
                        .font(.jetBrainsMedium(11))
                        .kerning(2.0)
                        .foregroundColor(Color.textDim60637AA8A4C0)
                        .padding(.horizontal, 4)
                    
                    WrapButtonsView(options: subscriptionOptions,
                                    selectedIndex: $selectedSubscriptions)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("WHAT KIND?")
                        .font(.jetBrainsMedium(11))
                        .kerning(2.0)
                        .foregroundColor(Color.textDim60637AA8A4C0)
                        .padding(.horizontal, 4)
                    
                    WrapButtonsView(options: spendingOptions,
                                    selectedIndex: $selectedSpending)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("YOUR COUNTRY")
                        .font(.jetBrainsMedium(11))
                        .kerning(2.0)
                        .foregroundColor(Color.textDim60637AA8A4C0)
                        .padding(.horizontal, 4)
                    
                    Button {
                        if commonApiVM.countriesResponse != nil {
                            showCountrySheet = true
                        } else {
                            commonApiVM.getCountries()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                if let flag = selectedCountry?.countryFlag {
                                    AsyncImage(url: URL(string: flag)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                                } else {
                                    Text("AE")
                                        .font(.appBold(12))
                                        .foregroundColor(Color.textPrimary0E101AF4F1FB)
                                }
                            }
                            
                            Text(selectedCountry?.countryName ?? "UAE Dirham")
                                .font(.appSemiBold(16))
                                .foregroundColor(Color.textPrimary0E101AF4F1FB)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.textDim60637AA8A4C0)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 64)
                        .background(Color.whiteNeutralCardBG)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("YOUR CURRENCY")
                        .font(.jetBrainsMedium(11))
                        .kerning(2.0)
                        .foregroundColor(Color.textDim60637AA8A4C0)
                        .padding(.horizontal, 4)
                    
                    Button {
                        // Currency selection action
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Text(selectedCountry?.countryCode ?? "AE")
                                    .font(.appBold(12))
                                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedCountry?.countryName ?? "UAE Dirham")
                                    .font(.appSemiBold(16))
                                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                                Text(selectedCurrency?.code ?? "AED")
                                    .font(.appRegular(12))
                                    .foregroundColor(Color.textDim60637AA8A4C0)
                            }
                            
                            Spacer()
                            
                            Text(selectedCurrency?.symbol ?? "د.إ")
                                .font(.appBold(20))
                                .foregroundColor(themeManager.accentTextColor)
                                .padding(.trailing, 8)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.textDim60637AA8A4C0)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 72)
                        .background(Color.whiteNeutralCardBG)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    //MARK: - Update onboarding API
    //    func updateOnboardingApi(){
    //        let input = UpdateOnboardingRequest(userId                  : Constants.getUserId(),
    //                                            preferredCurrency       : selectedCurrency?.code ?? "",
    //                                            preferredCurrencySymbol : selectedCurrency?.symbol ?? "",
    //                                            noofSubscriptions       : (selectedSubscriptions ?? 0),
    //                                            averageMonthlySpend     : (selectedSpending ?? 0),
    //                                            isoCountryCode          : selectedCountry?.countryCode ?? "")
    //        if let errorMessage = LoginSignupValidations().validateOnboarding(input: input) {
    //            ToastManager.shared.showToast(message: errorMessage,style: ToastStyle.error)
    //        } else {
    //            onboardingVM.updateOnboarding(input: input)
    //        }
    //    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

struct WrapButtonsView: View {
    let options                 : [String]
    @Binding var selectedIndex  : Int?
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        FlowLayout {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                let isSelected = (selectedIndex ?? 0) - 1 == index
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedIndex = index + 1
                    }
                } label: {
                    Text(LocalizedStringKey(option))
                        .font(.appSemiBold(15))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .foregroundColor(isSelected ? .white : Color.textPrimary0E101AF4F1FB)
                        .background(
                            Group {
                                if isSelected {
                                    themeManager.accentGradient
                                } else {
                                    Color.whiteNeutralCardBG
                                }
                            }
                        )
                        .cornerRadius(12)
                        .shadow(color: isSelected ? themeManager.accentShadowColor : Color.black.opacity(0.05), 
                                radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
            }
        }
    }
}

struct CapsuleInnerShadow: ViewModifier {
    var color: Color = Color.black.opacity(0.12)
    var radius: CGFloat = 6       // blur
    var verticalOffset: CGFloat = -4   // pulls shadow to top
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Capsule()
                    .fill(
                        Color.clear
                            .shadow(.inner(
                                color: color,
                                radius: radius,
                                x: 0,
                                y: verticalOffset
                            ))
                    )
                    .mask(
                        VStack(spacing: 0) {
                            Color.white              // keep top shadow visible
                            Color.clear.frame(height: 12) // cut bottom shadow
                        }
                            .mask(Capsule())
                    )
            )
    }
}

extension View {
    func capsuleInnerShadow(
        color: Color = Color.black.opacity(0.12),
        radius: CGFloat = 6,
        offset: CGFloat = -4
    ) -> some View {
        modifier(CapsuleInnerShadow(color: color, radius: radius, verticalOffset: offset))
    }
}


//struct ContentView: View {
//    let cornerRadius: CGFloat = 20
//    let shadowColor = Color.gray.opacity(0.5)
//    let shadowRadius: CGFloat = 8
//    // Offset the shadow down to hide the bottom edge
//    let shadowYOffset: CGFloat = 10
//    // Small offsets for left/right to ensure the shadow is visible there
//    let shadowXOffset: CGFloat = 1
//
//    var body: some View {
//        VStack{
//            RoundedRectangle(cornerRadius: cornerRadius)
//                .fill(Color.white.shadow(.inner(color: shadowColor, radius: shadowRadius, x: shadowXOffset, y: -shadowYOffset))) // Use -Y for top shadow
//                .frame(width: 200, height: 150)
//                .background(Color.white) // Ensure the background is white so the shadow is visible
//                .cornerRadius(cornerRadius) // Clip the background to the corners        }
//    }
//}
//
struct ContentView: View {
    let cornerRadius: CGFloat = 20
    let shadowColor = Color.gray.opacity(0.45)
    let shadowRadius: CGFloat = 10
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        Color.white
                            .shadow(.inner(
                                color: shadowColor,
                                radius: shadowRadius,
                                x: 0,
                                y: -4        // pulls shadow upward → top + sides
                            ))
                    )
                    .mask(
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 90) // top area where shadow should appear
                            Rectangle()
                                .fill(Color.clear) // remove shadow at bottom
                        }
                    )
            )
            .frame(width: 220, height: 120)
    }
}

extension View {
    func topSideInnerShadow(color: Color = .gray, radius: CGFloat = 5, x: CGFloat = 0, y: CGFloat = -3) -> some View {
        self.overlay(
            Rectangle()
                .stroke(color, lineWidth: radius)
                .offset(x: x, y: y)
                .clipped()
                .blur(radius: radius / 2) // Smooth blur effect
                .mask(self) // Confine the effect to the shape of the original view
        )
    }
}

struct FlowLayout: Layout {
    // Define spacing constants once
    let horizontalSpacing: CGFloat = 8
    let verticalSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(proposal)
            
            if currentX + subviewSize.width > containerWidth {
                // Wrap to the next line
                currentX = 0
                currentY += lineHeight + verticalSpacing
                lineHeight = 0
            }
            
            // Update positions
            currentX += subviewSize.width + horizontalSpacing
            lineHeight = max(lineHeight, subviewSize.height)
        }
        
        // Return the actual calculated height required to fit all chips
        // Add the last line's height to the total Y position
        return CGSize(width: containerWidth, height: currentY + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let containerWidth = bounds.width
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(proposal)
            
            // Check if the current chip exceeds the container width
            if currentX + subviewSize.width > containerWidth {
                // Wrap to the next line
                currentX = bounds.minX
                currentY += lineHeight + verticalSpacing // Use consistent spacing
                lineHeight = 0
            }
            
            // Place the subview
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                anchor: .topLeading,
                proposal: ProposedViewSize(subviewSize)
            )
            
            // Update the x position for the next chip
            currentX += subviewSize.width + horizontalSpacing // Use consistent spacing
            lineHeight = max(lineHeight, subviewSize.height)
        }
    }
}
