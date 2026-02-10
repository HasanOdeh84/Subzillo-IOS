import SwiftUI

struct ConnectedEmailItemView: View {
    let email                   : ListConnectedEmailsData
    let onSync                  : () -> Void
    let onView                  : () -> Void
    @State var provider         : EmailProvider = EmailProvider.gmail
    @State var isIntegrations   : Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Provider Icon
            Image(provider.iconName)
                .resizable()
                .scaledToFit()
//                .frame(width: 24, height: 24)
                .frame(width: 31, height: 31)
//                .padding(12)
//                .background(Color.white)
//                .clipShape(Circle())
//                .overlay(
//                    Circle()
//                        .stroke(Color.border, lineWidth: 0.5)
//                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(email.email ?? "")
                    .font(.appSemiBold(16))
                    .foregroundStyle(Color.underlineGray)
                
                if email.lastSyncDate != ""{
                    if email.lastSyncDate != nil{
                        Text((email.lastSyncDate ?? "").formattedDate(from: "DD/MM/YYYY", to: "dd/MM/yyyy"))
                            .font(.appRegular(14))
                            .foregroundStyle(Color.underlineGray)
                    }
                }
            }
            
            Spacer()
            
            // Action Button
            if !isIntegrations{
                actionButton
            }
        }
        .opacity(email.syncStatus == 1 ? 0.6 : 1.0)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .onAppear{
            if email.type == 1{
                self.provider = EmailProvider.gmail
            }else if email.type == 2{
                provider = EmailProvider.microsoft
            }else{
                provider = EmailProvider.yahoo
            }
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        if email.syncStatus == 0 && email.viewStatus == false{
            Text("Sync")
                .font(.appSemiBold(14))
                .foregroundColor(.white)
                .frame(width: 80, height: 30)
                .background(Color.blueMain700)
                .cornerRadius(5)
                .onTapGesture {
                    onSync()
                }
        } else if email.syncStatus == 1 && email.viewStatus == false{
            Text("Syncing...")
                .font(.appSemiBold(14))
                .foregroundColor(Color.blueMain700)
                .frame(width: 100, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.blueMain700, lineWidth: 1)
                )
        }
        if email.viewStatus ?? false{
            Text("View")
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
                )
                .onTapGesture {
                    onView()
                }
        }
        //        switch email.syncStatus {
        //        case 1:
        //            Text("Syncing...")
        //                .font(.appSemiBold(14))
        //                .foregroundColor(Color.blueMain700)
        //                .frame(width: 100, height: 30)
        //                .overlay(
        //                    RoundedRectangle(cornerRadius: 5)
        //                        .stroke(Color.blueMain700, lineWidth: 1)
        //                )
        //        case 2:
        //            Button(action: onView) {
        //                Text("View")
        //                    .font(.appSemiBold(14))
        //                    .foregroundStyle(LinearGradient(
        //                        gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
        //                        startPoint: .top,
        //                        endPoint: .bottom
        //                    ))
        //                    .frame(width: 80, height: 30)
        //                    .overlay(
        //                        RoundedRectangle(cornerRadius: 5)
        //                            .stroke(
        //                                LinearGradient(
        //                                    gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
        //                                    startPoint: .top,
        //                                    endPoint: .bottom
        //                                ),
        //                                lineWidth: 1
        //                            )
        //                    )
        //            }
        //        case 0:
        //            Button(action: onSync) {
        //                Text("Sync")
        //                    .font(.appSemiBold(14))
        //                    .foregroundColor(.white)
        //                    .frame(width: 80, height: 30)
        //                    .background(Color.blueMain700)
        //                    .cornerRadius(5)
        //            }
        //        case .none:
        //            if email.viewStatus ?? false{
        //                Button(action: onView) {
        //                    Text("View")
        //                        .font(.appSemiBold(14))
        //                        .foregroundStyle(LinearGradient(
        //                            gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
        //                            startPoint: .top,
        //                            endPoint: .bottom
        //                        ))
        //                        .frame(width: 80, height: 30)
        //                        .overlay(
        //                            RoundedRectangle(cornerRadius: 5)
        //                                .stroke(
        //                                    LinearGradient(
        //                                        gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
        //                                        startPoint: .top,
        //                                        endPoint: .bottom
        //                                    ),
        //                                    lineWidth: 1
        //                                )
        //                        )
        //                }
        //            }
        //        case .some(_):
        //            Text("")
        //        }
    }
}
