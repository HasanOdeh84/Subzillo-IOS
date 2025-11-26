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
    private let subscriptionOptions                     = ["5 - 10", "10 - 20", "20 - 30", "More than 30"]
    private let spendingOptions                         = ["Less than $50", "Less than $150", "More than $150"]
    @State private var selectedCurrency                 : Currency?
    @State private var selectedCountry                  : Country?
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
            title: "Manage your and your family'ssubscriptions in one place",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
        ),
        OnboardingPage(
            lottie: "onboarding",
            title: "Add Subscriptions Using Voice Commands",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
        ),
        OnboardingPage(
            lottie: "onboarding2",
            title: "Add Subscription by email integration",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
        ),
        OnboardingPage(
            lottie: "onboarding3",
            title: "Add Subscription by AI Assistant",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
        ),
        OnboardingPage(
            lottie: "onboarding",
            title: "Manage your and your family's subscriptions in one place",
            description: "Track Netflix, Spotify, gym memberships, and more in one organized dashboard. Never lose track again."
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
                    Spacer()
                    Button {
                        onboardingVM.navigate(to: .home)
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
                .padding(.vertical, 32)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack {
                            if currentPage == pages.count - 1{
                                tellUsAbtYourselfView()
                            }else{
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
                                
                                Spacer()
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
                AppState.shared.login()
                selectedCurrency = Currency(id      : nil,
                                            name    : Constants.shared.currencyCode,
                                            symbol  : Constants.shared.currencySymbol,
                                            code    : Constants.shared.currencyCode,
                                            flag    : Constants.shared.flag(from: Constants.shared.regionCode))
                if let error = commonApiVM.currencyError {
                    commonApiVM.getCurrencies()
                } else if let data = commonApiVM.currencyResponse {
                    selectedCurrency = data.first(where: { $0.code == Constants.shared.currencyCode })
                }
                else{
                    selectedCurrency = Currency(id      : nil,
                                                name    : Constants.shared.currencyCode,
                                                symbol  : Constants.shared.currencySymbol,
                                                code    : Constants.shared.currencyCode,
                                                flag    : Constants.shared.flag(from: Constants.shared.regionCode))
                }
            }
        }
    }
    
    //MARK: - User defined methods
    //MARK: Tell us about yourself view
    func tellUsAbtYourselfView() -> some View {
        ScrollView{
            VStack(spacing: 32){
                Text("Tell us about yourself")
                    .font(.appRegular(28))
                    .foregroundColor(.neutralMain700)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("How many subscriptions do you have?")
                        .font(.appRegular(18))
                        .foregroundColor(.neutralMain700)
                    WrapButtonsView(options: subscriptionOptions,
                                    selectedIndex: $selectedSubscriptions)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("How much you spend on subscription monthly?")
                        .font(.appRegular(18))
                        .foregroundColor(.neutralMain700)
                    WrapButtonsView(options: spendingOptions,
                                    selectedIndex: $selectedSpending)
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
                                            averageMonthlySpend     : (selectedSpending ?? 0))
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
    @Binding var selectedIndex  : Int? // 👈 store index instead of value
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    selectedIndex = index + 1 // 👈 track which one was tapped
                } label: {
                    var selectedIndexVal = (selectedIndex ?? 0) - 1
                    Text(LocalizedStringKey(option))
                        .font(.appRegular(18))
                        .foregroundColor(selectedIndexVal == index ? .white : .neutralMain700)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(selectedIndexVal == index ? Color.blueMain700 : .whiteBlackBG)
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedIndexVal == index ? Color.clear : .neutral300Border, lineWidth: 1)
                        )
                }
            }
        }
    }
}
