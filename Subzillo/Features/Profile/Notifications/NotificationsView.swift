//
//  NotificationsView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 30/01/26.
//

import SwiftUI

struct NotificationsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel      = NotificationsViewModel()
    @State private var selectionMode        : Bool = false
    @State private var showDeletePopup      : Bool = false
    @State private var openCardIndex        : Int? = nil
    @State private var isScrollDisabled     : Bool = false
    @State private var deleteSheetHeight    : CGFloat = .zero
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            ProfileHeaderView(
                title: "Notifications",
                trailingTitle: (viewModel.notificationsList.count == 0 || viewModel.notificationData?.totalCount == 0 || viewModel.notificationData?.totalCount == nil) ? nil : (selectionMode ? nil : "Mark all as read"),
                onBack: {
                    dismiss()
                },
                onTrailingAction: {
                    viewModel.markAllAsRead()
                }
            )
            .padding(.top, 70)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            if viewModel.notificationsList.count == 0{
                Spacer()
                VStack(){
                    Image("noNotifications")
                        .frame(width: 68, height: 68, alignment: .center)
                    Text("No Notifications Yet")
                        .padding(10)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.neutral800)
                        .font(.appBold(16))
                }
                Spacer()
            }else{
                // MARK: - Unread Count
                HStack {
                    Text(LocalizedStringKey("Unread notifications - \(viewModel.unreadCount)"))
                        .font(.appRegular(14))
                        .foregroundColor(.blueMain700)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // MARK: - Notifications List
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
                            ) {
                                NotificationRowView(
                                    notification: notification,
                                    selectionMode: selectionMode,
                                    onSelect: {
                                        toggleSelection(at: index)
                                    }
                                )
                                .onLongPressGesture {
                                    enterSelectionMode(at: index)
                                }
                                .onTapGesture {
                                    if selectionMode {
                                        toggleSelection(at: index)
                                    } else {
                                        // Handle notification tap
                                        viewModel.markAsRead(id: notification.id)
                                    }
                                }
                            }
                            .padding(.bottom, index == viewModel.notificationsList.count - 1 ? 20 : 0)
                        }
                    }
                    .padding(.top, 5)
                    .padding(.horizontal, 24)
                }
                .scrollDisabled(isScrollDisabled)
                
                // MARK: - Bottom Button
                if selectionMode {
                    //MARK: cancel and delete buttons
                    CancelDeleteView(leftImage: "cross_gradient", rightImage: "delete_red", leftText: "Cancel", rightText: "Delete") {
                        exitSelectionMode()
                    } deleteAction: {
                        showDeletePopup = true
                    }
                    .padding(.bottom, 40)
                    .padding(.horizontal, 24)
                    
                } else {
                    GradientBorderButton(title: "Load more notifications") {
                        viewModel.loadMore()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .opacity(viewModel.isAllLoaded ? 0.5 : 1)
                    .disabled(viewModel.isAllLoaded)
                }
            }
        }
        .background(Color.neutralBg100)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showDeletePopup) {
            InfoAlertSheet(
                onDelegate: {
                    deleteSelected()
                },
                title: "Are you sure you want to delete the notifications?\nData will be permanently deleted",
                subTitle: "",
                imageName: "del_red_big",
                buttonIcon: "deleteIcon",
                buttonTitle: "Delete",
                imageSize: 70
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
        .onAppear{
            viewModel.notificationsListApi()
        }
    }
    
    // MARK: - Button Actions
    private func toggleSelection(at index: Int) {
        viewModel.notificationsList[index].isSelected?.toggle()
    }
    
    private func enterSelectionMode(at index: Int) {
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
        let selectedIds = viewModel.notificationsList.filter { $0.isSelected ?? false == true }.map { $0.id}
        viewModel.deleteNotifications(ids: selectedIds)
        exitSelectionMode()
        showDeletePopup = false
    }
}

// MARK: - SwipeableNotificationRow

struct SwipeableNotificationRow<Content: View>: View {
    
    let id                          : Int
    @Binding var openCardIndex      : Int?
    @Binding var isScrollDisabled   : Bool
    let selectionMode               : Bool
    let onDelete                    : () -> Void
    let content                     : Content
    @State private var offsetX      : CGFloat = 0
    private let maxOffset: CGFloat  = -60
    let menuWidth: CGFloat          = 60
    @State private var rowHeight    : CGFloat = 0
    @State private var isSwiped     : Bool = false
    
    init(
        id: Int,
        openCardIndex: Binding<Int?>,
        isScrollDisabled: Binding<Bool>,
        selectionMode: Bool,
        onDelete: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self._openCardIndex = openCardIndex
        self._isScrollDisabled = isScrollDisabled
        self.selectionMode = selectionMode
        self.onDelete = onDelete
        self.content = content()
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
            }) {
                VStack() {
                    VStack(spacing: 8){
                        Image("del_white")
                        Text("Delete")
                            .font(.appSemiBold(14))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 5)
                    .frame(alignment: .trailing)
                    .frame(width: 70, height: rowHeight)
                }
                .frame(width: 70, height: rowHeight)
                .background(Color("redColor"))
                .clipShape(
                    RoundedCorner(
                        radius: 12,
                        corners: [.topRight, .bottomRight]
                    )
                )
            }
            .padding(.trailing, 1)
            .opacity(offsetX != 0 || isSwiped ? 1 : 0) // Hide when not swiping
            .zIndex(0)
            
            // Notification Card Content
            content
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
                        }
                        .onEnded { value in
                            if selectionMode { return }
                            isScrollDisabled = false
                            guard abs(value.translation.width) > abs(value.translation.height) else { return }
                            withAnimation(.spring()) {
                                if value.translation.width < maxOffset {
                                    self.offsetX = -menuWidth
                                    self.isSwiped = true
                                    self.openCardIndex = id
                                } else {
                                    self.offsetX = 0
                                    self.isSwiped = false
                                    if self.openCardIndex == id {
                                        self.openCardIndex = nil
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
            }
        }
    }
}
