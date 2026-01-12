import SwiftUI

struct ConnectedEmailItemView: View {
    let email: ConnectedEmail
    let onSync: () -> Void
    let onView: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Provider Icon
            Image(email.provider.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(12)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
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
                    .foregroundColor(Color(hex: "#3260BB"))
                    .frame(width: 100, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(hex: "#3260BB"), lineWidth: 1)
                    )
            }
        case .view:
            Button(action: onView) {
                Text(email.status.buttonText)
                    .font(.appSemiBold(14))
                    .foregroundColor(Color(hex: "#8766CE"))
                    .frame(width: 80, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(hex: "#8766CE"), lineWidth: 1)
                    )
            }
        case .sync:
            Button(action: onSync) {
                Text(email.status.buttonText)
                    .font(.appSemiBold(14))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 32)
                    .background(Color(hex: "#4489EB"))
                    .cornerRadius(6)
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
