import SwiftUI

struct SwipeableEmailRow: View {
    
    //MARK: - Properties
    let email                       : ConnectedEmail
    @Binding var activeEmailId      : UUID?
    @Binding var isScrollDisabled   : Bool
    let onDelete                    : () -> Void
    let onSync                      : () -> Void
    let onView                      : () -> Void
    @State private var offset       : CGFloat = 0
    @State private var isSwiped     : Bool = false
    @State private var rowHeight    : CGFloat = 0
    let swipeThreshold: CGFloat     = -20
    let menuWidth: CGFloat          = 50
    
    var body: some View {
        ZStack(alignment: .trailing) {
            //MARK: Delete Button
            VStack {
                HStack{
                    VStack(spacing: 8){
                        Image("del_white")
                    }
                }
                .frame(width: menuWidth, height: rowHeight)
            }
            .frame(width: menuWidth, height: rowHeight)
            .background(Color("disCardRed"))
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
            .onTapGesture {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
                onDelete()
            }
            
            //MARK: Top Layer card view
            ConnectedEmailItemView(email: email, onSync: onSync, onView: onView)
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
                                proposedOffset = containerWidth + value.translation.width
                            } else {
                                proposedOffset = value.translation.width
                            }
                            
                            self.offset = min(0, max(containerWidth, proposedOffset))
                        }
                        .onEnded { value in
                            isScrollDisabled = false
                            guard abs(value.translation.width) > abs(value.translation.height) else { return }
                            withAnimation(.spring()) {
                                if value.translation.width < swipeThreshold {
                                    self.offset = -menuWidth
                                    self.isSwiped = true
                                    self.activeEmailId = email.id
                                } else {
                                    self.offset = 0
                                    self.isSwiped = false
                                    if self.activeEmailId == email.id {
                                        self.activeEmailId = nil
                                    }
                                }
                            }
                        }
                )
                .zIndex(1)
        }
        .onChange(of: activeEmailId) { newValue in
            if newValue != email.id && (offset != 0 || isSwiped) {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
            }
        }
    }
}
