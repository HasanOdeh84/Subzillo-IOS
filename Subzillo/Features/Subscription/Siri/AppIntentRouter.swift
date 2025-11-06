//
//  AppIntentRouter.swift
//  SwiftUI_project_setup
//
//  Created by KSMACMINI-019 on 11/09/25.
//

import SwiftUI
import Combine

final class AppIntentRouter: ObservableObject {
    static let shared = AppIntentRouter()
    private init() {}

    @Published var navigatingRoute: NavigationRoute? = nil
}

extension AppIntentRouter {
    func navigate(to route: NavigationRoute) {
        navigatingRoute = route
    }
}
