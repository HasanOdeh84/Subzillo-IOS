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
    @Environment(\.colorScheme) private var systemScheme
    
    // Inline selection states
    @State private var isCountryExpanded    = false
    @State private var isCurrencyExpanded   = false
    @State private var countrySearchText    = ""
    @State private var currencySearchText   = ""
    
    var filteredCountries: [Country] {
        if countrySearchText.isEmpty {
            return commonApiVM.countriesResponse ?? []
        }
        return commonApiVM.countriesResponse?.filter {
            $0.countryCode?.localizedCaseInsensitiveContains(countrySearchText) ?? false ||
            $0.countryName?.localizedCaseInsensitiveContains(countrySearchText) ?? false
        } ?? []
    }
    
    var filteredCurrencies: [Currency] {
        if currencySearchText.isEmpty {
            return commonApiVM.currencyResponse ?? []
        }
        return commonApiVM.currencyResponse?.filter {
            $0.code?.localizedCaseInsensitiveContains(currencySearchText) ?? false ||
            $0.name?.localizedCaseInsensitiveContains(currencySearchText) ?? false
        } ?? []
    }
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            lottie      : "onboarding1_new",
            subtitle    : "SUBZILLO • AI FINANCE",
            title       : "Your subscriptions,\nfinally under control.",
            styledPart  : "finally",
            description : "An AI copilot that tracks, analyzes and cancels the ones you don't need."
        ),
        OnboardingPage(
            lottie      : "onboarding2_new",
            subtitle    : "",
            title       : "Just say it.\nWe'll add it.",
            styledPart  : "",
            description : "Talk to Subzillo like a friend. Our AI parses the price, the provider, the renewal date."
        ),
        OnboardingPage(
            lottie      : "onboarding3_new",
            subtitle    : "",
            title       : "Scan your inbox.\nZero typing.",
            styledPart  : "Zero typing.",
            description : "Connect Gmail or Outlook. We'll detect recurring charges in seconds — securely and read-only."
        ),
        OnboardingPage(
            lottie      : "onboarding4_new",
            subtitle    : "",
            title       : "Meet your\nmoney agent.",
            styledPart  : "money agent.",
            description : "Ask anything. Cancel subs, pause, compare plans — all from a chat."
        ),
        OnboardingPage(
            lottie      : "onboarding5_new",
            subtitle    : "",
            title       : "Meet \nmoney agent.",
            styledPart  : "money .",
            description : "Ask . Cancel subs, pause, compare plans — all from a chat."
        )
    ]
    
    //MARK: - Body
    var body: some View {
        VStack {
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
                
                if currentPage != 4 {
                    Button {
                        currentPage = 4
//                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//                            
//                        }
                    } label: {
                        Text("Skip")
                            .font(.geistSemiBold(14))
                            .foregroundColor(Color.textDim60637AA8A4C0)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack {
                        if currentPage == pages.count - 1{
                            tellUsAbtYourselfView()
                        }else{
                            GeometryReader { geometry in
                                ScrollView(.vertical) {
                                    VStack(spacing: 0) {
                                        Spacer(minLength: 20)
                                        
                                        //                                    // Lottie Animation
                                        //                                    LottieView(name: pages[index].lottie, loopMode: .loop)
                                        Image(pages[index].lottie)
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
                                            .font(.geistMedium(16))
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
                        }
                    }
                    .tag(index)
                }
            }
            .animation(.none, value: currentPage)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // hide default dots

            
//            if currentPage != 4 {
//                // Onboarding Pages
//                TabView(selection: Binding(
//                    get: { min(currentPage, pages.count - 1) },
//                    set: { currentPage = $0 }
//                )) {
//                    ForEach(0..<pages.count, id: \.self) { index in
//                        GeometryReader { geometry in
//                            ScrollView(.vertical, showsIndicators: false) {
//                                VStack(spacing: 0) {
//                                    Spacer(minLength: 20)
//                                    
//                                    //                                    // Lottie Animation
//                                    //                                    LottieView(name: pages[index].lottie, loopMode: .loop)
//                                    Image(pages[index].lottie)
//                                        .frame(height: 280)
//                                        .padding(.bottom, 20)
//                                    
//                                    // Subtitle
//                                    Text(pages[index].subtitle)
//                                        .font(.jetBrainsMedium(11))
//                                        .kerning(2.0)
//                                        .foregroundColor(themeManager.accentTextColor)
//                                        .padding(.bottom, 16)
//                                    
//                                    // Title with Styled Part
//                                    titleView(for: pages[index])
//                                        .multilineTextAlignment(.center)
//                                        .padding(.horizontal, 40)
//                                        .padding(.bottom, 20)
//                                    
//                                    // Description
//                                    Text(pages[index].description)
//                                        .font(.geistMedium(16))
//                                        .lineSpacing(4)
//                                        .foregroundColor(Color.textDim60637AA8A4C0)
//                                        .multilineTextAlignment(.center)
//                                        .padding(.horizontal, 40)
//                                    
//                                    Spacer()
//                                }
//                                .frame(minWidth: geometry.size.width)
//                                .frame(minHeight: geometry.size.height)
//                            }
//                        }
//                        .tag(index)
//                    }
//                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            } else {
//                tellUsAbtYourselfView()
//            }
            
            // Custom Page Control
            HStack(spacing: 8) {
                ForEach(0...pages.count - 1, id: \.self) { index in
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
            .padding(.vertical, 28)
            
            // Action Button
            GradientBgButton(
                title       : currentPage != 4 ? (currentPage == 0 ? "Get started" : "Continue") : "Start tracking",
                isSolid     : true,
                showChevron : true
            ) {
                if currentPage != 4 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    updateOnboardingApi()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
        .applyAppBackground()
        .navigationBarBackButtonHidden(true)
        .onAppear{
            if commonApiVM.currencyResponse != nil {
                selectedCurrency = commonApiVM.currencyResponse?.first(where: { $0.code == Constants.shared.currencyCode })
            }else{
                commonApiVM.getCurrencies()
            }
            
            if commonApiVM.countriesResponse != nil {
                selectedCountry = commonApiVM.countriesResponse?.first(where: { $0.countryCode == Constants.shared.regionCode })
            }else{
                commonApiVM.getCountries()
            }
        }
        .onChange(of: commonApiVM.countriesResponse) { countries in
            if selectedCountry == nil {
                selectedCountry = countries?.first(where: { $0.countryCode == Constants.shared.regionCode })
            }
        }
        //        .sheet(isPresented: $showCountrySheet) {
        //            CountriesBottomSheet(selectedCurrency   : $selectedCurrency,
        //                                 selectedCountry    : $selectedCountry,
        //                                 isCountry          : true,
        //                                 currencyResponse   : commonApiVM.currencyResponse,
        //                                 countryResponse    : commonApiVM.countriesResponse,
        //                                 header             : "Select your Country",
        //                                 placeholder        : "Search",
        //                                 isDialCode          : false)
        //            .presentationDetents([.large])
        //            .presentationDragIndicator(.hidden)
        //        }
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
        ScrollViewReader { proxy in
            ScrollView() {
                VStack(alignment: .leading, spacing: 38) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("One last thing.")
                            .font(.geistSemiBold(33))
                            .foregroundColor(Color.textPrimary0E101AF4F1FB)
                        
                        Text("Helps us tune your dashboard.")
                            .font(.geistMedium(18))
                            .foregroundColor(Color.textDim60637AA8A4C0)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("HOW MANY SUBS?")
                            .font(.jetBrainsMedium(14))
                            .kerning(2.0)
                            .foregroundColor(Color.textDim60637AA8A4C0)
                            .padding(.horizontal, 4)
                        
                        WrapButtonsView(options: subscriptionOptions,
                                        selectedIndex: $selectedSubscriptions)
                    }
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("HOW MUCH YOU SPEND ON SUBSCRIPTIONS MONTHLY?")
                            .font(.jetBrainsMedium(14))
                        //                        .kerning(2.0)
                            .foregroundColor(Color.textDim60637AA8A4C0)
                            .padding(.horizontal, 4)
                        
                        WrapButtonsView(options: spendingOptions,
                                        selectedIndex: $selectedSpending)
                    }
                    
                    InlineSelectionView(
                        title: "YOUR COUNTRY",
                        items: filteredCountries,
                        selectedItem: $selectedCountry,
                        isExpanded: $isCountryExpanded,
                        searchText: $countrySearchText,
                        placeholder: "Search Country...",
                        labelProvider: { $0.countryName ?? "" },
                        flagProvider: { $0.countryFlag ?? "" },
                        detailProvider: nil,
                        secondaryDetailProvider: nil
                    )
                    .id("countrySelection")
                    .onChange(of: isCountryExpanded) { expanded in
                        if expanded {
                            withAnimation { isCurrencyExpanded = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    proxy.scrollTo("countrySelection", anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    InlineSelectionView(
                        title: "YOUR CURRENCY",
                        items: filteredCurrencies,
                        selectedItem: $selectedCurrency,
                        isExpanded: $isCurrencyExpanded,
                        searchText: $currencySearchText,
                        placeholder: "Search Currency...",
                        labelProvider: { $0.name ?? "" },
                        flagProvider: { $0.flag ?? "" },
                        detailProvider: { $0.code ?? "" },
                        secondaryDetailProvider: { $0.symbol ?? "" }
                    )
                    .id("currencySelection")
                    .onChange(of: isCurrencyExpanded) { expanded in
                        if expanded {
                            withAnimation { isCountryExpanded = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    proxy.scrollTo("currencySelection", anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
            }
        }
    }
    
    //MARK: - Update onboarding API
    func updateOnboardingApi(){
        let input = UpdateOnboardingRequest(userId                  : Constants.getUserId(),
                                            preferredCurrency       : selectedCurrency?.code ?? "",
                                            preferredCurrencySymbol : selectedCurrency?.symbol ?? "",
                                            noofSubscriptions       : (selectedSubscriptions ?? 0) - 1,
                                            averageMonthlySpend     : (selectedSpending ?? 0),
                                            isoCountryCode          : selectedCountry?.countryCode ?? "")
        if let errorMessage = LoginSignupValidations().validateOnboarding(input: input) {
            ToastManager.shared.showToast(message: errorMessage,style: ToastStyle.error)
        } else {
            onboardingVM.updateOnboarding(input: input)
        }
    }
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
                        .font(.geistSemiBold(15))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .foregroundColor(isSelected ? .surfaceLightFFFFFF : Color.textPrimary0E101AF4F1FB)
                        .background(
                            Group {
                                if isSelected {
                                    themeManager.accentGradient
                                } else {
                                    Color.cardBgFFFFFF1A1030
                                }
                            }
                        )
                        .cornerRadius(12)
                        .shadow(color: isSelected ? themeManager.accentShadowColor : Color.clear,
                                radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.clear : Color.cardBorderE2E8F0E2E8F0, lineWidth: 1)
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
//            if currentX + subviewSize.width > containerWidth {
            if currentX + subviewSize.width > bounds.maxX {
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
