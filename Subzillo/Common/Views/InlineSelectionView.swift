//
//  InlineSelectionView.swift
//  Subzillo
//
//  Created by Antigravity on 16/05/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct InlineSelectionView<T: Hashable>: View {
    
    // MARK: - Properties
    let title: String
    let items: [T]
    @Binding var selectedItem: T?
    @Binding var isExpanded: Bool
    @Binding var searchText: String
    let placeholder: String
    
    // Closures for data extraction
    let labelProvider: (T) -> String
    let flagProvider: (T) -> String
    let detailProvider: ((T) -> String)?
    let secondaryDetailProvider: ((T) -> String)? // For Currency symbol
    var showSelectionField: Bool = true
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemScheme
    
    // MARK: - Body
    var body: some View {
        if showSelectionField {
            VStack(alignment: .leading, spacing: 14) {
                headerView
                
                VStack(spacing: 20) {
                    selectionField
                    
                    if isExpanded {
                        expandedContent
                    }
                }
            }
        } else {
            expandedContent
                .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        if !title.isEmpty {
            Text(LocalizedStringKey(title))
                .font(.jetBrainsMedium(14))
                .foregroundColor(Color.textDim60637AA8A4C0)
                .padding(.horizontal, 4)
        }
    }
    
    @ViewBuilder
    private var selectionField: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                flagView(url: selectedItem.map(flagProvider) ?? "")
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedItem.map(labelProvider) ?? "Select Options")
                        .font(.geistSemiBold(16))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB)
                    
                    if let detail = detailProvider, let selected = selectedItem {
                        Text(detail(selected))
                            .font(.jetBrainsMedium(12))
                            .foregroundColor(Color.textDim60637AA8A4C0)
                    }
                }
                
                Spacer()
                
                if let secondaryDetail = secondaryDetailProvider, let selected = selectedItem {
                    Text(secondaryDetail(selected))
                        .font(.geistMedium(17))
                        .foregroundColor(themeManager.accentTextColor)
                        .padding(.trailing, 8)
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.textDim60637AA8A4C0)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(Color.cardBgFFFFFF1A1030)
            .cornerRadius(13)
            .overlay(selectionFieldBorderView)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var selectionFieldBorderView: some View {
        if isExpanded{
            themeManager.selectionFieldBorder
        }else{
            RoundedRectangle(cornerRadius: 14)
                .stroke(themeManager.textPrimaryLight8_white8, lineWidth: 1)
        }
    }
    
    @ViewBuilder
    private var expandedContent: some View {
        VStack(spacing: 0) {
            searchField
            
            Divider()
                .background(Color.cardBorderE2E8F0E2E8F0.opacity(0.5))
            
            listItems
        }
        .background(Color.cardBgFFFFFF1A1030)
        .cornerRadius(13)
        //        .padding(.top, 4)
        .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .top)))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    themeManager.textPrimaryLight8_white8,
                    lineWidth: 1
                )
        }
    }
    
    @ViewBuilder
    private var searchField: some View {
        HStack(spacing: 12) {
            Image("search_new")
                .resizable()
            //                .renderingMode(.template)
                .frame(width: 18, height: 18)
            //                .foregroundColor(Color.textDim60637AA8A4C0)
            
            TextField(LocalizedStringKey(placeholder), text: $searchText)
                .font(.geistMedium(14))
                .foregroundColor(Color.textPrimary0E101AF4F1FB)
                .submitLabel(.done)
        }
        //        .padding(.horizontal, 16)
        .frame(height: 52)
        //        .background(Color.neutralBg100.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 12)
        //        .padding(.top, 16)
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var listItems: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                let itemsArray = Array(items)
                ForEach(0..<itemsArray.count, id: \.self) { index in
                    let item = itemsArray[index]
                    
                    listItem(for: item)
                    
                    if index < itemsArray.count - 1 {
                        Divider()
                            .background(themeManager.textPrimaryLight8_white8)
                    }
                }
            }
        }
        .frame(maxHeight: 250)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func listItem(for item: T) -> some View {
        Button {
            selectItem(item)
        } label: {
            listItemLabel(for: item)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func selectItem(_ item: T) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedItem = item
            isExpanded = false
            searchText = ""
        }
    }
    
    @ViewBuilder
    private func listItemLabel(for item: T) -> some View {
        let isSelected = item == selectedItem
        
        HStack(spacing: 12) {
            flagView(url: flagProvider(item))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(labelProvider(item))
                    .font(.geistMedium(15))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                
                if let detail = detailProvider {
                    Text(detail(item))
                        .font(.jetBrainsMedium(11))
                        .foregroundColor(themeManager.textPrimaryLight6_dark62)
                }
            }
            
            Spacer()
            
            if let secondaryDetail = secondaryDetailProvider {
                Text(secondaryDetail(item))
                    .font(.geistMedium(15))
                    .foregroundColor(isSelected ? themeManager.accentTextColor : themeManager.textPrimaryLight6_dark62)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .background(itemBackground(isSelected: isSelected))
    }
    
    @ViewBuilder
    private func itemBackground(isSelected: Bool) -> some View {
        if isSelected {
            LinearGradient(
                colors: [
                    .brandFromDarkA719DD.opacity(0.133),
                    .brandToDark4489EB.opacity(0.133)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color.clear
        }
    }
    
    @ViewBuilder
    private func flagView(url: String) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.flagBgF1F2F7F7F7F9)
                .frame(width: 39, height: 39)
                .cornerRadius(10)
            
            if !url.isEmpty {
                WebImage(url: URL(string: url))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            } else {
                Text("??")
                    .font(.geistSemiBold(12))
                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
            }
        }
    }
}

// Extension to limit height
extension View {
    func maxHeight(_ height: CGFloat) -> some View {
        self.frame(maxHeight: height)
            .clipped()
    }
}
