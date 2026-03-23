//
//  BottomSheetManager.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 28/11/25.
//

import Foundation
import Combine

final class SheetManager: ObservableObject {
    static let shared = SheetManager()
    
    @Published var isOfflineSheetVisible = false
    @Published var isUpgradeSheetVisible = false
    @Published var isFamilyMemberLimitSheetVisible = false
        
    private init() {}
}
