//
//  DuplicateSubscriptionsView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 19/11/25.
//

import SwiftUI
import UIKit

var modifiedDuplicateDataInfo  : ModifiedDuplicateDataInfo?
var duplicateDataCount         : Int?
var isFromAdd                  : Bool?

struct DuplicateSubscriptionsView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var originalDataList  = [DuplicateDataInfo]()
    @State private var updatedList       = [ModifiedDuplicateDataInfo]()
    @State var duplicateSubsList         : [DuplicateDataInfo]
    @StateObject var dupSubscriptionVM   = DuplicateSubscriptionsViewModel()
    @State var fromFamily                = false
    @State var isFromEmail               : Bool = false
    
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
                    
                    Button(action: skipAll) {
                        Text("Skip All")
                            .font(.appBold(16))
                            .foregroundColor(Color.neutralMain700)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.clear)
            //            .background(Color.white.ignoresSafeArea(edges: .top))
            //            .shadow(color: Color.dropShadowColor1, radius: 2, x: 0, y: 2)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(Array(duplicateSubsList.enumerated()), id: \.offset) { index, objc in
                        rowView(for: objc, at: index)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .background(.clear)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
        .background(.neutralBg100)
        .onAppear{
            //duplicateSubsList = duplicateSubsListSample
            //originalDataList = duplicateSubsList
            updateDetails()
        }
        .onChange(of: dupSubscriptionVM.subscriptioIds) { _ in
            
            if duplicateSubsList.count == 0
            {
                //                if isFromAdd == true {
                //                    AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
                //                }
                //                else{
                //                    AppIntentRouter.shared.navigate(to: .subscriptionsListView)
                //                }
                if fromFamily{
                    //                    AppIntentRouter.shared.navigate(to: .familyMembersView)
                    AppIntentRouter.shared.pop(count: 2)
                }else{
                    AppIntentRouter.shared.navigate(to: .subscriptionsListView())
                }
            }
            // print(dupSubscriptionVM.subscriptioIds)
            //AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
            //dismiss()
        }
        // .onChange(of: modifiedDuplicateDataInfo) { _ in updateDetails() }
    }
    
    private func updateDetails()
    {
        if modifiedDuplicateDataInfo != nil
        {
            //print(modifiedDuplicateDataInfo!)
            let ids = modifiedDuplicateDataInfo!.subscriptionIds ?? []
            
            if (modifiedDuplicateDataInfo!.isKeepAll ?? false) == true
            {
                if modifiedDuplicateDataInfo!.originalData?.newSubscriptions!.count == 1
                {
                    updatedList.append(modifiedDuplicateDataInfo!)
                    duplicateSubsList.removeAll { $0.id == modifiedDuplicateDataInfo!.originalData?.id }
                }
                else{
                    guard
                        let modified = modifiedDuplicateDataInfo,
                        var originalData = modified.originalData,
                        var newItems = originalData.newSubscriptions,
                        var oldItems = originalData.existingSubscriptions
                    else { return }
                    
                    var newItem = modified.selectedData![0]
                    
                    newItems.removeAll { $0.id == newItem.id }
                    if ids.count > 0 {
                        newItem.id = ids[0]
                    }
                    oldItems.append(newItem)
                    originalData.newSubscriptions = newItems
                    originalData.existingSubscriptions = oldItems
                    
                    updatedList.append(modifiedDuplicateDataInfo!)
                    
                    if let updatedData = modifiedDuplicateDataInfo?.originalData,
                       let index = duplicateSubsList.firstIndex(where: { $0.id == updatedData.id }) {
                        duplicateSubsList[index] = originalData
                    }
                }
            }
            else{
                if modifiedDuplicateDataInfo!.originalData?.newSubscriptions!.count == 1
                {
                    updatedList.append(modifiedDuplicateDataInfo!)
                    duplicateSubsList.removeAll { $0.id == modifiedDuplicateDataInfo!.originalData?.id }
                }
                else{
                    guard
                        let modified = modifiedDuplicateDataInfo,
                        var originalData = modified.originalData,
                        var newItems = originalData.newSubscriptions,
                        var oldItems = originalData.existingSubscriptions,
                        let selected = modified.selectedExistingData
                    else { return }
                    
                    let newItem = modified.selectedData![0]
                    
                    newItems.removeAll { $0.id == newItem.id }
                    
                    if let index = oldItems.firstIndex(where: { $0.id == selected.id }) {
                        oldItems[index] = newItem
                    }
                    
                    originalData.newSubscriptions = newItems
                    originalData.existingSubscriptions = oldItems
                    
                    updatedList.append(modifiedDuplicateDataInfo!)
                    
                    if let updatedData = modifiedDuplicateDataInfo?.originalData,
                       let index = duplicateSubsList.firstIndex(where: { $0.id == updatedData.id }) {
                        duplicateSubsList[index] = originalData
                    }
                }
            }
            print(duplicateSubsList)
            modifiedDuplicateDataInfo = nil
        }
    }
    
    
    // MARK: - Extracted subview
    @ViewBuilder
    private func rowView(for objc: DuplicateDataInfo, at index: Int) -> some View {
        DuplicateListItem(item: objc) { data, selected, type  in
            if type == "save" {
                let selectedObjects = selected.compactMap { index in
                    data.newSubscriptions?[index]
                }
                let newObject = ModifiedDuplicateDataInfo(originalData: data, selectedIndexs: selected, selectedData: selectedObjects)
                updatedList.append(newObject)
                duplicateSubsList.removeAll { $0.id == data.id }
                var selectedObjectsNew = [SubscriptionInfo]()
                for item in selectedObjects
                {
                    var newitem = item
                    if isFromAdd == true {
                        newitem.id = ""
                    }
                    selectedObjectsNew.append(newitem)
                }
                if selectedObjectsNew.isEmpty{
                    
                }else{
                    self.makeApiCall(action: 2, existingSubscription: "", newSubscriptions: selectedObjectsNew)
                }
            }
            else if type == "keep" {
                let newObject = ModifiedDuplicateDataInfo(originalData: data, isKeepAll: true)
                updatedList.append(newObject)
                duplicateSubsList.removeAll { $0.id == data.id }
                let selectedObjects = data.newSubscriptions ?? []
                var selectedObjectsNew = [SubscriptionInfo]()
                for item in selectedObjects
                {
                    var newitem = item
                    if isFromAdd == true {
                        newitem.id = ""
                    }
                    selectedObjectsNew.append(newitem)
                }
                self.makeApiCall(action: 2, existingSubscription: "", newSubscriptions: selectedObjectsNew)
            }
            else if type == "update"
            {
                //print(data.serviceName)
                duplicateDataCount = duplicateSubsList.count
                AppIntentRouter.shared.navigate(to: .duplicateUpdateView(duplicateSubsList: data, selectedIndex: selected[0], fromFamily: fromFamily, isFromEmail: isFromEmail))
            }
            else if type == "gotoDetails"
            {
                let index = selected[0]
                AppIntentRouter.shared.navigate(to: .duplicateSubDetailsView(subscriptionData: data.existingSubscriptions![index]))
            }
            else if type == "gotoNewDetails"
            {
                let index = selected[0]
                AppIntentRouter.shared.navigate(to: .duplicateSubDetailsView(subscriptionData: data.newSubscriptions![index]))
            }
        }
    }
    
    //MARK: - Button actions
    private func goBack() {
        dismiss()
    }
    
    private func skipAll() {
        //        if isFromAdd == true {
        //            AppIntentRouter.shared.navigate(to: .addSubscriptionsView)
        //        }
        //        else{
        //            AppIntentRouter.shared.navigate(to: .subscriptionsListView)
        //        }
        if fromFamily{
            AppIntentRouter.shared.pop(count: 2)
            //            AppIntentRouter.shared.navigate(to: .familyMembersView)
        }
        else{
            AppIntentRouter.shared.navigate(to: .subscriptionsListView())
        }
    }
    
    //MARK: - apicall
    func makeApiCall(action:Int, existingSubscription:String, newSubscriptions:[SubscriptionInfo])
    {
        let updatedSubscriptions = newSubscriptions.map { sub in
            var updatedSub = sub
            updatedSub.serviceLogo = sub.serviceLogo?.fileNameOnly
            if isFromEmail{
                updatedSub.sourceReference = sub.sourceReference
            }
            return updatedSub
        }
        let input = ResolveDuplicateSubscriptionRequest(userId: Constants.getUserId(),
                                                        action: action,
                                                        existingSubscription: existingSubscription,
                                                        //                                                        newSubscriptions: newSubscriptions)
                                                        newSubscriptions: updatedSubscriptions)
        dupSubscriptionVM.resolveDuplicateSubscription(input: input)
    }
}

struct DuplicateListItem: View {
    
    var item                              : DuplicateDataInfo!
    @State private var selectedIndex      : [Int] = []
    var onDelegate: ((_ data:DuplicateDataInfo, _ selected:[Int], _ type:String) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(item?.serviceName ?? "")
                    .font(.appBold(16))
                    .foregroundColor(.neutralMain700)
                Spacer()
                //                if (item.existingSubscriptions?.count ?? 0) > 0 {
                //                    Button(action: keepAllBtnAction) {
                Text("Keep All")
                    .font(.appBold(16))
                    .foregroundColor(.navyBlueCTA700)
                    .onTapGesture {
                        keepAllBtnAction()
                    }
                //                    }
                //                }
            }
            .padding(.top, 10)
            .padding(.bottom, 6)
            .padding(.horizontal, 16)
            
            VStack(spacing: 10) {
                ForEach(Array(item.newSubscriptions!.enumerated()), id: \.offset) { index, objc in
                    newRowView(for: objc, at: index)
                }
                if let existing = item.existingSubscriptions, !existing.isEmpty {
                    ForEach(Array(existing.enumerated()), id: \.offset) { index, objc in
                        oldRowView(for: objc, at: index)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            if item.existingSubscriptions?.count ?? 0 == 0 {
                CustomButton(title: "Save", height: 49)//, action: saveAction)
                    .frame(width: 124)
                    .padding(.bottom, 15) // Increased padding for better spacing
                    .onTapGesture {
                        saveAction()
                    }
            } else {
                Spacer()
                    .frame(height: 16)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .background(.whiteNeutralCardBG)
        .cornerRadius(16)
        .padding(.bottom, 16)
    }
    
    
    // MARK: - Extracted subview
    @ViewBuilder
    private func newRowView(for objc: SubscriptionInfo, at index: Int) -> some View {
        let isNoColor = (item.existingSubscriptions?.isEmpty ?? true)
        if isNoColor {
            let isSelected = selectedIndex.contains(index) ? true : false
            SubItem(item: objc, isNoColor:isNoColor, isNew:true, isSelected:isSelected) { data, type in
                
                if let index = item.newSubscriptions?.firstIndex(where: { $0.id == data.id }) {
                    print("Found at index: \(index)")
                    if type == "click" {
                        onDelegate?(item, [index], "gotoNewDetails")
                    }
                    else  if type == "check" {
                        selectedAction(at: index)
                    }
                }
                
            }
            /*.onTapGesture {
             selectedAction(at: index)
             }*/
        } else {
            SubItem(item: objc, isNoColor:isNoColor, isNew:true) { data, type in
                
                if let index = item.newSubscriptions?.firstIndex(where: { $0.id == data.id }) {
                    print("Found at index: \(index)")
                    if type == "click" {
                        onDelegate?(item, [index], "gotoNewDetails")
                    }
                    else  if type == "update" {
                        onDelegate?(item, [index], "update")
                    }
                }
            }
        }
    }
    
    private func oldRowView(for objc: SubscriptionInfo, at index: Int) -> some View {
        let isNoColor = (item.existingSubscriptions?.isEmpty ?? true)
        //        return SubItem(item: objc, isNoColor:isNoColor, isNew: false)
        //            .contentShape(Rectangle())
        //            .onTapGesture {
        //                onDelegate?(item, [index], "gotoDetails")
        //            }
        return ZStack {
            SubItem(item: objc, isNoColor: isNoColor, isNew: false)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onDelegate?(item, [index], "gotoDetails")
        }
    }
    
    // MARK: - Button actions
    private func selectedAction(at index: Int) {
        if selectedIndex.contains(index)
        {
            selectedIndex.removeAll { $0 == index }
        }
        else{
            selectedIndex.append(index)
        }
    }
    
    private func saveAction() {
        if selectedIndex.count > 0{
            onDelegate?(item, selectedIndex, "save")
        }else{
            ToastManager.shared.showToast(message: "At least one subscription is required",style: .error)
        }
    }
    
    private func keepAllBtnAction() {
        onDelegate?(item, [], "keep")
    }
}

struct SubItem: View {
    var item            : SubscriptionInfo!
    var isNoColor       : Bool = false
    var isNew           : Bool = false
    var isSelected      : Bool = false
    var onDelegate: ((_ data:SubscriptionInfo, _ type:String) -> Void)?
    
    var fullTitle: String {
        [item?.serviceName, item?.subscriptionType]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            //Button(action: clickBtnAction) {
            HStack(alignment: .top, spacing: 6) {
                if isNoColor == true
                {
                    // Button(action: checkBtnAction) {
                    VStack(alignment: .leading, spacing: 9) {
                        Image(isSelected == true ? "Checkmark" : "UnCheckmark")
                            .frame(width: 24, height: 24)
                            .offset(x: 0, y: -5)
                    }
                    .onTapGesture {
                        checkBtnAction()
                    }
                    // }
                }
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 10) {
                        Text(fullTitle)
                            .font(.appRegular(16))
                            .foregroundColor(.neutralMain700)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Text(isNew == true ? "New" : "Existing")
                            .font(.appRegular(12))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(isNew == true ? .linearGradient3 : .blueMain700)
                            .frame(height: 24)
                            .cornerRadius(4)
                    }
                    .padding(.bottom, -5)
                    
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
                        if isNew == true && isNoColor == false
                        {
                            //Button(action: updateBtnAction) {
                            Text("Update")
                                .font(.appSemiBold(16))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal,16)
                                .background(.navyBlueCTA700)
                                .frame(height: 34)
                                .cornerRadius(7)
                                .onTapGesture {
                                    updateBtnAction()
                                }
                            // }
                        }
                    }
                    
                    if item.status == "expired"{
                        Text("We found an old expired subscription. Do you want to replace it or add a new subscription?")
                            .foregroundStyle(Color.redBadge)
                            .font(.appRegular(12))
                    }
                }
                .padding(.vertical, 16)
            }
            .onTapGesture {
                clickBtnAction()
            }
            //}
        }
        .frame(minHeight: 108)
        .padding(.horizontal, 16)
        .background(.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .background(isNoColor == true ? .whiteBlack : .neutralBg100)
        .cornerRadius(8)
        .padding(.bottom, 10)
    }
    
    // MARK: - Button actions
    private func updateBtnAction() {
        print(item.serviceName ?? "")
        onDelegate?(item, "update")
        //AppIntentRouter.shared.navigate(to: .duplicateUpdateView)
    }
    
    private func clickBtnAction() {
        onDelegate?(item, "click")
    }
    
    private func checkBtnAction() {
        onDelegate?(item, "check")
    }
}
