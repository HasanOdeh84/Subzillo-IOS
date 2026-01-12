import SwiftUI

struct SwipeableEmailRow: View {
    let email                   : ConnectedEmail
    @Binding var activeEmailId  : UUID?
    @Binding var isScrollDisabled: Bool
    let onDelete                : () -> Void
    let onSync                  : () -> Void
    let onView                  : () -> Void
    
    @State private var offset   : CGFloat = 0
    @State private var isSwiped : Bool = false
    let swipeThreshold: CGFloat = -40
    let menuWidth: CGFloat      = 70
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete Background
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        offset = 0
                        isSwiped = false
                    }
                    onDelete()
                }) {
                    Image("del_white") // Assuming this exists based on MyCardsView
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding()
                        .frame(width: menuWidth, height: 80)
                        .background(Color("redColor")) // Assuming this exists
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Top Layer (Email Item)
            ConnectedEmailItemView(email: email, onSync: onSync, onView: onView)
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
