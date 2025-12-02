//
//  SubscriptionPreviewView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 11/11/25.
//

import SwiftUI
import SDWebImageSwiftUI

var globalSubscriptionData                      : SubscriptionData?
var originalImage                               : UIImage? = nil

struct SubscriptionPreviewView: View {
    
    //MARK: - Properties
    @State var isFromImage                      : Bool = false
    @State var subscriptionsData                : [SubscriptionData]?
    @State var numberOfSubscriptions            : Int = 0
    @State var currentSubscriptions             : Int = 1
    @State var subscriptionData                 : SubscriptionData?
    @State var content                          : String = ""
    @State var confidenceStr                    : String = ""
    @State var colorValue                       : Color?
    var confidence                              : Double = 0.0
    @State var showDiscardPopup                 : Bool = false
    @State var initials                         : String  = ""
    @State var showImagePopup                   : Bool = false
    @EnvironmentObject var commonApiVM          : CommonAPIViewModel
    @StateObject var subscriptionPreviewVM      = SubscriptionPreviewViewModel()
    var audioURL                                : URL? = nil
    @StateObject private var playerManager      = AudioRecorderManager()
    @Environment(\.dismiss) private var dismiss
    
    @State var showServiceBottom                : Bool = false
    @State var showAmountBottom                 : Bool = false
    @State var showNextChargeDateBottom         : Bool = false
    @State var showCurrencyBottom               : Bool = false
    @State var showCategoryBottom               : Bool = false
    @State var showPlanTypeBottom               : Bool = false
    @State var showBillingCycleBottom           : Bool = false
    
    //MARK: - body
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
                
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: - Title
                    Text("Review entry \(currentSubscriptions) of \(numberOfSubscriptions)")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    HStack {
                        // MARK: - SubTitle
                        Text("Validate extracted data")
                            .font(.appRegular(18))
                            .foregroundColor(Color.neutral500)
                        
                        if isFromImage == true {
                            Spacer()
                            Button(action: showImage) {
                                HStack(spacing: 4) {
                                    Image("imageicon")
                                        .frame(width: 20, height: 20)
                                    Text("Original")
                                        .font(.appRegular(14))
                                        .foregroundColor(Color.blueMain700)
                                        .underline(true, color: Color.blueMain700)
                                }
                            }
                            .sheet(isPresented: $showImagePopup) {
                                if let image = originalImage {
                                    VStack(spacing: 0) {
                                        OriginalImageView(image: image)
                                            .frame(maxWidth: .infinity)
                                        //                                            .background(Color.white)
                                        //                                            .cornerRadius(50, corners: [.topLeft, .topRight]) // 👈 your custom radius
                                    }
                                    .background(Color.clear)
                                    .presentationDetents([.height(imageHeightForSheet(image))])
                                    .presentationDragIndicator(.hidden)
                                    .ignoresSafeArea(edges: .bottom)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 0)
            
            ScrollView {
                VStack(spacing: 24) {
                    if isFromImage == false {
                        VStack(alignment: .leading, spacing: 8) {
                            
                            Text("Original Content")
                                .foregroundColor(Color.underlineGray)
                                .font(.appRegular(18))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 16)
                                .padding(.horizontal, 16)
                            
                            //                            ScrollView(showsIndicators: true) {
                            //                                Text(content)
                            //                                    .foregroundColor(Color.neutralMain700)
                            //                                    .font(.appRegular(16))
                            //                                    .frame(maxWidth: .infinity, alignment: .leading)
                            //                                    .padding(.horizontal, 16)
                            //                            }
                            //                            .padding(.bottom, 16)
                            
                            VoicePlayerUI(audioManager: playerManager)
                                .padding(.horizontal, 16)
                                .padding(.bottom,16)
                        }
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color.neutral300Border,
                                    style: StrokeStyle(lineWidth: 1, dash: [4])
                                )
                        )
                        .background(Color.whiteNeutralCardBG)
                        .cornerRadius(12)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("Extracted Details")
                                .font(.appRegular(18))
                                .foregroundColor(.underlineGray)
                            Spacer()
                            Button(action: onEditAction) {
                                Text("Edit")
                                    .font(.appBold(18))
                                    .foregroundColor(.underlineGray)
                            }
                            .frame(width: 40, alignment: .trailing)
                        }
                        .frame(height: 28)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 16) {
                                SubscriptionDetailsItem(title: "Service", value: subscriptionData?.serviceName ?? "", confidence: subscriptionData?.serviceNameConfidence ?? 0.0)
                                    .onTapGesture {
                                        showServiceBottom = true
                                    }
                                    .sheet(isPresented: $showServiceBottom) {
                                        ReviewExtractedDetailsView(onDelegate: {
                                        },
                                                                   detailType   : ReviewExtractedType.service,
                                                                   confidence   : subscriptionData?.serviceNameConfidence ?? 0.0,
                                                                   extractedData: subscriptionData)
                                        .presentationDragIndicator(.hidden)
                                        .presentationDetents([.medium, .large])
                                    }
                                
                                SubscriptionDetailsItem(title: "Amount", value: "\(subscriptionData?.currencySymbol ?? "")\(subscriptionData?.amount ?? 0.0)", confidence: subscriptionData?.amountConfidence ?? 0.0)
                                    .onTapGesture {
                                        showAmountBottom = true
                                    }
                                    .sheet(isPresented: $showAmountBottom) {
                                        ReviewExtractedDetailsView(onDelegate: {
                                        },
                                                                   detailType   : ReviewExtractedType.amount,
                                                                   confidence   : subscriptionData?.serviceNameConfidence ?? 0.0,
                                                                   extractedData: subscriptionData)
                                        .presentationDragIndicator(.hidden)
                                        .presentationDetents([.medium, .large])
                                    }
                            }
                            
                            HStack(spacing: 16) {
                                SubscriptionDetailsItem(title: "Next Charge Date", value: (subscriptionData?.nextPaymentDate ?? "").formattedDate(), confidence: subscriptionData?.nextPaymentDateConfidence ?? 0.0)
                                    .onTapGesture {
                                        showNextChargeDateBottom = true
                                    }
                                    .sheet(isPresented: $showNextChargeDateBottom) {
                                        ReviewExtractedDetailsView(onDelegate: {
                                        },
                                                                   detailType   : ReviewExtractedType.nextChargeDate,
                                                                   confidence   : subscriptionData?.serviceNameConfidence ?? 0.0,
                                                                   extractedData: subscriptionData)
                                        .presentationDragIndicator(.hidden)
                                        .presentationDetents([.medium, .large])
                                    }
                                if subscriptionData?.currency ?? "" == ""
                                {
                                    SubscriptionDetailsItem(title: "Currency", value: Constants.shared.currencyCode, confidence: 0.0, isAssumed: true)
                                        .onTapGesture {
                                            showCurrencyBottom = true
                                        }
                                }
                                else{
                                    SubscriptionDetailsItem(title: "Currency", value: subscriptionData?.currency ?? "", confidence: subscriptionData?.currencyConfidence ?? 0.0)
                                        .onTapGesture {
                                            showCurrencyBottom = true
                                        }
                                }
                            }
                            
                            HStack(spacing: 16) {
                                SubscriptionDetailsItem(title: "Category", value: subscriptionData?.categoryName ?? "", confidence: subscriptionData?.categoryConfidence ?? 0.0)
                                    .onTapGesture {
                                        showCategoryBottom = true
                                    }
                                    .sheet(isPresented: $showCategoryBottom) {
                                        ReviewExtractedDetailsView(onDelegate: {
                                        },
                                                                   detailType   : ReviewExtractedType.category,
                                                                   confidence   : subscriptionData?.serviceNameConfidence ?? 0.0,
                                                                   extractedData: subscriptionData)
                                        .presentationDragIndicator(.hidden)
                                        .presentationDetents([.medium, .large])
                                    }
                                SubscriptionDetailsItem(title: "Plan Type", value: subscriptionData?.subscriptionType ?? "", confidence: subscriptionData?.subscriptionTypeConfidence ?? 0.0)
                                    .onTapGesture {
                                        showPlanTypeBottom = true
                                    }
                            }
                            
                            SubscriptionDetailsItem(title: "Billing Cycle", value: subscriptionData?.billingCycle ?? "", confidence: subscriptionData?.billingCycleConfidence ?? 0.0)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("Subscription Match")
                                .font(.appRegular(18))
                                .foregroundColor(.underlineGray)
                            Spacer()
                            Button(action: onViewAction) {
                                Text("View")
                                    .font(.appBold(18))
                                    .foregroundColor(.underlineGray)
                            }
                            .frame(width: 40, alignment: .trailing)
                        }
                        .frame(height: 28)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            
                            HStack(spacing: 12) {
                                
                                //                                if (subscriptionData?.serviceLogo ?? "").isEmpty {
                                //                                    ZStack {
                                //                                        Color.black
                                //                                        Text(initials)
                                //                                            .font(.appBold(16))
                                //                                            .foregroundColor(.blueMain700)
                                //                                    }
                                //                                    .frame(width: 34, height: 34)
                                //                                    .cornerRadius(8)
                                //                                } else {
                                //                                    WebImage(url: URL(string: subscriptionData?.serviceLogo ?? ""))
                                //                                        .resizable()
                                //                                        .scaledToFill()
                                //                                        .frame(width: 34, height: 34)
                                //                                        .cornerRadius(8)
                                //                                        .clipped()
                                //                                }
                                AvatarView(serviceName: subscriptionData?.serviceName ?? "", serviceLogo: subscriptionData?.serviceLogo ?? "", size: 34, fontSize: 16)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(subscriptionData?.serviceName ?? "") \(subscriptionData?.subscriptionType ?? "")")
                                        .font(.appRegular(14))
                                        .foregroundColor(.neutralMain700)
                                    Text(String(format: "%@ • %@%.2f", subscriptionData?.billingCycle ?? "",subscriptionData?.currencySymbol ?? "",subscriptionData?.amount ?? 0.0))
                                        .font(.appRegular(12))
                                        .foregroundColor(.neutral500)
                                }
                                Spacer()
                                Text(confidenceStr)
//                                    .frame(maxWidth: .infinity)
                                    .frame(height: 24)
                                    .font(.appRegular(14))
                                    .foregroundColor(.neutralMain700Gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                    .background(colorValue)
                                    .cornerRadius(8)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text("Amount:")
                                        .font(.appRegular(14))
                                        .foregroundColor(.neutral500)
                                    Spacer()
                                    Text(String(format: "%@%.2f",subscriptionData?.currencySymbol ?? "",subscriptionData?.amount ?? 0.0))
                                        .font(.appBold(14))
                                        .foregroundColor(.blueMain700)
                                }
                                .frame(height: 20)
                                
//                                HStack(spacing: 8) {
//                                    Text("Subscription start:")
//                                        .font(.appRegular(14))
//                                        .foregroundColor(.neutral500)
//                                    Spacer()
//                                    Text("\(subscriptionData?.lastPaymentDate ?? "")".formattedDate())
//                                        .font(.appBold(14))
//                                        .foregroundColor(.blueMain700)
//                                }
//                                .frame(height: 20)
//                                
                                HStack(spacing: 8) {
                                    Text("Next Charge Date:")
                                        .font(.appRegular(14))
                                        .foregroundColor(.neutral500)
                                    Spacer()
                                    Text("\(subscriptionData?.nextPaymentDate ?? "")".formattedDate())
                                        .font(.appBold(14))
                                        .foregroundColor(.blueMain700)
                                }
                                .frame(height: 20)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neutral300Border, lineWidth: 1)
                        )
                        .background(Color.whiteNeutralCardBG)
                        .cornerRadius(12)
                    }
                    
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
                
                VStack(spacing: 10) {
                    if currentSubscriptions == 1
                    {
                        if currentSubscriptions == numberOfSubscriptions
                        {
                            CustomButton(title: "Save", height:50, action: onSaveAction)
                                .padding(.horizontal)
                                .padding(.bottom, 24)
                        }
                        else{
                            CustomButton(title: "Next", height:50, action: onNextAction)
                                .padding(.horizontal)
                                .padding(.bottom, 24)
                        }
                    }
                    else{
                        if currentSubscriptions == numberOfSubscriptions
                        {
                            HStack(spacing: 0) {
                                GradientBorderButton(title: "Previous", action:onPreviousAction, backgroundColor:.whiteBlack)
                                    .padding(.horizontal)
                                CustomButton(title: "Save All", height:50, action: onSaveAction)
                                    .padding(.horizontal)
                            }
                            .padding(.bottom, 24)
                        }
                        else{
                            HStack(spacing: 0)  {
                                GradientBorderButton(title: "Previous", action:onPreviousAction, backgroundColor:.whiteBlack)
                                    .padding(.horizontal)
                                CustomButton(title: "Next", height:50, action: onNextAction)
                                    .padding(.horizontal)
                            }
                            .padding(.bottom, 24)
                        }
                    }
                    
                    Button(action: onDiscardAction) {
                        HStack {
                            Image("IconCross")
                                .frame(width: 20, height: 20)
                            Text("Discard Entry")
                                .font(.appRegular(14))
                                .foregroundColor(Color.disCardRed)
                        }
                    }
                    .sheet(isPresented: $showDiscardPopup) {
                        InfoAlertSheet(
                            onDelegate: {
                                performDeleteAction()
                            }, title    : "Are you sure you want to discard the entry?\nData will be permanently deleted",
                            subTitle    : "",
                            imageName   : "infoIcon",
                            buttonIcon  : "deleteIcon",
                            buttonTitle : "Delete Entry"
                        )
                        .presentationDragIndicator(.hidden)
                        .presentationDetents([.height(380)])
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 6)
                .padding(.vertical, 24)
            }
            
        }
        .padding(.top, 10)
        .background(.neutralBg100)
        .navigationBarBackButtonHidden(true)
        .onAppear{
            //            commonApiVM.getCurrencies()
            getSubDetails()
            numberOfSubscriptions = subscriptionsData?.count ?? 0
            getSubDetails()
            if !isFromImage{
                guard let url = audioURL else {
                    return
                }
                playerManager.load(url: url)
            }
        }
        .onChange(of: globalSubscriptionData) { _ in updateSubDetails() }
        .onChange(of: commonApiVM.currencyResponse) { _ in getSubDetails() }
        .onChange(of: subscriptionPreviewVM.isEntrySuccess) { _ in
            self.addSubApiResponseHandling()
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            showImagePopup = false
            showDiscardPopup = false
        }
        .sheet(isPresented: $showCurrencyBottom) {
            ReviewExtractedDetailsView(onDelegate: {
            },
                                       detailType   : ReviewExtractedType.currency,
                                       confidence   : subscriptionData?.serviceNameConfidence ?? 0.0,
                                       extractedData: subscriptionData)
            .presentationDragIndicator(.hidden)
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showPlanTypeBottom) {
            ReviewExtractedDetailsView(onDelegate: {
            },
                                       detailType   : ReviewExtractedType.planType,
                                       confidence   : subscriptionData?.serviceNameConfidence ?? 0.0,
                                       extractedData: subscriptionData)
            .presentationDragIndicator(.hidden)
            .presentationDetents([.medium, .large])
        }
    }
    
    //MARK: - addSubApiRespons
    private func addSubApiResponseHandling() {
        if subscriptionPreviewVM.isEntrySuccess == true{
            if subscriptionPreviewVM.addSubscriptionResponse != nil{
                
                let duplicates =  subscriptionPreviewVM.addSubscriptionResponse!.duplicates ?? []
                if duplicates.count > 0
                {
                    var updatedDuplicates: [DuplicateDataInfo] = []
                    
                    for (index, item) in duplicates.enumerated() {
                        
                        var newSubs = item.newSubscription ?? []
                        for i in 0..<newSubs.count {
                            let currentID = newSubs[i].id ?? ""
                            if currentID.isEmpty {
                                newSubs[i].id = "\(i + 1)"
                            }
                        }
                        
                        let oldSubs = item.oldSubscription
                        let name: String? = newSubs.first?.serviceName ?? ""
                        
                        let info = DuplicateDataInfo(
                            id: String(index + 1),
                            serviceName: name,
                            newSubscriptions: newSubs,
                            existingSubscriptions: oldSubs
                        )
                        
                        updatedDuplicates.append(info)
                    }
                    isFromAdd = true
                    AppIntentRouter.shared.navigate(to: .duplicateSubscriptionsView(duplicateSubsList: updatedDuplicates))
                }
                else{
                    //                AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
                    AppIntentRouter.shared.navigate(to: .subscriptionsListView)
                }
            }
            else{
                //            AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
                AppIntentRouter.shared.navigate(to: .subscriptionsListView)
            }
        }
    }
    
    private func imageHeightForSheet(_ image: UIImage) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 40
        let aspectRatio = image.size.height / image.size.width
        let imageHeight = screenWidth * aspectRatio
        // Add some padding + capsule area
        return imageHeight + 150
    }
    
    func updateSubDetails()
    {
        if globalSubscriptionData != nil {
            subscriptionsData?[currentSubscriptions-1] = globalSubscriptionData!
            subscriptionData = globalSubscriptionData!
            getSubDetails()
        }
    }
    
    func getSubDetails()
    {
        if numberOfSubscriptions > 0
        {
            subscriptionData = subscriptionsData?[currentSubscriptions-1]
            
            let (confidenceStr1, colorValue1) = Constants.confidenceInfo(isAssumed: false, confidence: subscriptionData?.confidenceOverall ?? 0.0)
            confidenceStr = confidenceStr1
            colorValue = colorValue1
            
            //            let serviceName = subscriptionData?.serviceName ?? ""
            //            let words = serviceName
            //                .split(separator: " ")
            //                .filter { !$0.isEmpty }
            //
            //            if words.count == 1 {
            //                initials = String(words[0].prefix(1)).uppercased()
            //            } else {
            //                initials = words.prefix(2)
            //                    .map { String($0.prefix(1)).uppercased() }
            //                    .joined()
            //            }
            
            updateCountryAndCurrency()
        }
    }
    
    //MARK: - updateCountryAndCurrency
    func updateCountryAndCurrency() {
        if let currencies = commonApiVM.currencyResponse {
            let selectedCurrency = currencies.first(where: { $0.code == subscriptionData?.currency ?? Constants.shared.currencyCode })
            /*if selectedCurrency == nil{
             selectedCurrency = Currency(id      : nil,
             name    : Constants.shared.currencyCode,
             symbol  : Constants.shared.currencySymbol,
             code    : Constants.shared.currencyCode,
             flag    : Constants.shared.flag(from: Constants.shared.regionCode))
             }*/
            subscriptionData?.currencySymbol = selectedCurrency?.symbol
            subscriptionsData?[currentSubscriptions-1] = subscriptionData!
        }else{
            commonApiVM.getCurrencies()
        }
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
    
    private func showImage() {
        showImagePopup = true
    }
    
    private func onEditAction() {
        if numberOfSubscriptions > 0
        {
            globalSubscriptionData = subscriptionData!
            AppIntentRouter.shared.navigate(to: .manualEntry(isFromEdit: true))
        }
    }
    
    private func onViewAction() {
        if numberOfSubscriptions > 0
        {
            if subscriptionData != nil {
                subscriptionData?.notes = subscriptionData?.reason
                globalSubscriptionData = subscriptionData!
                AppIntentRouter.shared.navigate(to: .subscriptionMatchView(subscriptionData: subscriptionData!))
            }
        }
    }
    
    private func onNextAction() {
        if let errorMessage = ManualEntryValidations.shared.updateManualEntry(input: subscriptionData!) {
            ToastManager.shared.showToast(message: errorMessage,style:ToastStyle.error)
        }
        else{
            currentSubscriptions = currentSubscriptions + 1
            if currentSubscriptions >= numberOfSubscriptions
            {
                currentSubscriptions = numberOfSubscriptions
            }
            getSubDetails()
        }
        
    }
    
    private func onPreviousAction() {
        
        /*if let errorMessage = ManualEntryValidations.shared.updateManualEntry(input: subscriptionData!) {
         ToastManager.shared.showToast(message: errorMessage,style:ToastStyle.error)
         }
         else{*/
        currentSubscriptions = currentSubscriptions - 1
        if currentSubscriptions <= 1
        {
            currentSubscriptions = 1
        }
        getSubDetails()
        // }
    }
    
    private func onSaveAction() {
        if numberOfSubscriptions > 0
        {
            if let errorMessage = ManualEntryValidations.shared.updateManualEntry(input: subscriptionData!) {
                ToastManager.shared.showToast(message: errorMessage,style:ToastStyle.error)
            }
            else {
                //source -> 1- manual, 2 - voice, 3 - image, 4 - email
                var source = 2
                if isFromImage == true
                {
                    source = 3
                }
                var subsctionsArray: [ConfirmedSubscription] = []
                for i in 0..<subscriptionsData!.count
                {
                    let objc = subscriptionsData![i]
                    var currency = (objc.currency ?? "" == "") ? Constants.shared.currencyCode : (objc.currency ?? "")
                    let subObjc = ConfirmedSubscription(serviceName         : objc.serviceName ?? "",
                                                        serviceLogo         : objc.serviceLogo ?? "",
                                                        amount              : objc.amount ?? 0.0,
                                                        currency            : currency,//objc.currency ?? "",
                                                        billingCycle        : objc.billingCycle ?? "",
                                                        nextPaymentDate     : (objc.nextPaymentDate ?? "").formattedDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd"),
                                                        subscriptionType    : objc.subscriptionType ?? "",
                                                        paymentMethod       : objc.paymentMethodId ?? "",
                                                        paymentMethodDataId : objc.paymentMethodDataId ?? "",
                                                        category            : objc.categoryId ?? "",
                                                        subscriptionFor     : objc.subscriptionFor ?? Constants.getUserId(),
                                                        renewalReminder     : objc.renewalReminder ?? [],
                                                        notes               : objc.reason ?? "",
                                                        currencySymbol      : objc.currencySymbol ?? "",
                                                        source              : source)
                    subsctionsArray.append(subObjc)
                }
                let input = PendingSubscriptionConfirmRequest(userId: Constants.getUserId(), confirmedSubscription: subsctionsArray)
                subscriptionPreviewVM.updateSubscriptions(input: input)
            }
        }
    }
    
    private func onDiscardAction() {
        if numberOfSubscriptions > 0
        {
            showDiscardPopup = true
        }
    }
    
    private func performDeleteAction() {
        if numberOfSubscriptions < 2
        {
            dismiss()
        }
        else{
            subscriptionsData?.remove(at: currentSubscriptions-1)
            numberOfSubscriptions = subscriptionsData?.count ?? 0
            if currentSubscriptions <= 1
            {
                currentSubscriptions = 1
            }
            if currentSubscriptions >= numberOfSubscriptions
            {
                currentSubscriptions = numberOfSubscriptions
            }
            //currentSubscriptions = 1
            getSubDetails()
        }
    }
}

//MARK: - SubscriptionDetailsItem
struct SubscriptionDetailsItem: View {
    var title                   : String
    var value                   : String?
    var confidence              : Double = 0.0
    var isAssumed               : Bool = false
    
    @State var confidenceStr    : String = ""
    @State var colorValue       : Color?
    
    var body: some View {
        let (confidenceStr, colorValue) = Constants.confidenceInfo(isAssumed: isAssumed, confidence: confidence)
        
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 9) {
                Text(title)
                    .font(.appRegular(14))
                    .foregroundColor(.neutral500)
                
                Text(value ?? "")
                    .font(.appBold(16))
                    .foregroundColor(.neutralMain700)
                
                Text(confidenceStr)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                    .font(.appRegular(14))
                    .foregroundColor(.neutralMain700Gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .background(colorValue)
                    .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .frame(height: 106)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .background(.whiteNeutralCardBG)
        .cornerRadius(12)
    }
}

//MARK: - VoicePlayerUI
struct VoicePlayerUI: View {

    @ObservedObject var audioManager: AudioRecorderManager

    var body: some View {
        HStack(spacing: 5) {
            
            Button(action: {
                if audioManager.isPlaying {
                    audioManager.pausePlayback()
                } else {
                    audioManager.playRecording()
                }
            }) {
                Image(audioManager.isPlaying ? "Pause" : "Play")
                    .frame(width: 40, height: 40)
            }

            Slider(value: Binding(
                get: { audioManager.currentTime },
                set: { newValue in
                    audioManager.currentTime = newValue
                    audioManager.audioPlayer?.currentTime = newValue
                }
            ), in: 0...audioManager.duration)
            .tint(.navyBlueCTA700)

            Text("\(formatTime(TimeInterval(Int(audioManager.currentTime)))) / \(formatTime(TimeInterval(Int(audioManager.duration))))")
                .font(.appRegular(14))
                .foregroundStyle(Color.whiteBlackBGnoPic)

            Spacer()
        }
    }
}
