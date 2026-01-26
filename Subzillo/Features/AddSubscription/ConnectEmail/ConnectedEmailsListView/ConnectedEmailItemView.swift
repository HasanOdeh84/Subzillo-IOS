import SwiftUI

struct ConnectedEmailItemView: View {
    let email: ConnectedEmail
    let onSync: () -> Void
    let onView: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Provider Icon
//            Image(email.provider.iconName)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 24, height: 24)
//                .padding(12)
//                .background(Color.white)
//                .clipShape(Circle())
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.border, lineWidth: 0.5)
//                )
//                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            Image(email.provider.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(12)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.border, lineWidth: 0.5)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(email.email)
                    .font(.appSemiBold(16))
                    .foregroundStyle(Color.underlineGray)
                
                Text(email.date)
                    .font(.appRegular(14))
                    .foregroundStyle(Color.underlineGray)
            }
            
            Spacer()
            
            // Action Button
            actionButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        //        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch email.status {
        case .syncing:
            Button(action: onSync) {
                Text(email.status.buttonText)
                    .font(.appSemiBold(14))
                    .foregroundColor(Color.blueMain700)
                    .frame(width: 100, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.blueMain700, lineWidth: 1)
                    )
            }
        case .view:
            Button(action: onView) {
                Text(email.status.buttonText)
                    .font(.appSemiBold(14))
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 80, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
//                            .stroke(Color(hex: "#8766CE"), lineWidth: 1)
                    )
            }
        case .sync:
            Button(action: onSync) {
                Text(email.status.buttonText)
                    .font(.appSemiBold(14))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 30)
                    .background(Color.blueMain700)
                    .cornerRadius(5)
            }
        }
    }
}

#Preview {
    VStack {
        ConnectedEmailItemView(email: ConnectedEmail(email: "mahesh@gmail.com", date: "1/11/25", status: .syncing, provider: .gmail), onSync: {}, onView: {})
        ConnectedEmailItemView(email: ConnectedEmail(email: "mahesh@outlook.com", date: "1/11/25", status: .view, provider: .outlook), onSync: {}, onView: {})
        ConnectedEmailItemView(email: ConnectedEmail(email: "mahesh@outlook.com", date: "1/11/25", status: .sync, provider: .outlook), onSync: {}, onView: {})
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
