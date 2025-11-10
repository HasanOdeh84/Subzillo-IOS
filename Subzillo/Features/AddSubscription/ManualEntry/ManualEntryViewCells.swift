//
//  ManualEntryViewModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/11/25.
//

import SwiftUI

enum ListType {
    case billing, cards, relations, reminders
}

struct FieldView: View
{
    @Binding var text   : String
    var title           : String?
    var image           : String?
    var placeHolder     : String?
    var isButton        : Bool    = false
    var isText          : Bool    = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.appNeutralMain700)
            HStack{
                Image(image ?? "")
                if isText == true {
                    if text != ""
                    {
                        Text(text)
                            .padding(6)
                            .multilineTextAlignment(.leading)
                            .font(.appRegular(14))
                            .foregroundColor(.appNeutralMain700)
                            .frame(maxWidth:.infinity, alignment: .leading)
                    }
                    else{
                        Text(placeHolder ?? "")
                            .padding(6)
                            .multilineTextAlignment(.leading)
                            .font(.appRegular(14))
                            .foregroundColor(.neutral2_500)
                            .frame(maxWidth:.infinity, alignment: .leading)
                    }
                }
                else{
                    TextField(placeHolder ?? "", text: $text)
                        .keyboardType(.default)
                        .padding(6)
                        .autocapitalization(.none)
                        .multilineTextAlignment(.leading)
                        .font(.appRegular(14))
                        .foregroundColor(.neutral2_500)
                }
                if isButton == true
                {
                    Image("downArrow")
                }
            }
            .padding(16)
            .frame(height: 52)
            .background(.appBlackWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral_2_200, lineWidth: 1)
            )
        }
        .addDoneButtonToKeyboard()
    }
}

struct ListView: View {
    var type                    : ListType = .billing
    var title                   : String?
    var addMore                 : Bool = false
    @Binding var data           : [ManualDataInfo]
    @Binding var selectedIndex  : Int
    
    var body: some View {
        VStack(spacing: 0) {
            Text(LocalizedStringKey(title ?? ""))
                .font(.appRegular(14))
                .foregroundColor(.appNeutralMain700)
                .padding(.bottom, 4)
                .frame(maxWidth:.infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 0) {
                List {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, objc in
                        VStack(spacing: 0) {
                            rowView(for: objc, at: index)
                            
                            if index < data.count - 1 {
                                Divider()
                                    .overlay(Color.neutral_2_200)
                            }
                            else{
                                if addMore == true
                                {
                                    Divider()
                                        .overlay(Color.neutral_2_200)
                                }
                            }
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
                
                if addMore == true
                {
                    VStack(alignment: .center, spacing: 0) {
                        Button(action: addMoreAction) {
                            HStack(spacing: 8) {
                                Image("AddMore")
                                    .frame(width: 20, height: 20)
                                Text(type == .cards ? "Add New Card" : "Add New Member")
                                    .font(.appRegular(14))
                                    .foregroundColor(Color.blueMain700)
                            }
                            .frame(maxWidth:.infinity, alignment: .center)
                            .frame(height: 52)
                        }
                    }
                }
            }
            .background(.appBlackWhite)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neutral_2_200, lineWidth: 1)
            )
        }
        
    }
    
    // MARK: - Extracted subview
    @ViewBuilder
    private func rowView(for objc: ManualDataInfo, at index: Int) -> some View {
        if type == .billing {
            BillingCycleItem(title: objc.title ?? "", subtitle: objc.subtitle ?? "", isSelected: index == selectedIndex ? true : false)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
        if type == .cards {
            SubscriptionItem(title: objc.title ?? "", subtitle: objc.subtitle ?? "", isSelected: index == selectedIndex ? true : false, isSubTitlePresent: true)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
        if type == .relations {
            SubscriptionItem(title: objc.title ?? "", subtitle: objc.subtitle ?? "", isSelected: index == selectedIndex ? true : false)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
        if type == .reminders {
            ReminderItem(title: objc.title ?? "", isSelected: objc.isSelected ?? false)
                .onTapGesture {
                    selectedAction(at: index)
                }
        }
    }

    // MARK: - Button actions
    private func selectedAction(at index: Int) {
        selectedIndex = index
        if type == .reminders {
            var obj = data[index]
            if (obj.isSelected ?? false ) == true
            {
                obj.isSelected = false
            }
            else{
                obj.isSelected = true
            }
            data[index] = obj
        }
    }
    private func addMoreAction() {
    }
}

struct BillingCycleItem: View {
    var title           : String?
    var subtitle        : String?
    var isSelected      : Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(isSelected == true ? "SelectedRadio" : "UnSelectedRadio")
                Text(title ?? "")
                    .font(.appRegular(14))
                    .foregroundColor(.appNeutralMain700)
            }
            Spacer()
            Text(subtitle ?? "")
                .font(.appRegular(14))
                .foregroundColor(.appNeutral500)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
        .frame(height: 52)
        .background(.appBlackWhite)
    }
}

struct SubscriptionItem: View {
    var title                   : String?
    var subtitle                : String?
    var isSelected              : Bool = false
    var isSubTitlePresent       : Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(isSelected == true ? "SelectedRadio" : "UnSelectedRadio")
            Text(title ?? "")
                .font(.appRegular(14))
                .foregroundColor(.appNeutralMain700)
            if isSubTitlePresent == true {
                Text(subtitle ?? "")
                    .font(.appRegular(14))
                    .foregroundColor(.appNeutral500)
                    .multilineTextAlignment(.trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 52)
        .background(.appBlackWhite)
    }
}

struct ReminderItem: View {
    var title                   : String?
    var isSelected              : Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(isSelected == true ? "Checkmark" : "UnCheckmark")
            Text(title ?? "")
                .font(.appRegular(14))
                .foregroundColor(.appNeutralMain700)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 52)
        .background(.appBlackWhite)
    }
}
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
