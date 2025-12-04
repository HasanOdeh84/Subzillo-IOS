//
//  SubscriptionsViewModel.swift
//  Subzillo
//
//  Created by Ratna Kavya on 06/11/25.
//

import SwiftUI
import Combine
import SwiftUICore
import SDWebImageSwiftUI

class SubscriptionsViewModel: ObservableObject {
    
    private var subscriptions                 = Set<AnyCancellable>()
    var apiReference                          = NetworkRequest.shared
    private let router                        : AppIntentRouter
    @Published var listSubsResponse           : ListSubscriptionsResponseData?
    @Published var getSubsByMonthResponse     : MonthlySubscriptionsData?
    @Published var isDeletedSubscription      : Bool?
    
    init(router: AppIntentRouter = .shared) {
        self.router = router
    }
    
    func listSubscriptions(input: ListSubscriptionsRequest,showLoader:Bool = true) {
        apiReference.postApi(endPoint: APIEndpoint.listSubscriptions, method: .POST,token: authKey,body: input,showLoader: showLoader, responseType: ListSubscriptionsResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.listSubscriptions)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.listSubsResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func getSubscriptionsByMonth(input: GetSubscriptionsByMonthRequest) {
        apiReference.postApi(endPoint: APIEndpoint.getSubscriptionsByMonth, method: .POST,token: authKey,body: input,showLoader: true, responseType: MonthlySubscriptionsResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    self.handleError(error,endPoint: APIEndpoint.getSubscriptionsByMonth)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.getSubsByMonthResponse = response.data
        }
        .store(in: &self.subscriptions)
    }
    
    func deleteSubscription(input: DeleteSubscriptionRequest) {
        isDeletedSubscription = false
        apiReference.postApi(endPoint: APIEndpoint.deleteSubscription, method: .POST,token: authKey,body: input,showLoader: true, responseType: GeneralResponse.self)
            .sink { [unowned self] completion in
                if case let .failure(error) = completion {
                    isDeletedSubscription = false
                    self.handleError(error,endPoint: APIEndpoint.deleteSubscription)
                }
            }
        receiveValue: { response in
            PrintLogger.modelLog(response, type: .response, isInput: false)
            self.isDeletedSubscription = true
        }
        .store(in: &self.subscriptions)
    }
    
    func navigate(to route: NavigationRoute){
        self.router.navigate(to: route)
    }
    
    // MARK: - Handle errors
    func handleError(_ apiError: APIError, endPoint : APIEndpoint) {
        print("API Error : \(endPoint) - \(apiError.localizedDescription)")
    }
}

struct SubscriptionRow: View {
    let subscriptionData: SubscriptionInfoo
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center,spacing: 5){
                let result = getDayInfo(from: subscriptionData.createdAt ?? "")
                Text(result.dayName.uppercased())
                    .font(.appSemiBold(14))
                    .foregroundColor(.navyBlueCTA700)
                    .multilineTextAlignment(.center)
                    .frame(width: 60, alignment: .center)
                    .background(Color.primeryBlue100)
                    .autocapitalization(.allCharacters)
                
                Text(result.dayNumber)
                    .font(.appSemiBold(24))
                    .foregroundColor(.navyBlueCTA700)
                    .multilineTextAlignment(.center)
                    .frame(width: 60, alignment: .center)
                    .background(Color.primeryBlue100)
            }
            .frame(height: calculatedHeight(for: subscriptionData))
            .background(Color.primeryBlue100)
            
            DashedVerticalDivider()
            
            HStack(spacing: 0) {
                
                VStack(spacing: 8) {
                    
                    let isOpen = subscriptionData.isOpen ?? false
                    
                    HStack(spacing: 0) {
                        Text("\(subscriptionData.currency ?? "") \(String(describing: subscriptionData.amount ?? 0.0))")
                            .font(.appSemiBold(24))
                            .foregroundColor(.navyBlueCTA700)
                        
                        if subscriptionData.status == "expired"{
                            Text("Expired")
                                .font(.appBold(14))
                                .foregroundColor(.disCardRed)
                                .multilineTextAlignment(.leading)
                                .padding(.leading,8)
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            if isOpen == false {
                                if subscriptionData.relations!.count < 3
                                {
                                    ForEach(Array(subscriptionData.relations!.enumerated()), id: \.offset) { index, card in
                                        if card.name == "" && card.color == ""{
                                            RelationView(name: "Me", color: "#619BEE")
                                        }else{
                                            RelationView(name: card.name ?? "", color: card.color ?? "")
                                        }
                                    }
                                }
                                else{
                                    ForEach(Array(subscriptionData.relations!.prefix(3).enumerated()), id: \.offset) { index, card in
                                        if card.name == "" && card.color == ""{
                                            RelationView(name: "Me", color: "#619BEE")
                                        }else{
                                            RelationView(name: card.name ?? "", color: card.color ?? "")
                                        }
                                    }
                                    
                                    RelationView(isMore: true)
                                }
                            }
                        }
                    }
                    
                    
                    if isOpen == true {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(subscriptionData.relations!.enumerated()), id: \.offset) { index, relation in
                                if relation.name == "" && relation.color == ""{
                                    RelationView(name: "Me", color: "#619BEE")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }else{
                                    RelationView(name: relation.name ?? "", color: relation.color ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                ForEach(Array(relation.plans!.enumerated()), id: \.offset) { index, plan in
                                    PlanDetailsView(
                                        image       : plan.image ?? "",
                                        serviceName : plan.name ?? "",
                                        amount      : "\(plan.amount ?? 0.0)",
                                        currency    : plan.currency ?? "",
                                        card        : plan.card ?? ""
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    else {
                        HStack(spacing: 0) {
                            if subscriptionData.plans!.count < 5
                            {
                                ForEach(Array(subscriptionData.plans!.enumerated()), id: \.offset) { index, card in
                                    AvatarView(serviceName: card.name ?? "", serviceLogo: card.image ?? "", size: 24, cornerRadius: 12,fontSize: 14)
                                        .offset(x: CGFloat(-10 * index), y: 0)
                                }
                            }
                            else{
                                ForEach(Array(subscriptionData.plans!.prefix(5).enumerated()), id: \.offset) { index, card in
                                    AvatarView(serviceName: card.name ?? "", serviceLogo: card.image ?? "", size: 24, cornerRadius: 12,fontSize: 14)
                                        .offset(x: CGFloat(-10 * index), y: 0)
                                }
                                
                                PlanView(isMore: true)
                                    .offset(x: CGFloat(-10 * 5), y: 0)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 20)
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.leading, 16)
            .padding(.trailing, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: calculatedHeight(for: subscriptionData))
        .background(.whiteNeutralCardBG)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .cornerRadius(8)
        .padding(.bottom, 8)
    }
    
    func calculatedHeight(for subscriptionData: SubscriptionInfoo) -> Double {
        guard subscriptionData.isOpen ?? false else {
            return 76
        }
        
        var heightValue = 0.0
        if let relations = subscriptionData.relations {
            for relation in relations {
                let plansCount = relation.plans?.count ?? 0
                heightValue += Double(32 + (32 * plansCount))
            }
        }
        
        return 52 + heightValue
    }
    
    func getDay(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let day = Calendar.current.component(.day, from: date)
        return String(day)
    }
    
    func getDayInfo(from dateString: String) -> (dayNumber: String, dayName: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else {
            return ("", "")
        }
        // Day number
        let dayNumber = Calendar.current.component(.day, from: date)
        // Day name (Mon, Tue, Wed...)
        formatter.dateFormat = "EEE"   // 3-letter day name
        let dayName = formatter.string(from: date)
        return ("\(dayNumber)", dayName)
    }
}

struct DashedVerticalDivider: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
            }
            .stroke(Color.dottedLine, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
        }
        .frame(width: 1)
    }
}

struct DashedHorizontalDivider: View {
    var dash: [CGFloat] = [3, 3]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
            }
            .stroke(Color.dottedLine, style: StrokeStyle(lineWidth: 1, dash: dash))
        }
        .frame(height: 1)
    }
}

struct PlanView: View {
    var isMore          : Bool = false
    var image           : String?
    
    var body: some View {
        VStack
        {
            if isMore == true {
                Image("arrow-right-01")
            }
            else{
                Image(image!)
            }
        }
        .frame(width: 24, height: 24, alignment: .center)
        .background(Color.fieldBG)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral300Border, lineWidth: 1)
        )
        .shadow(color: Color.dropShadow, radius: 2, x: 0, y: 2)
        .cornerRadius(12)
    }
}

struct RelationView: View {
    var isMore          : Bool = false
    var name            : String?
    var color           : String?
    
    var body: some View {
        VStack
        {
            if isMore == true {
                Text("...")
                    .font(.appRegular(24))
                    .foregroundColor(.whiteBlackBGnoPic)
            }
            else{
                Text(name!)
                    .font(.appRegular(12))
                    .foregroundColor(.fieldBG)
            }
        }
        .padding(.horizontal, isMore ? 0 : 8)
        .frame(height: 24)
        .background(isMore ? Color.clear : Color(hex: color!))
        .cornerRadius(4)
        
    }
}

struct PlanDetailsView: View {
    var image           : String?
    var serviceName     : String?
    var amount          : String?
    var currency        : String?
    var card            : String?
    
    var body: some View {
        VStack
        {
            //            HStack(spacing: 8) {
            //                AvatarView(serviceName: serviceName ?? "", serviceLogo: image ?? "", size: 24, cornerRadius: 12,fontSize: 14)
            //
            //                Text("\(currency ?? "")\(amount ?? "")")
            //                    .font(.appRegular(12))
            //                    .foregroundColor(.neutralMain700)
            //                if card != ""{
            //                    DashedHorizontalDivider()
            //                        .layoutPriority(0)
            //                    Text("on")
            //                        .font(.appRegular(12))
            //                        .foregroundColor(.neutral500)
            //                        .multilineTextAlignment(.trailing)
            //                    Text(card ?? "")
            //                        .font(.appRegular(12))
            //                        .foregroundColor(Color.neutralMain700)
            ////                        .multilineTextAlignment(.trailing)
            //                        .layoutPriority(1)
            //                        .padding(.trailing, 12)
            //                }
            //                Spacer()
            //            }
            
            HStack(spacing: 8) {
                AvatarView(serviceName: serviceName ?? "",
                           serviceLogo: image ?? "",
                           size: 24,
                           cornerRadius: 12,
                           fontSize: 14)
                
                Text("\(currency ?? "")\(amount ?? "")")
                    .font(.appRegular(12))
                    .foregroundColor(.neutralMain700)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if let cardText = card, !cardText.isEmpty {
                    DashedHorizontalDivider()
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .layoutPriority(0)
                    
                    HStack(spacing: 6) {
                        Text("on")
                            .font(.appRegular(12))
                            .foregroundColor(.neutral500)
                            .fixedSize()
                        
                        Text(cardText)
                            .font(.appRegular(12))
                            .foregroundColor(.neutralMain700)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fixedSize()
                    }
                    .layoutPriority(1)
                }else{
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .background(Color.clear)
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 24)
        .background(Color.clear)
    }
}

struct CancelDeleteView: View {
    
    //MARK: - Properties
    var leftImage                   : String
    var rightImage                  : String
    var leftText                    : String
    var rightText                   : String
    let cancelAction                : () -> Void
    let deleteAction                : () -> Void
    
    //MARK: - body
    var body: some View {
        HStack(spacing: 8) {
            
            // MARK: - cancel Button
            Button() {
                cancelAction()
            } label: {
                HStack(spacing: 5) {
                    Image(leftImage)
                        .resizable()
                        .frame(width: 17, height: 17)
                    
                    Text(LocalizedStringKey(leftText))
                        .font(.appSemiBold(14))
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    Color.clear
                )
                .cornerRadius(8)
                .overlay(
                    // keep the stroke visually inside by padding the shape inward
                    RoundedCorner(radius: 8)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
            }
            
            // MARK: - Delete Button
            Button() {
                deleteAction()
            } label: {
                HStack(spacing: 5) {
                    Image(rightImage)
                        .resizable()
                        .frame(width: 17, height: 19)
                    
                    Text(LocalizedStringKey(rightText))
                        .font(.appSemiBold(14))
                        .foregroundColor(Color.disCardRed)
                }
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color.systemError)
                .cornerRadius(8)
                .overlay(
                    // keep the stroke visually inside by padding the shape inward
                    RoundedCorner(radius: 8)
                        .stroke(
                            Color.disCardRed,
                            lineWidth: 1
                        )
                )
            }
        }
        .frame(height: 44)
    }
}
