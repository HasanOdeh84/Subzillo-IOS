//
//  reviewExtractedDetailsView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 02/12/25.
//

import SwiftUI

struct ReviewExtractedDetailsView: View {
    
    //MARK: - Properties
    var onDelegate: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    var title                               : String? = "Review Extracted Details"
    var detailType                          : ReviewExtractedType = .currency
    var buttonIcon                          : String? = "update"
    var buttonTitle                         : String? = "Update"
    var confidence                          : Double = 0.0
    var isAssumed                           : Bool = false
    
    var extractedData                       : SubscriptionData?
    
    @State private var selectedCurrency     : Currency?
    @EnvironmentObject var commonApiVM      : CommonAPIViewModel
    
    @State private var serviceName          : String = ""
    
    @State private var category             : String = ""
    @State var selectedCategory             : Category?
    @State private var showCategorySheet    = false
    
    @State private var amount               : String = ""
    
    @State private var planType             : String = ""
    
    @State private var isDatePickerPresented    = false
    @State private var tempDate                 = Date()
    @State private var chargeDate               : String = ""
    
    //MARK: - body
    var body: some View {
        let (confidenceStr, colorValue) = Constants.confidenceInfo(isAssumed: isAssumed, confidence: confidence)
        
        VStack(alignment: .center) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top,24)
                .padding(.horizontal, -5)
            
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(24))
                .foregroundStyle(.neutralMain700)
                .multilineTextAlignment(.center)
                .padding(.top,24)
                .padding(.horizontal, -5)
            
            Text(confidenceStr)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .font(.appRegular(14))
                .foregroundColor(.neutralMain700)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .background(colorValue)
                .cornerRadius(4)
                .padding(.top,3)
                .padding(.bottom,36)
                .padding(.horizontal, -5)
            
            switch detailType {
            case .service:
                FieldView(text: $serviceName, title: "Service Name", image: "gridIcon", placeHolder: "e.g. Netflix, Spotify, Adobe")
                    .addDoneButton()
            case .amount:
                FieldView(text: $amount, title: "Amount", image: "currencyIcon", placeHolder: "0.00",isNumberPad: true)
            case .nextChargeDate:
                Button(action: dateSelection) {
                    FieldView(text: $chargeDate, textValue: "", title: "Next Charge Date", image: "Calendar1", placeHolder: "dd/mm/yyyy", isButton: false, isText: true, isDate:true)
                }
                .background(
                    DatePickerPopup(isPresented: $isDatePickerPresented, selectedDate: $tempDate) { date in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd/MM/yyyy"//"yyyy-MM-dd"
                        self.chargeDate = formatter.string(from: date)
                        print(chargeDate)
                    }
                )
            case .currency:
                PhoneNumberField(phoneNumber        : .constant(""),
                                 header             : "Your payment currency",
                                 placeholder        : selectedCurrency?.name,
                                 selectedCurrency   : $selectedCurrency,
                                 selectedCountry    : .constant(nil),
                                 isCountry          : false,
                                 fromPreview        : true)
            case .category:
                Button(action: selectCategory) {
                    FieldView(text: $category, textValue: selectedCategory?.name ?? "", title: "Category", image: "gridIcon", placeHolder: "Please select", isButton: true, isText: true)
                }
                .sheet(isPresented: $showCategorySheet) {
                    CategoriesBottomSheet(selectedCategory: $selectedCategory, categoryResponse:commonApiVM.categoriesResponse, header: "Select Category", placeholder: "Search Category")
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                }
            case .planType:
                FieldView(text: $planType, title: "Plan Type", image: "gridicon2", placeHolder: "e.g. Free, Pro, Premium")
            case .billingCycle:
                Button(action: dateSelection) {
                    FieldView(text: $chargeDate, textValue: "", title: "Next Charge Date", image: "Calendar1", placeHolder: "dd/mm/yyyy", isButton: false, isText: true, isDate:true)
                }
                .background(
                    DatePickerPopup(isPresented: $isDatePickerPresented, selectedDate: $tempDate) { date in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd/MM/yyyy"//"yyyy-MM-dd"
                        self.chargeDate = formatter.string(from: date)
                        print(chargeDate)
                    }
                )
            }
            
            GradientBorderButton(title          : buttonTitle ?? "",
                                 isBtn          : true,
                                 buttonImage    : buttonIcon ?? "") {
                switch detailType {
                case .service:
                    globalSubscriptionData?.serviceName = serviceName.trimmed
                case .amount:
                    globalSubscriptionData?.amount = Double(amount.trimmed) ?? 0.0
                case .nextChargeDate:
                    globalSubscriptionData?.nextPaymentDate = chargeDate
                case .currency:
                    globalSubscriptionData?.currency = selectedCurrency?.code ?? ""
                    globalSubscriptionData?.currencySymbol = selectedCurrency?.symbol ?? ""
                case .category:
                    globalSubscriptionData?.categoryId = category
                    globalSubscriptionData?.categoryName = selectedCategory?.name ?? ""
                case .planType:
                    globalSubscriptionData?.subscriptionType = planType.trimmed
                case .billingCycle:
                    globalSubscriptionData?.subscriptionType = planType.trimmed
//                    globalSubscriptionData?.billingCycle = billingCycle.lowercased()
                }
                onDelegate?()
                dismiss()
            }
                                 .padding(.vertical,36)
                                 .padding(.horizontal, -5)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear{
            if detailType == .category{
                commonApiVM.getCategories()
            }else if detailType == .currency{
                selectedCurrency = Currency(id      : nil,
                                            name    : Constants.shared.currencyCode,
                                            symbol  : Constants.shared.currencySymbol,
                                            code    : Constants.shared.currencyCode,
                                            flag    : Constants.shared.flag(from: Constants.shared.regionCode))
                if let data = commonApiVM.currencyResponse {
                    selectedCurrency = data.first(where: { $0.code == Constants.shared.currencyCode })
                }else{
                    commonApiVM.getCurrencies()
                }
            }
            setupData()
        }
        .onChange(of: commonApiVM.categoriesResponse) { _ in updateCatInfo() }
    }
    
    //MARK: - User defined methods
    private func selectCategory()
    {
        showCategorySheet = true
    }
    
    private func dateSelection() {
        withAnimation(.easeInOut) {
            isDatePickerPresented = true
        }
    }
    
    private func updateCatInfo() {
        if globalSubscriptionData?.categoryId ?? "" != "" {
            if let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first(where: { $0.id == globalSubscriptionData?.categoryId ?? ""})
            }
        }
        if category != ""
        {
            if let categories = commonApiVM.categoriesResponse {
                selectedCategory = categories.first(where: { $0.name?.lowercased() == category.lowercased()})
            }
        }
    }
    
    func setupData(){
        serviceName = extractedData?.serviceName ?? ""
        amount      = "\(extractedData?.amount ?? 0.0)"
        chargeDate  = extractedData?.nextPaymentDate ?? ""
        if extractedData?.currency ?? "" != ""{
            if let currencies = commonApiVM.currencyResponse {
                selectedCurrency = currencies.first(where: { $0.code == extractedData?.currency ?? ""})
            }
        }
        category    = extractedData?.categoryName ?? ""
        planType    = extractedData?.subscriptionType ?? ""
    }
}

#Preview {
    ReviewExtractedDetailsView()
}
