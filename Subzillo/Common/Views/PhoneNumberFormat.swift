//
//  phoneNew.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 22/12/25.
//

import SwiftUI
import libPhoneNumber

final class PhoneNumberFormatterService: ObservableObject {
    
    private let phoneUtil = NBPhoneNumberUtil.sharedInstance()
    //    private(set) var regionCode: String
    @Published private(set) var regionCode: String
    
    private var formatter: NBAsYouTypeFormatter
    
    init(regionCode: String) {
        self.regionCode = regionCode
        self.formatter = NBAsYouTypeFormatter(regionCode: regionCode)
    }
    
    func updateRegion(_ newRegion: String) {
        regionCode = newRegion
        formatter = NBAsYouTypeFormatter(regionCode: newRegion)
    }
    
    //    func format(digits: String) -> String {
    //        formatter.clear()
    //        var result = ""
    //        for c in digits {
    //            result = formatter.inputDigit(String(c))
    //        }
    //        return result
    //    }
    
    func format(digits: String) -> String {
        formatter.clear()
        
        let countryCode = countryCallingCode(for: regionCode)
        let fullNumber = "+" + countryCode + digits
        
        var result = ""
        for c in fullNumber {
            result = formatter.inputDigit(String(c))
        }
        
        let prefix = "+\(countryCode)"
        
        if result.hasPrefix(prefix) {
            let trimmed = result.dropFirst(prefix.count)
            return trimmed.trimmingCharacters(in: .whitespaces)
        }
        
        return result
    }
    
    func countryCallingCode(for region: String) -> String {
        phoneUtil.getCountryCode(forRegion: region).stringValue
    }
    
    //    func placeholder() -> String {
    //        do {
    //            let example = try phoneUtil.getExampleNumber(
    //                forType: regionCode,
    //                type: .MOBILE
    //            )
    //            let formatted = try phoneUtil.format(
    //                example,
    //                numberFormat: .INTERNATIONAL
    //            )
    //
    //            let noTrunk = formatted.trimmingCharacters(in: .whitespaces)
    //                .replacingOccurrences(of: "^0", with: "", options: .regularExpression)
    //
    //            return noTrunk.replacingOccurrences(
    //                of: "\\d",
    //                with: "0",
    //                options: .regularExpression
    //            )
    //        } catch {
    //            return "0000000000"
    //        }
    //    }
    
    func placeholder() -> String {
        do {
            // 1️⃣ Get example number
            let example = try phoneUtil.getExampleNumber(
                forType: regionCode,
                type: .MOBILE
            )
            
            // 2️⃣ Format in INTERNATIONAL style
            let formatted = try phoneUtil.format(
                example,
                numberFormat: .INTERNATIONAL
            )
            
            // 3️⃣ Remove country code prefix safely
            let countryCode = phoneUtil.getCountryCode(forRegion: regionCode).stringValue
            let prefix = "+\(countryCode)"
            
            var withoutPrefix = formatted
            if formatted.hasPrefix(prefix) {
                withoutPrefix = String(formatted.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
            }
            
            // 4️⃣ Replace all digits with 0
            let placeholder = withoutPrefix.replacingOccurrences(
                of: "\\d",
                with: "0",
                options: .regularExpression
            )
            
            return placeholder
            
        } catch {
            return "0000000000"
        }
    }
    
    
    func maxLength() -> Int {
        do {
            let example = try phoneUtil.getExampleNumber(
                forType: regionCode,
                type: .MOBILE
            )
            return example.nationalNumber.stringValue.count
        } catch {
            return 15
        }
    }
    
    func isValid(digits: String) -> Bool {
        do {
            let num = try phoneUtil.parse(digits, defaultRegion: regionCode)
            return phoneUtil.isValidNumber(num)
        } catch {
            return false
        }
    }
}

//final class PhoneNumberFormatterService: ObservableObject {
//
//    private let phoneUtil = NBPhoneNumberUtil.sharedInstance()
//    private(set) var regionCode: String
//
//    private var formatter: NBAsYouTypeFormatter
//
//    init(regionCode: String) {
//        self.regionCode = regionCode
//        self.formatter = NBAsYouTypeFormatter(regionCode: regionCode)
//    }
//
//    func updateRegion(_ newRegion: String) {
//        regionCode = newRegion
//        formatter = NBAsYouTypeFormatter(regionCode: newRegion)
//    }
//
////    func format(digits: String) -> String {
////        formatter.clear()
////        var result = ""
////        for c in digits {
////            result = formatter.inputDigit(String(c))
////        }
////        return result
////    }
//
//    func format(digits: String) -> String {
//        formatter.clear()
//
//        let countryCode = countryCallingCode(for: regionCode)
//        let fullNumber = "+" + countryCode + digits
//
//        var result = ""
//        for c in fullNumber {
//            result = formatter.inputDigit(String(c))
//        }
//        return result
//    }
//
//    func countryCallingCode(for region: String) -> String {
//        phoneUtil.getCountryCode(forRegion: region).stringValue
//    }
//
//    func placeholder() -> String {
//        do {
//            let example = try phoneUtil.getExampleNumber(
//                forType: regionCode,
//                type: .MOBILE
//            )
//            let formatted = try phoneUtil.format(
//                example,
//                numberFormat: .NATIONAL
//            )
//
//            let noTrunk = formatted.trimmingCharacters(in: .whitespaces)
//                .replacingOccurrences(of: "^0", with: "", options: .regularExpression)
//
//            return noTrunk.replacingOccurrences(
//                of: "\\d",
//                with: "0",
//                options: .regularExpression
//            )
//        } catch {
//            return "0000000000"
//        }
//    }
//
//    func maxLength() -> Int {
//        do {
//            let example = try phoneUtil.getExampleNumber(
//                forType: regionCode,
//                type: .MOBILE
//            )
//            return example.nationalNumber.stringValue.count
//        } catch {
//            return 15
//        }
//    }
//
//    func isValid(digits: String) -> Bool {
//        do {
//            let num = try phoneUtil.parse(digits, defaultRegion: regionCode)
//            return phoneUtil.isValidNumber(num)
//        } catch {
//            return false
//        }
//    }
//}


import SwiftUI
import UIKit

struct PhoneNumberTextField: UIViewRepresentable {
    
    @Binding var digits: String
    @ObservedObject var formatterService: PhoneNumberFormatterService
    
    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.delegate = context.coordinator
        tf.font = UIFont(name: "Roboto-Regular", size: 14)
        tf.placeholder = formatterService.placeholder()
        // Done button only
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.doneTapped)
        )
        
        toolbar.items = [spacer, doneButton]
        tf.inputAccessoryView = toolbar
        return tf
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        let formatted = formatterService.format(digits: digits)
        
        if uiView.text != formatted {
            uiView.text = formatted
        }
        
        // 🔴 CRITICAL: placeholder must be updated here
        uiView.placeholder = formatterService.placeholder()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        
        let parent: PhoneNumberTextField
        
        init(_ parent: PhoneNumberTextField) {
            self.parent = parent
        }
        
        //        func textField(
        //            _ textField: UITextField,
        //            shouldChangeCharactersIn range: NSRange,
        //            replacementString string: String
        //        ) -> Bool {
        //
        //            let currentDigits = parent.digits
        //            let inputDigits = string.filter { $0.isNumber }
        //
        //            // Backspace
        //            if string.isEmpty {
        //                DispatchQueue.main.async {
        //                    self.parent.digits = String(currentDigits.dropLast())
        //                }
        //                return false
        //            }
        //
        //            let maxLength = parent.formatterService.maxLength()
        //            guard currentDigits.count < maxLength else {
        //                return false
        //            }
        //
        //            DispatchQueue.main.async {
        //                self.parent.digits.append(contentsOf: inputDigits)
        //            }
        //
        //            return false
        //        }
        
        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            
            let currentText = textField.text ?? ""
            
            // 1️⃣ Count digits before cursor (IMPORTANT)
            let digitsBeforeCursor = currentText
                .prefix(range.location)
                .filter { $0.isNumber }
                .count
            
            // 2️⃣ Apply UIKit range on formatted text
            guard let textRange = Range(range, in: currentText) else {
                return false
            }
            
            let updatedText = currentText.replacingCharacters(
                in: textRange,
                with: string
            )
            
            // 3️⃣ Extract digits only
            var newDigits = updatedText.filter { $0.isNumber }
            
            // 4️⃣ Enforce max length (UNCHANGED)
            let maxLength = parent.formatterService.maxLength()
            if newDigits.count > maxLength {
                newDigits = String(newDigits.prefix(maxLength))
            }
            
            // 5️⃣ Save digits
            parent.digits = newDigits
            
            // 6️⃣ Format
            let formatted = parent.formatterService.format(digits: newDigits)
            textField.text = formatted
            
            
            // 7️⃣ Restore cursor based on DIGIT COUNT
            var digitCount = 0
            var cursorPosition = formatted.count
            
            for (index, char) in formatted.enumerated() {
                if char.isNumber {
                    digitCount += 1
                }
                if digitCount >= digitsBeforeCursor + string.filter({ $0.isNumber }).count {
                    cursorPosition = index + 1
                    break
                }
            }
            
            if let position = textField.position(
                from: textField.beginningOfDocument,
                offset: cursorPosition
            ) {
                textField.selectedTextRange =
                textField.textRange(from: position, to: position)
            }
            
            return false
        }
        
        // Helper: map numeric index to formatted string index
        private func calculateCursorPosition(in formatted: String, digitOffset: Int) -> Int {
            var digitsPassed = 0
            for (i, c) in formatted.enumerated() {
                if c.isNumber {
                    digitsPassed += 1
                }
                if digitsPassed >= digitOffset {
                    return i + 1
                }
            }
            return formatted.count
        }
        
        
        @objc func doneTapped() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

struct PhoneInputView: View {
    
    @State private var selectedRegion = "IN"
    @State private var phoneDigits = ""
    
    @StateObject private var formatterService =
    PhoneNumberFormatterService(regionCode: "IN")
    
    var body: some View {
        VStack(spacing: 20) {
            
            Picker("Country", selection: $selectedRegion) {
                Text("India").tag("IN")
                Text("USA").tag("US")
                Text("UAE").tag("AE")
            }
            .onChange(of: selectedRegion) { newRegion in
                phoneDigits = ""
                formatterService.updateRegion(newRegion)
            }
            
            PhoneNumberTextField(
                digits: $phoneDigits,
                formatterService: formatterService
            )
            .frame(height: 50)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray))
            
            Button("Validate") {
                print(formatterService.isValid(digits: phoneDigits))
            }
        }
        .padding()
    }
}

