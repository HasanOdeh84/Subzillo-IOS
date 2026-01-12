//
//  CurrencyBottomSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 27/10/25.
//
import SwiftUI
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
    @Binding var shouldCallAPI              : Bool
    @State var isEdit                       = false
    @State var cardId                       = ""
    var action                              : () -> Void = {}
    
    //MARK: - body
    var body: some View {
        VStack {
            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.grayCapsule)
                    .frame(width: 150, height: 5)
                
                Text(LocalizedStringKey(isEdit ? "Edit card" : "Add new card"))
                    .font(.appRegular(24))
                    .foregroundColor(.neutralMain700)
                
                FieldView(text: $nickName, title: "Card Nickname", image: "Calendar2", placeHolder: "Nickname")
                    .onChange(of: nickName) { newValue in
                        if newValue.count > 15 {
                            nickName = String(newValue.prefix(15))
                            toastManager.showToast(message: "Card Nickname cannot exceed 15 characters",style:ToastStyle.error)
                        }
                    }
                FieldView(text: $cardNumber, title: "Card number", image: "cardNumberIcon", placeHolder: "Number Card", maxDigits: 4, isNumberPad: true, isCardNo: true)
                FieldView(text: $cardName, title: "Name of the card", image: "profile", placeHolder: "Name")
                
                /*HStack(spacing: 24) {
                 
                 Button(action: {
                 showExpiryPopup = true
                 }) {
                 FieldView(text: $expDate, textValue: expDate, title: "Amount", image: "expDateIcon", placeHolder: "MM / YY", isText:  true)
                 }
                 .sheet(isPresented: $showExpiryPopup) {
                 CustomCalenderSheet(
                 isPresented: $showExpiryPopup,
                 selectedMonth: Binding(
                 get: { selectedMonth },
                 set: { month in
                 selectedMonth = month
                 updateExpDate()
                 }
                 ),
                 selectedYear: Binding(
                 get: { selectedYear },
                 set: { year in
                 selectedYear = year
                 updateExpDate()
                 }
                 )
                 )
                 .presentationDetents([.height(300)])
                 .presentationDragIndicator(.hidden)
                 }
                 
                 SecureCCVField(ccv: $ccv, title: "CCV", placeHolder: "***", maxDigits: 3)
                 .frame(width: 120, alignment: .trailing)
                 }
                 */
            }
            .padding(20)
            
            GradientBorderButton(title: (isEdit ? "Update" : "Add card"),isBtn:true, buttonImage: (isEdit ? "update" : "addCardIcon"), action:addCard)
                . padding(.horizontal)
            
            Spacer()
        }
        .fixedSize(horizontal: false, vertical: true)
        .modifier(ToastModifier(toast: toastManager))
        .onChange(of: myCardsVM.isEdit) { value in
            if value == true{
                action()
                dismiss()
            }
        }
        .onChange(of: addSubscriptionVM.isAdd) { value in
            if value == true{
                shouldCallAPI = true
                action()
                dismiss()
            }
        }
    }
    
    //MARK: - Button actions
    private func addCard() {
        let input = AddCardRequest(userId           : Constants.getUserId(),
                                   cardNumber       : cardNumber.trimmed,
                                   nickName         : nickName.trimmed,
                                   cardHolderName   : cardName.trimmed)
        if let errorMessage = ManualEntryValidations.shared.addCard(input: input) {
            toastManager.showToast(message: errorMessage,style:ToastStyle.error)
        } else {
            if isEdit{
                let input = EditCardRequest(userId          : Constants.getUserId(),
                                            cardId          : cardId,
                                            cardNumber      : cardNumber.trimmed,
                                            nickName        : nickName.trimmed,
                                            cardHolderName  : cardName.trimmed)
                myCardsVM.editCard(input: input)
            }else{
                addSubscriptionVM.addCard(input: input)
            }
        }
    }
    
    private func updateExpDate() {
        expDate = String(format: "%02d / %02d", selectedMonth, selectedYear % 100)
    }
}
