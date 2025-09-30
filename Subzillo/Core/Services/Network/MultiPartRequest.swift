//
//  MultiPartRequest.swift
//  RajaKiRani
//
//  Created by KS-MACIMINI-016 on 13/03/25.
//

import Foundation

public struct MultipartInput<T> {
    let parameters: T
    let fileInput: [MultiPartFileInput]
    public init(parameters: T, fileInput: [MultiPartFileInput]) {
        self.parameters = parameters
        self.fileInput = fileInput
    }
}

public struct MultiPartFileInput: Codable {
    let fieldName: String
    let fileName: String
    let mimeType: String
    let fileData: Data
    public init(fieldName: String, fileName: String, mimeType: String, fileData: Data) {
        self.fieldName = fieldName
        self.fileName = fileName
        self.mimeType = mimeType
        self.fileData = fileData
    }
}
