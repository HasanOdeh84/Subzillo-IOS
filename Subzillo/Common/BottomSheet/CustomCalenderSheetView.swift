//
//  CustomCalenderSheet.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/11/25.
//

import SwiftUI

struct CustomCalenderSheet: View {
    
    //MARK: - Properties
    @Binding var isPresented    : Bool
    @Binding var selectedMonth  : Int
    @Binding var selectedYear   : Int
    let onDone                  : () -> Void
    //    let months  = Array(1...12)
    let months                  = ["January", "February", "March", "April", "May", "June",
                                   "July", "August", "September", "October", "November", "December"]
    let years                   = Array(2025...(Calendar.current.component(.year, from: Date()) + 100))
    
    //MARK: - body
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top,20)
            
            Text("Select month and year")
                .font(.headline)
            
            HStack(spacing: 16) {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(Array(months.enumerated()), id: \.offset) { index, month in
                        //                    ForEach(months, id: \.self) { month in
                        //                        Text(String(format: "%02d", month)).tag(month)
                        Text(month).tag(index+1)
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(.wheel)
                
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(.wheel)
            }
            .frame(height: 150)
            
            CustomButton(title: "Ok"){
                onDone()
                isPresented = false
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Color.whiteBlackBG)
    }
}

struct CustomYearBottomSheet: View {
    
    //MARK: - Properties
    @Binding var isPresented    : Bool
    @State var selectedYear     : Int = 2025
    let onDone                  : (Int) -> Void
    let years                   = Array(2025...(Calendar.current.component(.year, from: Date()) + 100))
    
    //MARK: - body
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.grayCapsule)
                .frame(width: 150, height: 5)
                .padding(.top,20)
            
            Text("Select year")
                .font(.headline)
            
            HStack() {
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(.wheel)
            }
            .frame(height: 150)
            
            CustomButton(title: "Ok"){
                onDone(selectedYear)
                isPresented = false
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Color.whiteBlackBG)
    }
}
