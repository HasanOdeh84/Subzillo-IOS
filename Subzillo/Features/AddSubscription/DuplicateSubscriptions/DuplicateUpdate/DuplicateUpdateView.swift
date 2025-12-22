//
//  DuplicateUpdateView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 19/11/25.
//

import SwiftUI
import UIKit

struct DuplicateUpdateView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State var duplicateSubsList            : DuplicateDataInfo?
    @State var selectedIndex                : Int = 0
    @State private var existingSubIndex     : Int = 0//-1
    @StateObject var dupSubscriptionVM      = DuplicateSubscriptionsViewModel()
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            // MARK: - Header
            HStack(spacing: 8) {
                HStack{
                    Button(action: goBack) {
                        HStack {
                            Image("back_gray")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Text("Duplicate Found")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.clear)
            //            .background(Color.white.ignoresSafeArea(edges: .top))
            //            .shadow(color: Color.dropShadowColor1, radius: 2, x: 0, y: 2)
            
            ScrollView(showsIndicators: false) {
                Button(action: goToDetials) {
                    SubOldItem(item: duplicateSubsList?.newSubscriptions![selectedIndex], isNew: true)
                        .padding(.bottom, 24)
                        .padding(.top, 16)
                }
                
                Text("Update with")
                    .font(.appRegular(16))
                    .foregroundColor(Color.neutralMain700)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 0) {
                    List {
                        ForEach(Array((duplicateSubsList?.existingSubscriptions!.enumerated())!), id: \.offset) { index, objc in
                            VStack(spacing: 0) {
                                rowView(for: objc, at: index)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }
                    .scrollDisabled(true)
                    .listStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .scrollContentBackground(.hidden)
                    .frame(height: getCellHeight())
                    .background(.clear)
                }
                
                CustomButton(title: "Update Existing Subscription", buttonImage: "settingsicon", action: onUpdateAction)
                    .padding(.top, 10)
                
                GradientBorderButton(title: "Keep All Subscriptions", isBtn: true, buttonImage: "keepIcon", action: onKeepAction, backgroundColor: .whiteBlack)
                    .padding(.vertical, 10)
            }
            .padding(.horizontal, 19.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
        .background(.neutralBg100)
        .onChange(of: dupSubscriptionVM.subscriptioIds) { _ in
            self.handleApiResponse()
            //AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
            //dismiss()
        }
    }
    
    //MARK: - User defined methods
    //MARK: handleApiResponse
    private func handleApiResponse() {
        // print(dupSubscriptionVM.subscriptioIds?.subscriptionIds)
        let ids = dupSubscriptionVM.subscriptioIds?.subscriptionIds ?? []
        if ids.count > 0 {
            modifiedDuplicateDataInfo?.subscriptionIds = ids
        }
        if duplicateDataCount == 1
        {
            if modifiedDuplicateDataInfo!.originalData?.newSubscriptions!.count == 1
            {
                //                if isFromAdd == true {
                //                    AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
                //                }
                //                else{
                //                    AppIntentRouter.shared.navigate(to: .subscriptionsListView)
                //                }
                modifiedDuplicateDataInfo = nil
                AppIntentRouter.shared.navigate(to: .subscriptionsListView)
            }
            else{
                dismiss()
            }
        }
    }
    
    //MARK: getCellHeight
    private func getCellHeight() -> CGFloat {
        let count = duplicateSubsList?.existingSubscriptions?.count ?? 0
        let height = 118 * count
        return CGFloat(height)
    }
    
    //MARK: rowView
    @ViewBuilder
    private func rowView(for objc: SubscriptionInfo, at index: Int) -> some View {
        let isSelected = index == existingSubIndex ? true : false
        SubOldItem(item: objc, isNew: false, isSelected: isSelected, showSelection: true) { data, type in
            if type == "check"
            {
                selectedAction(at: index)
            }
            else if type == "click"
            {
                AppIntentRouter.shared.navigate(to: .duplicateSubDetailsView(subscriptionData: data))
            }
        }
        /*
         return SubOldItem(item: objc, isNew:false, isSelected:isSelected, showSelection:true)
         .onTapGesture {
         selectedAction(at: index)
         }*/
    }
    
    //MARK: makeApiCall
    func makeApiCall(action:Int, existingSubscription:String, newSubscriptions:[SubscriptionInfo])
    {
        let inoput = ResolveDuplicateSubscriptionRequest(userId: Constants.getUserId(),
                                                         action: action,
                                                         existingSubscription: existingSubscription,
                                                         newSubscriptions: newSubscriptions)
        dupSubscriptionVM.resolveDuplicateSubscription(input: inoput)
    }
    
    //MARK: - Button actions
    //MARK: goBack
    private func goBack() {
        dismiss()
    }
    
    //MARK: goToDetials
    private func goToDetials() {
        AppIntentRouter.shared.navigate(to: .duplicateSubDetailsView(subscriptionData: duplicateSubsList?.newSubscriptions![selectedIndex]))
    }
    
    //MARK: onUpdateAction
    private func onUpdateAction() {
        if existingSubIndex != -1 {
            var newItem = duplicateSubsList!.newSubscriptions![selectedIndex]
            let existingItem = duplicateSubsList!.existingSubscriptions![existingSubIndex]
            let newObject = ModifiedDuplicateDataInfo(originalData: duplicateSubsList, selectedIndexs: [selectedIndex], selectedData: [newItem], selectedExistingData: existingItem)
            modifiedDuplicateDataInfo = newObject
            if isFromAdd == true {
                newItem.id = ""
            }
            self.makeApiCall(action: 1, existingSubscription: existingItem.id!, newSubscriptions: [newItem])
            //dismiss()
            // AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
        }
        else{
            ToastManager.shared.showToast(message: "Please select existing subscription",style:ToastStyle.error)
        }
    }
    
    //MARK: onKeepAction
    private func onKeepAction() {
        var newItem = duplicateSubsList!.newSubscriptions![selectedIndex]
        let newObject = ModifiedDuplicateDataInfo(originalData: duplicateSubsList, selectedIndexs: [selectedIndex], selectedData: [newItem], isKeepAll: true)
        modifiedDuplicateDataInfo = newObject
        if isFromAdd == true {
            newItem.id = ""
        }
        self.makeApiCall(action: 2, existingSubscription: "", newSubscriptions: [newItem])
        // dismiss()
        // AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
    }
    
    //MARK: selectedAction
    private func selectedAction(at index: Int) {
        existingSubIndex = index
    }
}

//MARK: - SubOldItem view
struct SubOldItem: View {
    
    //MARK: - Properties
    var item            : SubscriptionInfo!
    var isNew           : Bool = false
    var isSelected      : Bool = false
    var showSelection   : Bool = false
    var onDelegate: ((_ data:SubscriptionInfo, _ type:String) -> Void)?
    
    //MARK: - body
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 6) {
                if showSelection == true
                {
                    VStack(alignment: .leading) {
                        Image(isSelected == true ? "SelectedRadio" : "UnSelectedRadio")
                            .frame(width: 24, height: 24)
                            .offset(x: 0, y: -5)
                    }
                    .onTapGesture {
                        checkBtnAction()
                    }
                }
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 10) {
                        Text("\(item.serviceName ?? "") \(item.subscriptionType ?? "")")
                            .font(.appRegular(16))
                            .foregroundColor(.neutralMain700)
                        Spacer()
                        Text(isNew == true ? "New" : "Existing")
                            .font(.appRegular(12))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(isNew == true ? .linearGradient3 : .blueMain700)
                            .frame(height: 24)
                            .cornerRadius(4)
                    }
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 9) {
                            Text("Next charge: \(item.nextPaymentDate ?? "")")
                                .font(.appRegular(12))
                                .foregroundColor(.neutral500)
                            Text(String(format: "%@%.2f • %@", item?.currencySymbol ?? "",item?.amount ?? 0.00,item?.billingCycle ?? ""))
                                .font(.appRegular(16))
                                .foregroundColor(.neutralMain700)
                        }
                        Spacer()
                    }
                }
                .frame(height: 24)
                .padding(.vertical, 16)
                .onTapGesture {
                    clickBtnAction()
                }
            }
        }
        .frame(height: 108)
        .padding(.horizontal, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .background(.whiteNeutralCardBG)
        .cornerRadius(8)
        .padding(.bottom, 10)
    }
    
    //MARK: - Button actions
    //MARK: clickBtnAction
    private func clickBtnAction() {
        onDelegate?(item, "click")
    }
    
    //MARK: checkBtnAction
    private func checkBtnAction() {
        onDelegate?(item, "check")
    }
}

//MARK: - DuplicateUpdateDelegateBox
final class DuplicateUpdateDelegateBox {
    let action: (ModifiedDuplicateDataInfo) -> Void
    init(_ action: @escaping (ModifiedDuplicateDataInfo) -> Void) {
        self.action = action
    }
}
