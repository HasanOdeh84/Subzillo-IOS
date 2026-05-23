//
//  MyCardsView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 26/12/25.
//

import SwiftUI

struct MyCardsView: View {
    
    //MARK: - Properties
    @StateObject var manualVM           = ManualEntryViewModel()
    @StateObject var myCardsVM          = MyCardsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State var editCardSheet            = false
    @State var addCardSheet             = false
    @State private var shouldCallAPI    = false
    @State var showDeletePopup          : Bool = false
    @State var cardId                   = ""
    @State var editCardData             : ListUserCardsResponseData?
    @State private var activeCardId     : String? = nil
    @State private var editingCard      : EditableCardWrapper?
    @State private var isScrollDisabled : Bool = false
    @State private var sheetHeight              : CGFloat = .zero
    @State private var sheetID                  = UUID()
    @EnvironmentObject var themeManager         : ThemeManager
    @Environment(\.colorScheme) var colorScheme
    struct EditableCardWrapper: Identifiable {
        let id = UUID()
        let data: ListUserCardsResponseData
    }
    
    @State private var deleteSheetHeight        : CGFloat = .zero

    //MARK: - Body
    var body: some View {
        VStack{
            
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: {
                    AppIntentRouter.shared.pop()
                }) {
                    HStack {
                        
                        if colorScheme == .dark
                        {
                            Image("back_gray")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                        }
                        else{
                            Image("back_gray")
                        }
                    }
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(themeManager.white_white4)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                themeManager.black_white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("My Cards")
                        .font(.geistBold(16))
                        .foregroundColor(
                            Color("TextPrimary_ 0E101A_F4F1FB")
                        )
                }
                
                Spacer()
                
                // MARK: - Empty Space
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            if manualVM.listUserCardsResponse == nil || manualVM.listUserCardsResponse?.count == 0{
                VStack(alignment: .center, spacing: 9){
                    Spacer()
                    Image("noCard")
                        .frame(width: 100, height: 100)
                    Text("No Cards Added Yet")
                        .font(.geistSemiBold(16))
                        .foregroundStyle(.textPrimary0E101AF4F1FB)
                        .multilineTextAlignment(.center)
                    Text("Add a card to manage your subscriptions and payments easily.")
                        .font(.geistRegular(14))
                        .foregroundStyle(.textPrimary0E101AF4F1FB.opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    addButton
                        .padding(.top, 20)
                        .padding(.bottom, 126)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }else{
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(Array((manualVM.listUserCardsResponse ?? []).enumerated()), id: \.element.id) { index, card in
                            SwipeableCardRow(
                                card            : card,
                                linearGradient  : getGradient(for: index),
                                activeCardId    : $activeCardId,
                                isScrollDisabled: $isScrollDisabled,
                                onEdit: {
                                    print("Edit tapped for \(card.nickName ?? "")")
                                    editingCard = EditableCardWrapper(data: card)
                                },
                                onDelete: {
                                    print("Delete tapped for \(card.nickName ?? "")")
                                    cardId = card.id ?? ""
                                    showDeletePopup = true
                                }
                            )
                        }
                        addButton
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                .scrollDisabled(isScrollDisabled)
            }
            
        }
        
        .padding(.vertical, 16)
        .applyAppBackground()
        .navigationBarBackButtonHidden(true)
        .onAppear{
            userCardsApi()
        }
        .sheet(isPresented: $addCardSheet) {
            AddNewCardSheet(shouldCallAPI   : $shouldCallAPI,
                            action: {
                self.userCardsApi()
            })
//            .onAppear {
//                DispatchQueue.main.async {
//                    sheetHeight = sheetHeight
//                }
//            }
//            .id(sheetID)
//            .overlay {
//                GeometryReader { geo in
//                    Color.clear
//                        .preference(
//                            key: InnerHeightPreferenceKey.self,
//                            value: geo.size.height
//                        )
//                }
//            }
//            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
//                if height > 150 {
//                    sheetHeight = height
//                }
//            }
//            .presentationDetents([.height(sheetHeight)])
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
//            .interactiveDismissDisabled(false)
        }
        .sheet(item: $editingCard) { wrapper in
            AddNewCardSheet(nickName        : wrapper.data.nickName ?? "",
                            cardNumber      : wrapper.data.cardNumber ?? "",
                            cardName        : wrapper.data.cardHolderName ?? "",
                            shouldCallAPI   : $shouldCallAPI,
                            isEdit          : true,
                            cardId          : wrapper.data.id ?? "",
                            action: {
                self.userCardsApi()
            })
            .presentationDetents([.medium, .large])
//            .presentationDetents([.height(500), .large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showDeletePopup) {
            InfoAlertSheet(
                onDelegate: {
                    deleteCard()
                }, title    : "Are you sure you want to delete this card?\n This card will be permanently removed.",
                subTitle    :"",
                imageName   : "del_red_new",
                buttonIcon  : "del_red_newSmall",
                buttonTitle : "Delete",
                imageSize   : 70
            )
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
        .onChange(of: myCardsVM.isDelete) { value in
            if value == true{
                userCardsApi()
            }
        }
    }
    
    //MARK: - User defined methods
    func userCardsApi(){
        manualVM.listUserCards(input: ListUserCardsRequest(userId: Constants.getUserId()))
    }
    
    func addCard(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sheetID = UUID()
            activeCardId = nil
            addCardSheet = true
        }
    }
    
    func editCard(){
        editCardSheet = true
    }
    
    func deleteCard(){
        let input = DeleteCardRequest(userId: Constants.getUserId(), cardId: cardId)
        myCardsVM.deleteCard(input: input)
    }
    
    func getGradient(for index: Int) -> LinearGradient {
        let remainder = index % 3
        switch remainder {
        case 0:
            return LinearGradient(
                gradient: Gradient(colors: [.brandFromDarkA719DD, .brandMidDark7C5CFF, .brandToDark4489EB]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        case 1:
            return LinearGradient(
                gradient: Gradient(colors: [.sunsetFromF35BB3, .sunsetMidCB61FA, .sunsetTo764CFF]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2:
            return LinearGradient(
                gradient: Gradient(colors: [.auroraFrom13D8B0, .auroraMid5598EA, .auroraTo9A28DF]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [.brandFromDarkA719DD, .brandMidDark7C5CFF, .brandToDark4489EB]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
    }
}

#Preview {
    MyCardsView()
}

extension MyCardsView {
    
    var addButton: some View {
        
        VStack{
            Button {
                addCard()
            } label: {
                
                HStack(spacing: 8) {
                    
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Add card")
                        .font(.geistSemiBold(15))
                }
                .foregroundStyle(Color.textPrimary0E101AF4F1FB)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(themeManager.white_white4)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(
                            Color.textPrimary0E101AF4F1FB.opacity(0.08),
                            lineWidth: 0
                        )
                }
                .shadow(
                    color: themeManager.black_white.opacity(0.04),
                    radius: 6,
                    y: 2
                )
            }
        }
    }
}
//MARK: - CardView
struct CardView: View {
    let card            : ListUserCardsResponseData
    let linearGradient  : LinearGradient
    
    var body: some View {
        
        ZStack {
            
            // MARK: Background Gradient
            
            linearGradient
            
            // MARK: Decorative Circles
            
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 160, height: 160)
                .offset(x: 80, y: -80)
            
            Circle()
                .fill(Color.black.opacity(0.15))
                .frame(width: 180, height: 180)
                .offset(x: -90, y: 90)
            
            // MARK: Content
            
            VStack(alignment: .leading) {
                
                // MARK: Top
                
                HStack(alignment: .top) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("SUBZILLO · CARD")
                            .font(.jetBrainsRegular(10))
                            .tracking(2)
                            .opacity(0.7)
                        
                        if card.isPrimary == true {
                            Text("PRIMARY")
                                .font(.jetBrainsRegular(9))
                                .tracking(1)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Color.white.opacity(0.2)
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 4)
                                )
                        }
                        
                        Text("\(card.nickName ?? "")")
                            .font(
                                .geistSemiBold(13)
                            )
                    }
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 36, height: 28)
                }
                
                Spacer()
                
                // MARK: Card Number
                
                Text("•••• •••• •••• \(card.cardNumber ?? "")")
                    .font(.jetBrainsMedium(18))
                    .tracking(3)
                
                Spacer()
                
                // MARK: Bottom
                
                HStack(alignment: .bottom) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("CARDHOLDER")
                            .font(.jetBrainsRegular(8))
                            .tracking(1)
                            .opacity(0.6)
                        
                        Text("\(card.nickName ?? "")")
                            .font(
                                .system(size: 13, weight: .semibold)
                            )
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("")
                            .font(.jetBrainsRegular(8))
                            .tracking(1)
                            .opacity(0.6)
                        
                        Text("")
                            .font(
                                .geistSemiBold(13)
                            )
                    }
                    
                    Spacer()
                    
                    Text("\(card.cardHolderName ?? "")")
                        .font(
                            .jetBrainsBoldItalic(18)
                        )
                }
            }
            .padding(20)
            .foregroundStyle(.white)
        }
        .frame(height: 200)
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
        .shadow(
            color: .black.opacity(0.3),
            radius: 25,
            y: 20
        )
    }
    /*{
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(linearGradient)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(formatName(card.cardHolderName ?? ""))
                        .font(.appMedium(12))
                        .foregroundColor(.white)
                        .padding(.top, 14)
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Image("sim")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 25)
                    
                    Image("wave")
                        .frame(width: 14, height: 13)
                    
                    Spacer()
                }
                
                HStack {
                    Text("****   ****   ****   \(card.cardNumber ?? "")")
//                        .font(.system(size: 20, weight: .bold, design: .monospaced))
//                        .font(.appBold(20))
//                        .lineSpacing(4)
//                        .minimumScaleFactor(0.7)
//                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                            .allowsTightening(true)
                            .foregroundColor(.white)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(card.nickName ?? "")
                        .font(.appSemiBold(11))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 2)
                        .frame(height: 20)
                        .background(LinearGradient(
                            gradient        : Gradient(colors: [Color.lightGreenLG, Color.greenLG]),
                            startPoint      : .topLeading,
                            endPoint        : .bottomTrailing
                        ))
                        .cornerRadius(14, corners: [.topLeft])
                        .cornerRadius(14, corners: [.bottomRight])
                }
            }
        }
        .frame(height: 148)
    }*/
    
    func formatName(_ name: String) -> String {
        return name.map { String($0) }.joined(separator: " ").uppercased()
    }
}

//MARK: - SwipeableCardRow
struct SwipeableCardRow: View {
    let card                    : ListUserCardsResponseData
    let linearGradient          : LinearGradient
    @Binding var activeCardId   : String?
    @Binding var isScrollDisabled : Bool
    let onEdit                  : () -> Void
    let onDelete                : () -> Void
    @State private var offset   : CGFloat = 0
    @State private var isSwiped : Bool = false
    let swipeThreshold: CGFloat = -70
    let menuWidth: CGFloat      = 135
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack {
                HStack{
                    VStack(spacing: 8){
                        Image("swipeDel")
                        Text("Delete")
                            .font(.jetBrainsBold(11))
                            .foregroundColor(colorScheme == .light ? .textPrimaryDarkF4F1FB : .dangerDarkFF5A7A)
                    }
                    .padding(.leading, 20)
                    .frame(alignment: .trailing)
                    .frame(width: 80, height: 200)
                }
                .frame(width: 80, height: 200)
            }
            .frame(width: 100, height: 200)
            .background(colorScheme == .light ? .dangerLightE43C5C : .dangerLightE43C5C.opacity(0.4))
            .clipShape(
                RoundedCorner(
                    radius: 25,
                    corners: [.topRight, .bottomRight]
                )
            )
            .overlay(
                RoundedCorner(
                    radius: 25,
                    corners: [.topRight, .bottomRight]
                )
                .stroke(colorScheme == .light ? .E_2_E_8_F_0 : .dangerLightE43C5C.opacity(0.40), lineWidth: 1)
            )
            .onTapGesture {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
                onDelete()
            }
            
            VStack(spacing: 8) {
                VStack(spacing: 8){
                    Image("swipeEdit")
                    Text("Edit")
                        .font(.jetBrainsBold(11))
                        .foregroundColor(colorScheme == .light ? .textPrimaryDarkF4F1FB : .successDark5CE4A8)
                }
                .padding(.leading, 15)
                .frame(alignment: .trailing)
                .frame(width: 70, height: 200)
            }
            .frame(width: 90, height: 200)
            .background(colorScheme == .light ? .successLight0EA870 : .successLight0EA870.opacity(0.4))
            .clipShape(
                RoundedCorner(
                    radius: 25,
                    corners: [.topRight, .bottomRight]
                )
            )
            .overlay(
                RoundedCorner(
                    radius: 25,
                    corners: [.topRight, .bottomRight]
                )
                .stroke(colorScheme == .light ? .E_2_E_8_F_0 : .successDark5CE4A8.opacity(0.40), lineWidth: 1)
            )
            .offset(x: -70)
            .zIndex(0)
            .onTapGesture {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
                onEdit()
            }
            
            // Top Card Layer
            CardView(card: card, linearGradient: linearGradient)
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
                            withAnimation(.spring()) {
                                if value.translation.width < swipeThreshold {
                                    self.offset = -menuWidth
                                    self.isSwiped = true
                                    self.activeCardId = card.id
                                    print("3")
                                } else {
                                    self.offset = 0
                                    self.isSwiped = false
                                    if self.activeCardId == card.id {
                                        self.activeCardId = nil
                                    }
                                    print("4")
                                }
                            }
                        }
                )
                .zIndex(1)
        }
        .padding(.horizontal, 20)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .onChange(of: activeCardId) { newValue in
            if newValue != card.id && (offset != 0 || isSwiped) {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
            }
        }
    }
}
