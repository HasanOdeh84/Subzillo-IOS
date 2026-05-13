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
    private let subscriptionOptions                     = ["5 - 10", "10 - 20", "20+"]
    private let spendingOptions                         = ["$50 - $100", "$100 - $200", "$200+"]
    @State private var selectedCurrency                 : Currency?
    @State private var selectedCountry                  : Country?
    @State private var showCountrySheet                 = false
    @EnvironmentObject var commonApiVM                  : CommonAPIViewModel
    @StateObject private var onboardingVM               = OnboardingViewModel()
    @State private var animateIn                        = false
    var appearDelay: Double                             = 0.12
    var moveDistance: CGFloat                           = 280
    @EnvironmentObject var router                       : AppIntentRouter
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            lottie      : "onboarding",
            subtitle    : "SUBZILLO • AI FINANCE",
            title       : "Your subscriptions,\n finally under control.",
            styledPart  : "finally",
            description : "An AI copilot that tracks, analyzes and cancels the ones you don't need."
        ),
        OnboardingPage(
            lottie      : "onboarding",
            subtitle    : "SUBZILLO • AI VOICE",
            title       : "Just say it.\n We'll add it.",
            styledPart  : "",
            description : "Talk to Subzillo like a friend. Our AI parses the price, the provider, the renewal date."
        ),
        OnboardingPage(
            lottie      : "onboarding2",
            subtitle    : "SUBZILLO • AI SCAN",
            title       : "Scan your inbox.\n Zero typing.",
            styledPart  : "Zero typing.",
            description : "Connect Gmail or Outlook. We'll detect recurring charges in seconds — securely and read-only."
        ),
        OnboardingPage(
            lottie      : "onboarding3",
            subtitle    : "SUBZILLO • AI AGENT",
            title       : "Meet your\n money agent.",
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
                
                Button {
                    router.navigate(to: .login)
                } label: {
                    Text("Skip")
                        .font(.geistSemiBold(14))
                        .foregroundColor(Color.textDim60637AA8A4C0)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 0) {
                        Spacer(minLength: 20)
                        
                        // Lottie Animation
                        LottieView(name: pages[index].lottie, loopMode: .loop)
                            .frame(height: 280)
                            .padding(.bottom, 40)
                        
                        // Subtitle
                        Text(pages[index].subtitle)
                            .font(.jetBrainsMedium(11))
                            .kerning(2.0)
                            .foregroundColor(Color.brandMidDark7C5CFF)
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
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom Page Control
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? LinearGradient.primaryTextGradient : LinearGradient(
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
                if currentPage == pages.count - 1 {
                    router.navigate(to: .login)
                } else {
                    withAnimation {
                        currentPage += 1
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
        .applyAppBackground()
        .navigationBarBackButtonHidden(true)
    }
    
    private func titleView(for page: OnboardingPage) -> some View {
        let lines = page.title.components(separatedBy: "\n")
        
        return VStack(spacing: 0) {
            ForEach(lines, id: \.self) { line in
                let styledPart = page.styledPart ?? ""
                if !styledPart.isEmpty && line.contains(styledPart) {
                    let parts = line.components(separatedBy: styledPart)
                    HStack(spacing: 0) {
                        Text(parts.first ?? "")
                        
                        Text(styledPart)
                            .font(.appRegular(34))
                            .italic()
                            .overlay(
                                LinearGradient(
                                    colors: [Color.brandGlowDarkA719DD, Color.brandToDark4489EB],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .mask(
                                Text(styledPart)
                                    .font(.appRegular(34))
                                    .italic()
                            )
                        
                        Text(parts.last ?? "")
                    }
                    .font(.geistSemiBold(34))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                } else {
                    Text(line)
                        .font(.geistSemiBold(34))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB)
                }
            }
        }
        .multilineTextAlignment(.center)
    }
    
    //MARK: - User defined methods
    //MARK: Tell us about yourself view
    func tellUsAbtYourselfView() -> some View {
        ScrollView{
            VStack(spacing: 32){
                //                Text("Tell us about yourself")
                Text("Almost Done")
                    .font(.appRegular(28))
                    .foregroundColor(.neutralMain700)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("How many subscriptions?")
                        .font(.appRegular(18))
                        .foregroundColor(.neutralMain700)
                    WrapButtonsView(options: subscriptionOptions,
                                    selectedIndex: $selectedSubscriptions)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Monthly subscription cost?")
                        .font(.appRegular(18))
                        .foregroundColor(.neutralMain700)
                    WrapButtonsView(options: spendingOptions,
                                    selectedIndex: $selectedSpending)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your country")
                        .font(.appRegular(14))
                        .foregroundColor(Color.neutralMain700)
                    
                    Button {
                        if commonApiVM.countriesResponse != nil {
                            showCountrySheet = true
                        } else {
                            commonApiVM.getCountries()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            AsyncImage(url: URL(string: selectedCountry?.countryFlag ?? "")) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 24, height: 24)
                                        .shimmer(true)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 24, height: 24)
                                case .failure:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 24, height: 24)
                                        .shimmer(true)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            Text(selectedCountry?.countryName ?? "Select Country")
                                .font(.appRegular(14))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image("dropDown_blackWhite")
                                .frame(width: 20, height: 20)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neutral2200, lineWidth: 1)
                        )
                    }
                }
                
                PhoneNumberField(phoneNumber        : .constant(""),
                                 header             : "Your payment currency",
                                 placeholder        : selectedCurrency?.name,
                                 selectedCurrency   : $selectedCurrency,
                                 selectedCountry    : $selectedCountry,
                                 isCountry          : false)
                
                Spacer()
            }
            .padding(.horizontal,2)
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

//struct WrapButtonsView: View {
//    let options: [String]
//    @Binding var selected: String?
//
//    var body: some View {
//        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
//            ForEach(options, id: \.self) { option in
//                Button {
//                    selected = option
//                } label: {
//                    Text(LocalizedStringKey(option))
//                        .font(.appRegular(18))
//                    //                        .lineLimit(1)
//                    //                        .fixedSize(horizontal: true, vertical: false)
//                        .foregroundColor(selected == option ? .white : .neutralMain700)
//                        .padding(.vertical, 6)
//                        .padding(.horizontal, 12)
//                        .frame(maxWidth: .infinity)
//                        .background(
//                            Capsule()
//                                .fill(selected == option ? Color.blueMain700 : .appNeutral900)
//                        )
//                        .overlay(
//                            Capsule()
//                                .stroke(selected == option ? Color.clear : .appNeutral800, lineWidth: 1)
//                        )
//                }
//            }
//        }
//    }
//}

struct WrapButtonsView: View {
    let options                 : [String]
    @Binding var selectedIndex  : Int?
    
    var body: some View {
        FlowLayout {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                
                Button {
                    selectedIndex = index + 1
                } label: {
                    let selectedIndexVal = (selectedIndex ?? 0) - 1
                    Text(LocalizedStringKey(option))
                        .font(.appRegular(18))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(selectedIndexVal == index ? Color.blueMain700 : .whiteBlackBG)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.innerShadow, lineWidth: 2)
                                        .blur(radius: 4)
                                        .offset(.init(width: 0, height: 2))
                                        .mask(Capsule())
                                )
                            //                                .if(selectedIndexVal != index) { view in
                            //                                                view.capsuleInnerShadow(
                            //                                                    color: Color.black.opacity(0.12),
                            //                                                    radius: 6,
                            //                                                    offset: -4
                            //                                                )
                            //                                            }
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedIndexVal == index ? Color.clear : .neutral300Border, lineWidth: 1)
                        )
                        .foregroundColor(selectedIndexVal == index ? .white : .neutralMain700)
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
