//
//  ManualEntryView.swift
//  Subzillo
//
//  Created by Ratna Kavya on 08/11/25.
//

import SwiftUI
import UIKit

struct ManualEntryView: View {
    
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary

    
    @State private var serviceName         : String = ""
    @State private var amount              : String = ""
    @State private var currency            : String = ""
    @State private var planType            : String = ""
    @State private var chargeDate          : String = ""
    @State private var catrgory            : String = ""
    @State private var paymentMethod       : String = ""
    @State private var notes               : String = ""
    @State private var isDatePickerPresented = false
    @State private var tempDate = Date()
    @State private var billingIndex        : Int = 0
    @State private var cardIndex           : Int = 0
    @State private var relationIndex       : Int = 0
    @State private var reminderInedex      : Int = 0
    @State private var isMoreEnable        : Bool = false
    
    @State private var billingData = [
        ManualDataInfo(id: "1", title: "Daily", subtitle: "Every 24 hours"),
        ManualDataInfo(id: "2", title: "Weekly", subtitle: "Every 7 Days"),
        ManualDataInfo(id: "3", title: "Monthly", subtitle: "Every 30 Days"),
        ManualDataInfo(id: "4", title: "Quarterly", subtitle: "Every 90 Days"),
        ManualDataInfo(id: "5", title: "Biannually", subtitle: "Every 180 Days"),
        ManualDataInfo(id: "6", title: "Yearly", subtitle: "Every 360 Days"),
        ManualDataInfo(id: "7", title: "Lifetime", subtitle: "Limitless")
    ]
    
    @State private var cardsData = [
        ManualDataInfo(id: "1", title: "My VISA", subtitle: "471 *********1234"),
        ManualDataInfo(id: "2", title: "MOM CARD", subtitle: "477 *********4321"),
        ManualDataInfo(id: "3", title: "MASTE CARD", subtitle: "480 *********1234")
    ]
    
    @State private var relationsData = [
        ManualDataInfo(id: "1", title: "Me"),
        ManualDataInfo(id: "2", title: "Mom"),
        ManualDataInfo(id: "3", title: "Son")
    ]
    
    @State private var remindersData = [
        ManualDataInfo(id: "1", title: "3 days before renewal"),
        ManualDataInfo(id: "2", title: "1 day before renewal"),
        ManualDataInfo(id: "3", title: "On renewal day")
    ]
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: goBack) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: - Title
                    Text("Manual Entry")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    // MARK: - SubTitle
                    Text("in Ut laoreet porta at, nec facilisi")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutral500)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 0)
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Required Information")
                        .font(.appRegular(18))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .layoutPriority(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 28)
                    
                    FieldView(text: $serviceName, title: "Service Name", image: "gridIcon", placeHolder: "e.g. Netflix, Spotify, Adobe")

                    HStack(spacing: 24) {
                        FieldView(text: $amount, title: "Amount", image: "currencyIcon", placeHolder: "0.00")
                        Button(action: currencySelection) {
                            FieldView(text: $currency, title: "Currency", image: "globeIcon", placeHolder: "USD", isButton: true, isText: true)
                                .frame(width: 140, alignment: .trailing)
                        }
                    }
                    
                    FieldView(text: $planType, title: "Plan Type", image: "gridicon2", placeHolder: "e.g. Free, Pro, Premium")
                    
                    ListView(type: .billing, title: "Billing Cycle", addMore: false, data: $billingData, selectedIndex: $billingIndex)
                        .frame(height: Double(23 + (52 * billingData.count)))
                  
                    Button(action: dateSelection) {
                        FieldView(text: $chargeDate, title: "Next Charge Date", image: "Calendar1", placeHolder: "dd/mm/yyyy", isButton: true, isText: true)
                    }
                    .background(
                        DatePickerPopup(isPresented: $isDatePickerPresented, selectedDate: $tempDate) { date in
                            let formatter = DateFormatter()
                            formatter.dateFormat = "dd/MM/yyyy"
                            chargeDate = formatter.string(from: date)
                            print(chargeDate)
                        }
                    )
                    
                    HStack(spacing: 8) {
                        Text("Optional Details")
                            .font(.appRegular(18))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .layoutPriority(1)
                        DashedHorizontalDivider()
                        Button(action: optionalDetailsAction) {
                            HStack {
                                Image("downArrow")
                                    .rotationEffect(.degrees(isMoreEnable ? 0 : 180))
                                    .animation(.easeInOut(duration: 0.25), value: isMoreEnable)
                            }
                        }
                        .frame(width: 12, height: 7, alignment: .trailing)
                    }
                    .frame(height: 28)
                    
                    if isMoreEnable == true {
                        Button(action: dateSelection) {
                            FieldView(text: $catrgory, title: "Category", image: "gridIcon", placeHolder: "Please select", isButton: true, isText: true)
                        }
                        
                        Button(action: dateSelection) {
                            FieldView(text: $paymentMethod, title: "Payment Method", image: "Calendar2", placeHolder: "Select payment method", isButton: true, isText: true)
                        }
                        
                        ListView(type: .cards, title: "Which card is linked to this subscription?", addMore: true, data: $cardsData, selectedIndex: $cardIndex)
                            .frame(height: Double(75 + (52 * cardsData.count)))
                        
                        ListView(type: .relations, title: "Who will benefit from this subscription?", addMore: true, data: $relationsData, selectedIndex: $relationIndex)
                            .frame(height: Double(75 + (52 * relationsData.count)))
                        
                        ListView(type: .reminders, title: "Renewal Reminders", addMore: false, data: $remindersData, selectedIndex: $reminderInedex)
                            .frame(height: Double(23 + (52 * remindersData.count)))
                        
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.appRegular(14))
                                .foregroundColor(.appNeutralMain700)
                            VStack{
                                TextField("Add any additional notes about this subscription...", text: $notes)
                                    .keyboardType(.default)
                                    .autocapitalization(.none)
                                    .doneOnSubmit()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .font(.appRegular(14))
                                    .foregroundColor(.neutral2_500)
                                Spacer(minLength: 0)
                                
                            }
                            .padding(16)
                            .frame(height: 110)
                            .background(.appBlackWhite)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.neutral_2_200, lineWidth: 1)
                            )
                        }
                        
                        VStack(spacing: 4) {
                            Text("Receipt or Screenshot")
                                .font(.appRegular(14))
                                .foregroundColor(.appNeutralMain700)
                                .frame(maxWidth:.infinity, alignment: .leading)
                            VStack(spacing: 0){
                                Button(action: uploadImage) {
                                    if let image = selectedImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    else {
                                        VStack(spacing: 8){
                                            Image("uploadImage")
                                            Text("Upload receipt or screenshot")
                                                .font(.appRegular(14))
                                                .foregroundColor(.neutral400)
                                            
                                            Text("Choose file")
                                                .font(.appRegular(16))
                                                .foregroundColor(.blueMain700)
                                        }
                                        .padding(16)
                                    }
                                }
                                .confirmationDialog("Select Image", isPresented: $showActionSheet, titleVisibility: .visible) {
                                    Button("Camera") {
                                        pickerSource = .camera
                                        showImagePicker = true
                                    }
                                    Button("Photo Library") {
                                        pickerSource = .photoLibrary
                                        showImagePicker = true
                                    }
                                    Button("Cancel", role: .cancel) { }
                                }
                                .sheet(isPresented: $showImagePicker) {
                                    if pickerSource == .camera {
                                        ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                                            .edgesIgnoringSafeArea(.all)
                                            .ignoresSafeArea()
                                    } else {
                                        ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                                    }
                                }
                            }
                            .frame(maxWidth:.infinity)
                            .frame(height: 110)
                            .background(.appBlackWhite)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.neutral_2_200, lineWidth: 1)
                            )
                        }
                    }
                    CustomButton(title: "Save Subscription", action: saveAction)
                        .padding(.horizontal, 0)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .padding(.top, 10)
        .background(.appBackground)
    }
    
    //MARK: - Button actions
    private func goBack() {
        print(billingData)
    }
    private func infoButtonAction() {
    }
    private func currencySelection() {
    }
    private func dateSelection() {
        withAnimation(.easeInOut) {
            isDatePickerPresented = true
        }
    }
    private func optionalDetailsAction() {
        isMoreEnable.toggle()
    }
    private func uploadImage() {
        showActionSheet = true
    }
    private func saveAction() {
    }
}

#Preview {
    ManualEntryView()
}
