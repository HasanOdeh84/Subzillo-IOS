//
//  subscriptionListCard.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 05/11/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct subscriptionListCard: View {
    var title       : String = "sdfsdf"
    var description : String = "sfsdf"
    var imageUrl    : String = ""
    var currency    : String = "sdfsdf"
    var price       : String = "sdfsdf"
    var relation    : String = "sdfsdfs"
    
    var body: some View {
        HStack{
//            WebImage(url: URL(string: imageUrl))
            Image("netflix")
                        .resizable()
//                        .indicator(.activity)
//                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .cornerRadius(8)
            VStack(alignment: .leading,spacing: 4){
                Text("\(title) | \(title)")
                    .font(.appRegular(12))
                    .foregroundColor(.appNeutral600)
                    .multilineTextAlignment(.leading)
                Text("\(description) • \(description)")
                    .font(.appRegular(14))
                    .foregroundColor(.navyBlueCTA700)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            VStack(spacing: 8){
                Text(price)
                    .font(.appSemiBold(16))
                    .foregroundColor(.navyBlueCTA700)
                VStack{
                    Text(relation)
                        .font(.appRegular(12))
                        .foregroundColor(.blue900)
                }
                .padding(.vertical,4)
                .padding(.horizontal,8)
                .frame(height: 24)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.blue300, lineWidth: 1)
                )
            }
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.appNeutral800, lineWidth: 1)
        )
        .background(.appNeutral900)
        .cornerRadius(8)
    }
}

#Preview {
    subscriptionListCard()
}
