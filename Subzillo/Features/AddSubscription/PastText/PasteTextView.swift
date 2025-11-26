//
//  PasteTextView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 13/11/25.
//

import SwiftUI

struct PasteTextView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var textValue                    : String = ""//"Hello, i have taken Netflix premium auto renuwal subscription for quarterly using my moms debit card and i have paid 12.99 USD on 1st November 2025 also i have taken another subscription for monthly using my dads credit card and i have paid 11.99"
    @StateObject var voiceCommandVM         = VoiceCommandViewModel()
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: goBack) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                Text("Paste Text")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.top, 0)
            
            Text("Copy and paste notification text to automatically detect subscription payments")
                .font(.appRegular(18))
                .foregroundColor(Color.neutral500)
                .padding(.leading, 52)
                .padding(.trailing, 20)
            
            VStack {
                //  ScrollView(showsIndicators: false) {
                
                if textValue.isEmpty {
                    Text("Paste here")
                        .background(Color.clear)
                        .font(.appRegular(14))
                        .foregroundColor(.neutral500)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                TextEditor(text: $textValue)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .keyboardType(.default)
                    .autocapitalization(.none)
                    .font(.appRegular(14))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, -5)
                    .padding(.top, -8)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                hideKeyboard()
                            }
                        }
                    }
                    .offset(x: 0, y: textValue.isEmpty ? -25 : 0)
                //}
                
                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(height: 148)
            //            .overlay(
            //                RoundedRectangle(cornerRadius: 12)
            //                    .stroke(Color.neutral2200, lineWidth: 1)
            //            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral300Border, lineWidth: 1)
            )
            .background(Color.whiteNeutralCardBG)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 18);
            
            CustomButton(title: "Submit", action: onSubmit)
                .padding(.horizontal, 16)
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 10)
        .background(.neutralBg100)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $voiceCommandVM.showErrorPopup) {
            InfoAlertSheet(
                onDelegate: {
                    voiceCommandVM.showErrorPopup = false
                    self.textValue = ""
                },
                title       : "Couldn’t Understand That",
                subTitle    : "The text you pasted isn’t clear. Please check and try again.",
                imageName   : "pastErrorIcon",
                buttonIcon  : "tryIcon",
                buttonTitle : "Try Again"
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(380)])
        }
        
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
    
    private func onSubmit() {
        if textValue != ""
        {
            hideKeyboard()
            let input = VoiceSubscriptionRequest(userId: Constants.getUserId(), text: textValue)
            voiceCommandVM.voiceSubscription(input: input)
        }
        else
        {
            ToastManager.shared.showToast(message: "Please paste text.", style: ToastStyle.error)
        }
    }
}
