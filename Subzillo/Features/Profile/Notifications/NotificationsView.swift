//
//  NotificationsView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/01/26.
//  Redesigned by Antigravity on 27/05/26.
//

import SwiftUI

struct NotificationsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager     : ThemeManager
    
    @StateObject private var viewModel      = NotificationsViewModel()
    @State private var selectionMode        : Bool = false
    @State private var showDeletePopup      : Bool = false
    @State private var openCardIndex        : Int? = nil
    @State private var isScrollDisabled     : Bool = false
    @State private var deleteSheetHeight    : CGFloat = .zero
    
    // MARK: - Filter States
    private let filters = ["All", "Alerts", "Renewals", "Rewards", "Promotional"]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Redesigned Custom Header
            HStack {
                CircleBackButton {
                    AppIntentRouter.shared.pop()
                }
                
                Spacer()
                
                Text("Notifications")
                    .font(.geistSemiBold(17))
                    .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                
                Spacer()
                
                if !viewModel.notificationsList.isEmpty && !selectionMode {
                    Button(action: {
                        viewModel.markAllAsRead()
                    }) {
                        Text("Mark read")
                            .font(.geistSemiBold(12))
                            .foregroundColor(themeManager.currentAccent.senColor)
                    }
                } else {
                    Spacer().frame(width: 40)
                }
            }
            .padding(.top, 60)
            .padding(.horizontal, 24)
            .padding(.bottom, 0)
            
            // MARK: - Custom Tags Horizontal Pills Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filters, id: \.self) { filter in
                        let tab = tabIndex(for: filter)
                        let isSelected = viewModel.selectedTab == tab
                        Button(action: {
                            if viewModel.selectedTab != tab {
                                //                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.selectedTab = tab
                                viewModel.resetAndFetch()
                                //                                    }
                            }
                        }) {
                            Text(filter)
                                .font(.geistSemiBold(12))
                                .foregroundColor(isSelected ? .white : themeManager.textPrimaryLight6_dark62)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Group {
                                        if isSelected {
                                            themeManager.accentGradient
                                        } else {
                                            themeManager.white_white4
                                        }
                                    }
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            isSelected ? Color.clear : themeManager.textPrimaryLight8_white8,
                                            lineWidth: 1
                                        )
                                )
                                .shadow(
                                    color: isSelected ? themeManager.accentTextColor.opacity(0.55) : Color.clear,
                                    radius: 7,
                                    x: 0,
                                    y: 4
                                )
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 0)
            
            // MARK: - Main Notifications Area
            if viewModel.isLoading && viewModel.notificationsList.isEmpty {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentAccent.senColor))
                Spacer()
            } else if viewModel.notificationsList.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image("noNotifications")
                        .renderingMode(.template)
                        .foregroundStyle(themeManager.gradient(style: .vertical))
//                        .resizable()
                        .scaledToFit()
                        .frame(width: 68, height: 68)
                    
                    Text("No Notifications Yet")
                        .font(.geistSemiBold(16))
                        .foregroundColor(Color("TextPrimary_ 0E101A_F4F1FB"))
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.notificationsList.enumerated()), id: \.element.id) { index, notification in
                            SwipeableNotificationRow(
                                id: index,
                                openCardIndex: $openCardIndex,
                                isScrollDisabled: $isScrollDisabled,
                                selectionMode: selectionMode,
                                onDelete: {
                                    showDeletePopup = true
                                }
                            ) { isSwipedState in
                                NotificationRowView(
                                    notification: notification,
                                    selectionMode: selectionMode,
                                    isSwiped: isSwipedState,
                                    onSelect: {
                                        toggleSelection(at: index)
                                    }
                                )
                                .onLongPressGesture {
                                    //                                        enterSelectionMode(at: index)
                                }
                                .onTapGesture {
                                    if selectionMode {
                                        toggleSelection(at: index)
                                    } else {
                                        viewModel.markAsRead(id: notification.id)
                                    }
                                }
                            }
                            .onAppear {
                                // Automatic Scroll-Based Infinite Pagination
                                if index == viewModel.notificationsList.count - 1 && !viewModel.isAllLoaded && !viewModel.isLoading {
                                    viewModel.loadMore()
                                }
                            }
                        }
                        
                        // Bottom loading indicator for scroll pagination
                        if viewModel.isLoading && !viewModel.notificationsList.isEmpty {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentAccent.senColor))
                                .padding(.vertical, 16)
                        }
                    }
                    .padding(.top, 5)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
                .scrollDisabled(isScrollDisabled)
            }
            
            // MARK: - Bottom Actions in Selection Mode
            if selectionMode {
                CancelDeleteView(leftImage: "cross_gradient", rightImage: "delete_red", leftText: "Cancel", rightText: "Delete") {
                    exitSelectionMode()
                } deleteAction: {
                    showDeletePopup = true
                }
                .padding(.bottom, 100)
                .padding(.horizontal, 24)
            }
        }
        .ignoresSafeArea()
        .applyAppBackground()
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showDeletePopup) {
            InfoAlertSheet(
                onDelegate: {
                    deleteSelected()
                },
                title                   : "Are you sure you want to delete the notifications?",
                subTitle                : "Data will be permanently deleted",
                imageName               : "del_red_new",
                buttonIcon              : "del_red_newSmall",
                buttonTitle             : "Delete",
                imageSize               : 70,
                isCancelButtonVisible   : true,
                isImageVisible          : true
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
        .onAppear {
            viewModel.notificationsListApi()
        }
    }
    
    // MARK: - Button Actions
    
    private func toggleSelection(at index: Int) {
        guard index >= 0 && index < viewModel.notificationsList.count else { return }
        viewModel.notificationsList[index].isSelected?.toggle()
    }
    
    private func enterSelectionMode(at index: Int) {
        guard index >= 0 && index < viewModel.notificationsList.count else { return }
        selectionMode = true
        viewModel.notificationsList[index].isSelected = true
    }
    
    private func exitSelectionMode() {
        selectionMode = false
        for i in 0..<viewModel.notificationsList.count {
            viewModel.notificationsList[i].isSelected = false
        }
    }
    
    private func deleteSelected() {
        let selectedIds = viewModel.notificationsList.filter { $0.isSelected ?? false == true }.map { $0.id }
        viewModel.deleteNotifications(ids: selectedIds)
        exitSelectionMode()
        showDeletePopup = false
    }
    
    // MARK: - Helper Methods
    
    private func tabIndex(for filter: String) -> Int {
        switch filter {
        case "All": return 1
        case "Alerts": return 2
        case "Renewals": return 3
        case "Rewards": return 4
        case "Promotional": return 5
        default: return 1
        }
    }
    
    private func filterName(for tab: Int) -> String {
        switch tab {
        case 1: return "All"
        case 2: return "Alerts"
        case 3: return "Renewals"
        case 4: return "Rewards"
        case 5: return "Promotional"
        default: return "All"
        }
    }
}

// MARK: - SwipeableNotificationRow

struct SwipeableNotificationRow<Content: View>: View {
    
    let id                          : Int
    @Binding var openCardIndex      : Int?
    @Binding var isScrollDisabled   : Bool
    let selectionMode               : Bool
    let onDelete                    : () -> Void
    let content                     : (Bool) -> Content
    @State private var offsetX      : CGFloat = 0
    private let maxOffset: CGFloat  = -60
    let menuWidth: CGFloat          = 60
    @State private var rowHeight    : CGFloat = 0
    @State private var isSwiped     : Bool = false
    @State private var isCardUIActive: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    
    init(
        id: Int,
        openCardIndex: Binding<Int?>,
        isScrollDisabled: Binding<Bool>,
        selectionMode: Bool,
        onDelete: @escaping () -> Void,
        @ViewBuilder content: @escaping (Bool) -> Content
    ) {
        self.id = id
        self._openCardIndex = openCardIndex
        self._isScrollDisabled = isScrollDisabled
        self.selectionMode = selectionMode
        self.onDelete = onDelete
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete Action (revealed on swipe)
            Button(action: {
                onDelete()
                withAnimation {
                    offsetX = 0
                    isSwiped = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    if self.offsetX == 0 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.isCardUIActive = false
                        }
                    }
                }
            }) {
                VStack() {
                    HStack{
                        Spacer()
                        VStack(spacing: 8){
                            Image("swipeDel")
                            Text("Delete")
                                .font(.jetBrainsBold(11))
                                .foregroundColor(colorScheme == .light ? .textPrimaryDarkF4F1FB : .dangerDarkFF5A7A)
                        }
                        .padding(.leading, 5)
                        .frame(alignment: .trailing)
                        .frame(width: 70, height: rowHeight)
                    }
                }
                .frame(width: 80, height: rowHeight)
                .background(colorScheme == .light ? .dangerLightE43C5C : .dangerLightE43C5C.opacity(0.4))
                .clipShape(
                    RoundedCorner(
                        radius: 20,
                        corners: [.topRight, .bottomRight]
                    )
                )
                .overlay(
                    RoundedCorner(
                        radius: 20,
                        corners: [.topRight, .bottomRight]
                    )
                    .stroke(colorScheme == .light ? .E_2_E_8_F_0 : .dangerLightE43C5C.opacity(0.40), lineWidth: 1)
                    .padding(0.5)
                )
            }
            .padding(.trailing, 1)
            .opacity(offsetX != 0 || isSwiped ? 1 : 0) // Hide when not swiping
            .zIndex(0)
            
            // Notification Card Content
            content(isCardUIActive)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                rowHeight = geo.size.height
                            }
                            .onChange(of: geo.size.height) { newValue in
                                rowHeight = newValue
                            }
                    }
                )
                .offset(x: offsetX)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
                        .onChanged { value in
                            if selectionMode { return }
                            guard abs(value.translation.width) > abs(value.translation.height) else {
                                isScrollDisabled = false
                                return
                            }
                            isScrollDisabled = true
                            let containerWidth = -menuWidth
                            var proposedOffset: CGFloat = 0
                            if isSwiped {
                                // Starting from open state (-menuWidth)
                                proposedOffset = containerWidth + value.translation.width
                            } else {
                                // Starting from closed state (0)
                                proposedOffset = value.translation.width
                            }
                            // Strictly clamp the offset
                            self.offsetX = min(0, max(containerWidth, proposedOffset))
                            
                            if self.offsetX < 0 && !self.isCardUIActive {
                                self.isCardUIActive = true
                            }
                        }
                        .onEnded { value in
                            if selectionMode { return }
                            isScrollDisabled = false
                            guard abs(value.translation.width) > abs(value.translation.height) else { return }
                            
                            if value.translation.width < maxOffset {
                                withAnimation(.spring()) {
                                    self.offsetX = -menuWidth
                                    self.isSwiped = true
                                    self.openCardIndex = id
                                }
                                self.isCardUIActive = true
                            } else {
                                withAnimation(.spring()) {
                                    self.offsetX = 0
                                    self.isSwiped = false
                                    if self.openCardIndex == id {
                                        self.openCardIndex = nil
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    if self.offsetX == 0 {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            self.isCardUIActive = false
                                        }
                                    }
                                }
                            }
                        }
                )
                .zIndex(1)
        }
        .onChange(of: openCardIndex) { newValue in
            if newValue != id && (offsetX != 0 || isSwiped) {
                withAnimation {
                    offsetX = 0
                    isSwiped = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    if self.offsetX == 0 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.isCardUIActive = false
                        }
                    }
                }
            }
        }
    }
}
