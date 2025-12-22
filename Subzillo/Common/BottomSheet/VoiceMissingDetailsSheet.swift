//
//  VoiceMissingDetailsSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/12/25.
//

import SwiftUI

struct MissingDetails: Codable, Identifiable, Hashable {
    var id          : String?
    var title       : String
    var description : String
}

struct VoiceMissingDetailsSheet: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager   = AudioRecorderManager()
    @State var showDiscardPopup             : Bool = false
    @State private var showPermissionAlert  = false
    @State var missingDetailsList           : [MissingDetails] = []
    var onDelegate          : (() -> Void)?
    var onSubmit            : ((URL) -> Void)?
    var onSkipToContinue    : (() -> Void)?
    
    //MARK: - body
    var body: some View {
        VStack{
            VStack(spacing: 12){
                Capsule()
                    .fill(Color.grayCapsule)
                    .frame(width: 150, height: 5)
                    .frame(alignment: .center)
                    .padding(.top, 20)
                
                //MARK: Skip to continue
                HStack{
                    Spacer()
                    Button {
                        skipToContinue()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Skip to continue")
                                .foregroundColor(Color.navyBlueCTA700)
                                .font(.appRegular(14))
                            Image(systemName: "arrow.right")
                                .foregroundColor(Color.blueMain700)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
                //MARK: Missing details title
                Text("Missing Details")
                    .font(.appSemiBold(24))
                    .foregroundStyle(Color.neutralMain700)
                
                //MARK: Missing details list
                //                List(missingDetailsList, id: \.self) { item in
                //                    VStack(spacing: 0) {
                //                        MissingDetailItem(title         : item.title,
                //                                          description   : item.description)
                //                    }
                //                    .padding(.vertical, 17)
                //                    .padding(.horizontal, 17)
                //                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // remove default list padding
                //                    .listRowSeparator(.hidden)
                //                    .listRowBackground(Color.clear)
                //                }
                //                .listStyle(.plain)
                //                .overlay(
                //                    RoundedRectangle(cornerRadius: 16)
                //                        .stroke(.neutral300Border, lineWidth: 1)
                //                )
                //                .cornerRadius(16)
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(missingDetailsList, id: \.self) { item in
                                MissingDetailItem(
                                    title: item.title,
                                    description: item.description
                                )
                                .padding(.vertical, 17)
                                .padding(.horizontal, 17)
                            }
                        }
                    }
                }
                .frame(
                    height: min(
                        CGFloat(missingDetailsList.count) * 80,
                        UIScreen.main.bounds.height * 0.35
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.neutral300Border, lineWidth: 1)
                )
                .cornerRadius(16)
                
                //MARK: Note
                //                HStack{
                //                    Text("Note: ")
                //                        .font(.appSemiBold(15))
                //                        .foregroundColor(Color.black)
                //                    + Text("Please record missing details along with service name")
                //                        .font(.appRegular(15))
                //                        .foregroundColor(Color.black)
                //                    Spacer()
                //                }
                Text("**Note:** Please record missing details along with service name")
                    .font(.appRegular(15))
                    .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                //MARK: Recording Button
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color.linearGradient3,
                                                    Color.linearGradient4,
                                                    Color.navyBlueCTA700],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(audioManager.isRecording ? "Recording" : "mic-01")
                        .font(.system(size: 63))
                        .foregroundColor(.white)
                }
                .frame(width: 137, height: 137)
                .background(
                    RoundedRectangle(cornerRadius: 137/2)
                        .fill(Color.white)
                )
                .cornerRadius(137/2)
                .shadow(color: Color.dropShadow, radius: 2, x: 0, y: 2)
                .frame(maxWidth: .infinity, alignment: .center)
                .onTapGesture {
                    if audioManager.hasRecording && !audioManager.isRecording{
                        
                    }else{
                        if !audioManager.isRecording{
                            audioManager.startRecording()
                        }
                    }
                }
                
                //MARK: Timer
                Text("\(formatTime(TimeInterval(Int(audioManager.recordTime))))")
                    .font(.appSemiBold(28))
                    .foregroundColor(Color.navyBlueCTA700)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                //                    .padding(.bottom, 24)
                
                HStack(spacing: 10){
                    //MARK: Discard Button
                    GradientBorderButton(title      : "Discard",
                                         isBtn      :true,
                                         buttonImage: "discardIcon",
                                         action     :{
                        audioManager.pausePlayback()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showDiscardPopup = true
                        }
                    },
                                         buttonHeight: 56)
                    .opacity(audioManager.hasRecording && !audioManager.isRecording ? 1.0 : 0.5)
                    .disabled(audioManager.hasRecording && !audioManager.isRecording ? false : true)
                    
                    //MARK: Stop and Submit buttons
                    if audioManager.hasRecording && !audioManager.isRecording{
                        CustomButton(
                            title       : "Submit",
                            background  : .navyBlueCTA700,
                            textColor   : .neutralDisabled200White,
                            action      : submitAction
                        )
                        .padding(.top, 17)
                        .padding(.bottom, 20)
                    }else{
                        CustomButton(
                            title       : "Stop",
                            background  : .systemError,
                            textColor   : .disCardRed,
                            action      : stopBtnActn
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    Color("redColor"),
                                    lineWidth: 1
                                )
                        )
                        .padding(.top, 17)
                        .padding(.bottom, 20)
                        .opacity(!audioManager.isRecording ? 0.5 : 1.0)
                        .disabled(!audioManager.isRecording)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            Spacer()
        }
        .background(Color.neutralBg100)
        .sheet(isPresented: $showPermissionAlert) {
            PermissionSheet(onDelegate: {
                //dismiss()
            }, title: "We need microphone access to add subscriptions by voice", type: "voice", value: "Tap Microphone")
            .id(UUID())
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(580)])
        }
        .sheet(isPresented: $showDiscardPopup) {
            InfoAlertSheet(
                onDelegate: {
                    audioManager.discardAll()
                }, title    : "Are you sure you want to discard the recording?",
                subTitle    : "",
                imageName   : "infoIcon",
                buttonIcon  : "deleteIcon",
                buttonTitle : "Discard"
            )
            .id(UUID())
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(350)])
        }
        .onChange(of: audioManager.requiredPermission) { _ in
            if audioManager.requiredPermission{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showPermissionAlert = true
                }
            }
        }
    }
    
    //MARK: - User defined methods
    //MARK: stop action
    func stopBtnActn(){
        audioManager.stopRecording()
//        audioManager.playLatestRecording()
    }
    
    //MARK: Submit action
    private func submitAction() {
        if let url = audioManager.audioURL{
            onSubmit?(url)
        }
        dismiss()
    }
    
    //MARK: skipToContinue action
    private func skipToContinue() {
        onSkipToContinue?()
        dismiss()
    }
}

//MARK: - MissingDetailItem
struct MissingDetailItem: View {
    
    //MARK: - Properties
    var title                               : String?
    var description                         : String?
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack{
                Text(LocalizedStringKey(title ?? ""))
                    .font(.appSemiBold(18))
                    .foregroundStyle(.neutralMain700)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            Text(LocalizedStringKey(description ?? ""))
                .font(.appRegular(18))
                .foregroundStyle(.neutralMain700)
                .multilineTextAlignment(.leading)
                .padding(.leading, 19)
        }
        .background(Color.clear)
    }
}
