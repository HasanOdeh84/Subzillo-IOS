//
//  OtpSuccessView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 03/11/25.
//

import SwiftUI

struct SuccessView: View {
    
    //MARK: - Properties
    var isOtp: Bool?
    
    var body: some View {
        ZStack{
            Group {
                Color(.appBackground)
            }
            .ignoresSafeArea()
            
            VStack() {
                Text("Welcome to")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
                    .padding(.top,20)
                
                Image("logo_svg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128,height: 88)
                    .padding(.top,24)
                    .padding(.bottom,106)
                
                LottieView(name: "success")
                    .frame(width: 127,height: 127)
                
                Text("Phone Number\n Verified")
                    .font(.appRegular(24))
                    .foregroundColor(Color.neutralMain700)
                    .multilineTextAlignment(.center)
                    .padding(.top,24)
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SuccessView()
}
