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
    
    struct EditableCardWrapper: Identifiable {
        let id = UUID()
        let data: ListUserCardsResponseData
    }
    
    //MARK: - Body
    var body: some View {
        VStack{
            //Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image("back_gray")
                        .frame(width: 24,height: 24)
                }
                
                Text("My Cards")
                    .font(.appRegular(24))
                    .foregroundColor(.neutralMain700)
                
                Spacer()
                
                Button("Add") {
                    addCard()
                }
                .foregroundColor(.neutralDisabled200White)
                .padding(.horizontal, 18)
                .padding(.vertical, 4)
                .background(Color.navyBlueCTA700)
                .cornerRadius(5)
                .frame(width: 75, height: 27)
            }
            .frame(height: 32)
            
            if manualVM.listUserCardsResponse == nil || manualVM.listUserCardsResponse?.count == 0{
                VStack(alignment: .center, spacing: 9){
                    Spacer()
                    Image("noCard")
                        .frame(width: 100, height: 100)
                    Text("No Cards Added Yet")
                        .font(.appBold(16))
                        .foregroundStyle(Color.neutral800)
                        .multilineTextAlignment(.center)
                    Text("Add a card to manage your subscriptions and payments easily.")
                        .font(.appRegular(16))
                        .foregroundStyle(Color.grayText)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
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
                    }
                    .padding(.top, 20)
                }
                .scrollDisabled(isScrollDisabled)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.neutralBg100)
        .navigationBarBackButtonHidden(true)
        .onAppear{
            userCardsApi()
        }
        .sheet(isPresented: $addCardSheet) {
            AddNewCardSheet(shouldCallAPI   : $shouldCallAPI,
                            action: {
                self.userCardsApi()
            })
            .onAppear {
                DispatchQueue.main.async {
                    sheetHeight = sheetHeight
                }
            }
            .id(sheetID)
            .overlay {
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: InnerHeightPreferenceKey.self,
                            value: geo.size.height
                        )
                }
            }
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 150 {
                    sheetHeight = height
                }
            }
            .presentationDetents([.height(sheetHeight)])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(false)
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
            .presentationDetents([.height(500), .large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showDeletePopup) {
            InfoAlertSheet(
                onDelegate: {
                    deleteCard()
                }, title    : "Are you sure you want to delete the subscriptions?\nData will be permanently deleted",
                subTitle    :"",
                imageName   : "del_red_big",
                buttonIcon  : "deleteIcon",
                buttonTitle : "Delete",
                imageSize   : 70
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(340)])
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
                gradient: Gradient(colors: [Color.blackLG, Color.grayLG]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        case 1:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blueLG, Color.darkBlueLG]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2:
            return LinearGradient(
                gradient: Gradient(colors: [Color.orangeLG, Color.brownLG]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(gradient: Gradient(colors: [.gray]), startPoint: .leading, endPoint: .trailing)
        }
    }
}

#Preview {
    MyCardsView()
}

//MARK: - CardView
struct CardView: View {
    let card            : ListUserCardsResponseData
    let linearGradient  : LinearGradient
    
    var body: some View {
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
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .font(.appBold(20))
                        .lineSpacing(4)
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
    }
    
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
    let swipeThreshold: CGFloat = -80
    let menuWidth: CGFloat      = 145
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack {
                HStack{
                    VStack(spacing: 8){
                        Image("del_white")
                        Text("Delete")
                            .font(.appSemiBold(14))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 80, height: 148)
            }
            .frame(width: 80, height: 148)
            .background(Color("redColor"))
            .clipShape(
                RoundedCorner(
                    radius: 14,
                    corners: [.topRight, .bottomRight]
                )
            )
            .overlay(
                RoundedCorner(
                    radius: 14,
                    corners: [.topRight, .bottomRight]
                )
                .stroke(Color.neutral300Border, lineWidth: 1)
            )
            .onTapGesture {
                withAnimation {
                    offset = 0
                    isSwiped = false
                }
                onDelete()
            }
            
            VStack(spacing: 8) {
                Image("edit_white")
                Text("Edit")
                    .font(.appSemiBold(14))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 148)
            .background(Color("green"))
            .clipShape(
                RoundedCorner(
                    radius: 14,
                    corners: [.topRight, .bottomRight]
                )
            )
            .overlay(
                RoundedCorner(
                    radius: 14,
                    corners: [.topRight, .bottomRight]
                )
                .stroke(Color.neutral300Border, lineWidth: 1)
            )
            .offset(x: -75)
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
