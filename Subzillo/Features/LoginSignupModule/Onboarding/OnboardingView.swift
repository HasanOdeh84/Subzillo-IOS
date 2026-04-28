//
//  OnboardingView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 23/09/25.
//

import SwiftUI

struct OnboardingPage {
    let lottie      : String
    let title       : String
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
    
    // controls the SwiftUI offset animation
    @State private var animateIn    = false
    // delay and distance
    var appearDelay: Double         = 0.12
    var moveDistance: CGFloat       = 280
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            lottie: "onboarding",
            title: "Manage your and your family's subscriptions in one place",
            description: ""
        ),
        OnboardingPage(
            lottie: "onboarding",
            title: "Add Subscriptions Using Voice Commands",
            description: ""
        ),
        OnboardingPage(
            lottie: "onboarding2",
            title: "Add Subscription by email integration",
            description: ""
        ),
        OnboardingPage(
            lottie: "onboarding3",
            title: "Add Subscription by AI Assistant",
            description: ""
        ),
        OnboardingPage(
            lottie: "onboarding",
            title: "Manage your and your family's subscriptions in one place",
            description: ""
        )
    ]
    
    //MARK: - Body
    var body: some View {
        ZStack{
            Group {
                Color(.neutralBg100)
            }
            .ignoresSafeArea()
            VStack {
                HStack(spacing: 10) {
                    Text("\(currentPage+1)/\(pages.count)")
                        .font(.appRegular(18))
                        .foregroundColor(.neutral500)
                    Spacer()
                    if currentPage != 4{
                        Button {
                            //                        onboardingVM.navigate(to: .home)
                            currentPage = 4
                        } label: {
                            HStack(spacing: 4) {
                                Text("Skip Onboarding")
                                    .foregroundColor(Color.navyBlueCTA700)
                                    .font(.appRegular(14))
                                Image(systemName: "arrow.right")
                                    .foregroundColor(Color.blueMain700)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 32)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack {
                            if currentPage == pages.count - 1{
                                tellUsAbtYourselfView()
                            }else{
                                ScrollView{
                                    if currentPage == 0{
                                        Image(pages[index].lottie)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 190)
                                    }else{
                                        if currentPage == 3{
                                            LottieView(name: pages[index].lottie)
                                                .frame(height: 190)
                                                .frame(maxWidth: .infinity)
                                                .offset(y: animateIn ? 0 : moveDistance)
                                                .opacity(animateIn ? 1 : 0)
                                                .id(currentPage)
                                                .onAppear {
                                                    if currentPage == index {
                                                        withAnimation(.interpolatingSpring(stiffness: 220, damping: 22).delay(appearDelay)) {
                                                            animateIn = true
                                                        }
                                                    }
                                                }
                                                .onChange(of: currentPage) { newValue in
                                                    if newValue == index {
                                                        animateIn = false
                                                        withAnimation(.interpolatingSpring(stiffness: 220, damping: 22).delay(appearDelay)) {
                                                            animateIn = true
                                                        }
                                                    }
                                                }
                                                .onDisappear {
                                                    if currentPage != 3{
                                                        // Reset when leaving page
                                                        animateIn = false
                                                    }
                                                }
                                        }else{
                                            LottieView(name: pages[index].lottie)
                                                .frame(height: 190)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    
                                    Text(LocalizedStringKey(pages[index].title))
                                        .font(.appRegular(28))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .padding(.top,64)
                                        .foregroundColor(.neutralMain700)
                                    
                                    Text(LocalizedStringKey(pages[index].description))
                                        .font(.appRegular(18))
                                        .foregroundColor(.neutral500)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .padding(.top,32)
                                        .padding(.bottom,40)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .tag(index)
                    }
                }
                .animation(.none, value: currentPage)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // hide default dots
                
                // Custom page indicator
                HStack(spacing: 13) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        if index == currentPage{
                            Capsule()
                                .fill(Color.blueMain700)
                                .frame(width: 32, height: 8)
                        }else{
                            Circle()
                                .fill(Color.neutral400)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding(.bottom, 23)
                
                GradientBorderButton(title: currentPage == pages.count - 1 ?
                                     "Lets Go!" : "Next") {
                    if currentPage == pages.count - 1{
                        updateOnboardingApi()
                    }else{
                        currentPage += 1
                    }
                }
                                     .background(Color.clear)
                                     .padding(.bottom,48)
            }
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
            .onAppear{
                //                AppState.shared.login()
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
            .sheet(isPresented: $showCountrySheet) {
                CountriesBottomSheet(selectedCurrency   : $selectedCurrency,
                                     selectedCountry    : $selectedCountry,
                                     isCountry          : true,
                                     currencyResponse   : commonApiVM.currencyResponse,
                                     countryResponse    : commonApiVM.countriesResponse,
                                     header             : "Select your Country",
                                     placeholder        : "Search",
                                     isDialCode          : false)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
            }
        }
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
    func updateOnboardingApi(){
        let input = UpdateOnboardingRequest(userId                  : Constants.getUserId(),
                                            preferredCurrency       : selectedCurrency?.code ?? "",
                                            preferredCurrencySymbol : selectedCurrency?.symbol ?? "",
                                            noofSubscriptions       : (selectedSubscriptions ?? 0),
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
