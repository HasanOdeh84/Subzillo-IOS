//
//  CurrencyBottomSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//
import SwiftUI

enum CardType: Int, CaseIterable {
    
    case Visa = 1
    case Mastercard = 2
    case Amex = 3
    case Other = 0
    
    var title: String {
        switch self {
        case .Visa:
            return "Visa"
        case .Mastercard:
            return "Mastercard"
        case .Amex:
            return "Amex"
        case .Other:
            return "Other"
        }
    }
}


struct AddNewCardSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State var nickName             : String = ""
    @State var cardNumber           : String = ""
    @State var cardName             : String = ""
    @State private var expDate              : String = ""
    @State private var ccv                  : String = ""
    @State private var showExpiryPopup      = false
    @State private var selectedMonth        = Calendar.current.component(.month, from: Date())
    @State private var selectedYear         = Calendar.current.component(.year, from: Date())
    @State var formattedExpiry: String      = ""
    @StateObject var addSubscriptionVM      = ManualEntryViewModel()
    @StateObject var myCardsVM              = MyCardsViewModel()
    @StateObject private var toastManager   = ToastManager()
    @State var shouldCallAPI              : Bool
    @State var isEdit                       = false
    @State var cardId                       = ""
    @State var selectedType                 : CardType = .Visa
    @State var isDefault                    = true
    var action                              : () -> Void = {}
    @EnvironmentObject var themeManager     : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    
    //MARK: - body
    var body: some View {
        VStack {
            
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                Spacer()
                
                VStack(alignment: .leading, spacing: 1) {
                    Text((LocalizedStringKey(isEdit ? "Edit card" : "Add card")))
                        .font(.geistBold(16))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                }
                
                Spacer()
                
                // MARK: - Empty Space
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal,20)
            .padding(.top, 10)
            
            ScrollView{
                
                ZStack {
                    
                    // Background
                    if colorScheme == .dark
                    {
                        LinearGradient(
                            colors: [
                                Color(hex: "#1A1A2E"),
                                Color(hex: "#2A1F4A")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    else{
                        LinearGradient(
                            colors: [
                                Color(hex: "#E8ECF5"),
                                Color(hex: "#D5DBEC")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    
                    // Decorative circles
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 160, height: 160)
                        .offset(x: 80, y: -70)
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 120, height: 120)
                        .offset(x: -90, y: 70)
                    
                    VStack(spacing: 0) {
                        
                        // Top Section
                        HStack(alignment: .top) {
                            
                            VStack(alignment: .leading, spacing: 2) {
                                
                                Text("Subzillo · Identifier")
                                    .font(.jetBrainsMedium(10))
                                    .tracking(1.4)
                                    .textCase(.uppercase)
                                    .foregroundColor(
                                        Color.textPrimary0E101AF4F1FB.opacity(0.75)
                                    )
                                
                                Text(cardName)
                                    .font(.geistBold(14))
                                    .foregroundColor(
                                        Color.textPrimary0E101AF4F1FB.opacity(0.6)
                                    )
                                
                                Text(nickName)
                                    .font(.geistBold(11))
                                    .tracking(-0.2)
                                    .foregroundColor(
                                        Color.textPrimary0E101AF4F1FB.opacity(0.6)
                                    )
                            }
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    themeManager.black_white.opacity(0.08)
                                )
                                .frame(width: 34, height: 22)
                        }
                        
                        Spacer()
                        
                        // Bottom Section
                        HStack(alignment: .bottom) {
                            
                            Text("•••• •••• \(cardNumber)")
                                .font(.jetBrainsMedium(22))
                                .tracking(3)
                                .foregroundColor(
                                    Color.textPrimary0E101AF4F1FB.opacity(0.6)
                                )
                            
                            Spacer()
                            
                            Text(selectedType.title)
                                .font(.geistExtraBold(15))
                                .tracking(-0.5)
                                .textCase(.uppercase)
                                .foregroundColor(
                                    Color.textPrimary0E101AF4F1FB.opacity(0.6)
                                )
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 20)
                }
                .frame(height: 190)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
                .shadow(
                    color: themeManager.selectedAccent.senColor.opacity(0.55),
                    radius: 25,
                    x: 0,
                    y: 20
                )
                .padding(.top,10)
                .padding(.horizontal,20)
                
                HStack(alignment: .center, spacing: 10) {
                    
                    Image("lockIcon")
                        .frame(width: 14, height: 14)
                    
                    Text(attributedDescription)
                        .font(.geistRegular(11))
                        .lineSpacing(2)
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .background(
                    themeManager.accentGradient.opacity(0.133)
                )
                .overlay {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            themeManager.selectedAccent.primaryColor
                                .opacity(0.2),
                            lineWidth: 1
                        )
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                VStack(spacing: 14) {
                    
                    FieldView(text: $cardName, title: "Card holder name", image: "cardName", placeHolder: "Enter your full name")
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("Card type")
                            .font(.jetBrainsMedium(10))
                            .tracking(1)
                            .textCase(.uppercase)
                            .foregroundStyle(
                                Color.textPrimary0E101AF4F1FB
                                    .opacity(0.6)
                            )
                            .padding(.bottom, 5)
                        
                        HStack(spacing: 4) {
                            ForEach(CardType.allCases, id: \.rawValue) { type in
                                
                                Button {
                                    
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedType = type
                                    }
                                    
                                } label: {
                                    
                                    Text(type.title)
                                        .font(.geistSemiBold(12))
                                        .foregroundStyle(
                                            selectedType == type
                                            ? .white
                                            : Color.textPrimary0E101AF4F1FB
                                                .opacity(0.6)
                                        )
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 38)
                                        .background {
                                            
                                            if selectedType == type {
                                                
                                                themeManager.accentGradient
                                            } else {
                                                
                                                Color.clear
                                            }
                                        }
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 10)
                                        )
                                        .shadow(
                                            color: selectedType == type
                                            ? themeManager.selectedAccent.senColor
                                                .opacity(0.55)
                                            : .clear,
                                            radius: 10,
                                            y: 2
                                        )
                                }
                            }
                        }
                        .padding(4)
                        .background(themeManager.white_white4)
                        .overlay {
                            
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    Color.textPrimary0E101AF4F1FB
                                        .opacity(0.08),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                    }
                    
                    
                    FieldView(text: $cardNumber, title: "Last 4 digits (optional)", image: "cardNum", placeHolder: "4829", maxDigits: 4, isNumberPad: true, isCardNo: true)
                        .addDoneButton{
                        }
                    
                    FieldView(text: $nickName, title: "Nickname (optional)", image: "cardNic", placeHolder: "e.g. Personal, Work, Family")
                        .onChange(of: nickName) { newValue in
                            if newValue.count > 15 {
                                nickName = String(newValue.prefix(15))
                                toastManager.showToast(message: "Nickname cannot exceed 15 characters".localized, style: .error)
                            }
                        }
                    
                    Button {
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isDefault.toggle()
                        }
                        
                    } label: {
                        
                        HStack {
                            
                            VStack(alignment: .leading, spacing: 0) {
                                
                                Text("Make default")
                                    .font(.geistSemiBold(13))
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                    )
                                
                                Text("Assign new subscriptions to this card")
                                    .font(.geistRegular(11))
                                    .foregroundStyle(
                                        Color.textPrimary0E101AF4F1FB
                                            .opacity(0.6)
                                    )
                                    .padding(.top, 2)
                            }
                            
                            Spacer()
                            
                            ZStack(alignment: isDefault ? .trailing : .leading) {
                                
                                RoundedRectangle(cornerRadius: 999)
                                    .fill(
                                        isDefault
                                        ? themeManager.accentGradient
                                        : LinearGradient(
                                            colors: [
                                                themeManager.black_white.opacity(0.08)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 44, height: 26)
                                    .shadow(
                                        color: isDefault
                                        ? themeManager.selectedAccent.senColor
                                            .opacity(0.55)
                                        : .clear,
                                        radius: 10
                                    )
                                
                                Circle()
                                    .fill(.white)
                                    .frame(width: 20, height: 20)
                                    .padding(3)
                                    .shadow(
                                        color: themeManager.black_white.opacity(0.3),
                                        radius: 3,
                                        y: 1
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                        .background(themeManager.white_white4)
                        .overlay {
                            
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    Color.textPrimary0E101AF4F1FB
                                        .opacity(0.08),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                GradientBgButton(
                    title       : (isEdit ? "Update" : "Add card"),
                    isSolid     : true,
                    showChevron : false
                ) {
                    addCard()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
                
                Spacer()
            }
            
        }
        .keyboardAdaptive()
        .applyAppBackground()
        .modifier(ToastModifier(toast: toastManager))
        .onChange(of: myCardsVM.isEdit) { value in
            if value == true{
                action()
                goBack()
            }
        }
        .onChange(of: addSubscriptionVM.isAdd) { value in
            if value == true{
                shouldCallAPI = true
                action()
                goBack()
            }
        }
        .onChange(of: addSubscriptionVM.isAddError) { value in
            if addSubscriptionVM.isAddError != nil || addSubscriptionVM.isAddError != ""{
                toastManager.showToast(message: addSubscriptionVM.isAddError ?? "", style: .error)
            }
        }
    }
    
    //MARK: - Button actions
    private func goBack() {
        AppIntentRouter.shared.pop()
    }
    private func addCard() {
        let input = AddCardRequest(userId           : Constants.getUserId(),
                                   cardNumber       : cardNumber.trimmed,
                                   nickName         : nickName.trimmed,
                                   cardHolderName   : cardName.trimmed,
                                   cardType         : selectedType.rawValue,
                                   isDefault        : isDefault)
        
        if let errorMessage = ManualEntryValidations.shared.addCard(input: input) {
            toastManager.showToast(message: errorMessage.localized, style: .error)
        } else {
            if isEdit{
                let input = EditCardRequest(userId          : Constants.getUserId(),
                                            cardId          : cardId,
                                            cardNumber      : cardNumber.trimmed,
                                            nickName        : nickName.trimmed,
                                            cardHolderName  : cardName.trimmed,
                                            cardType        : selectedType.rawValue,
                                            isDefault       : isDefault)
                myCardsVM.editCard(input: input)
            }else{
                addSubscriptionVM.addCard(input: input)
            }
        }
    }
    
    private func updateExpDate() {
        expDate = String(format: "%02d / %02d", selectedMonth, selectedYear % 100)
    }
    
    private var attributedDescription: AttributedString {
        
        var result = AttributedString("We only use this to ")
        result.foregroundColor = .textPrimary0E101AF4F1FB
        
        var streaming = AttributedString("match subscriptions to the right card")
        streaming.font = .geistSemiBold(11)
        streaming.foregroundColor = .textPrimary0E101AF4F1FB
        
        var cycle = AttributedString(". No full numbers, expiry, or CVC needed.")
        cycle.foregroundColor = .textPrimary0E101AF4F1FB
        
        
        result += streaming
        result += cycle
        
        return result
    }
}
