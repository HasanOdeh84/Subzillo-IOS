import SwiftUI

//MARK: - SwipeableSubscriptionRow
struct SwipeableMailRow: View {
    
    //MARK: Properties
    let email                       : ListConnectedEmailsData
    @Binding var activeCardId       : String?
    @Binding var isScrollDisabled   : Bool
    let onDelete                    : () -> Void
    let onSync                      : () -> Void
    let onView                      : () -> Void
    let onDownloadLogs              : () -> Void
    @State private var offset       : CGFloat = 0
    @State private var isSwiped     : Bool = false
    let swipeThreshold: CGFloat     = -20
    let menuWidth: CGFloat          = 60
    @State private var rowHeight    : CGFloat = 0
    @State var isIntegrations       : Bool = false
    
    //MARK: Body
    var body: some View {
        ZStack(alignment: .trailing) {
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
            .overlay(
                RoundedCorner(
                    radius: 12,
                    corners: [.topRight, .bottomRight]
                )
                .stroke(Color.neutral300Border, lineWidth: 1)
            )
            .zIndex(0)
            .opacity(offset != 0 || isSwiped ? 1 : 0) // Hide when not swiping
            .onTapGesture {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
                if email.syncStatus != 1{
                    onDelete()
                }else{
                    ToastManager.shared.showToast(message: "Email is syncing. Deletion will be available once complete.")
                }
            }
            
            // Top Card Layer
            ConnectedEmailItemView(email            : email,
                                   onSync           : onSync,
                                   onView           : onView,
                                   onDownloadLogs   : onDownloadLogs,
                                   isIntegrations   : isIntegrations)
            .background(Color.clear)
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
            .offset(x: offset)
            .simultaneousGesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged { value in
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
                        self.offset = min(0, max(containerWidth, proposedOffset))
                    }
                    .onEnded { value in
                        isScrollDisabled = false
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
//                        withAnimation(.spring()) {
                            if value.translation.width < swipeThreshold {
                                self.offset = -menuWidth
                                self.isSwiped = true
                                self.activeCardId = email.id
                            } else {
                                self.offset = 0
                                self.isSwiped = false
                                if self.activeCardId == email.id {
                                    self.activeCardId = nil
                                }
                            }
//                        }
                    }
            )
            .zIndex(1)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .onChange(of: activeCardId) { newValue in
            if newValue != email.id && (offset != 0 || isSwiped) {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
            }
        }
    }
}
