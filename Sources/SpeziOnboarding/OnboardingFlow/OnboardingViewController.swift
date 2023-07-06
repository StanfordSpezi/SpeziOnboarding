//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public class OnboardingViewController: ObservableObject {
    var views: [AnyView]
    var complete: Binding<Bool>
    
    @Published var currentView: AnyView
    
    init(views: [any View], complete: Binding<Bool>) {
        self.views = views.map { AnyView($0) }  // Convert to `AnyView` (TODO?)
        self.complete = complete
        self.currentView = self.views.popLast() ?? .init(EmptyView())
    }
    
    public func nextStep() {
        if views.isEmpty {
            complete.wrappedValue = true
            /*
            Task { @MainActor in
                self.objectWillChange.send() // Is that needed? I guess the Binding doesnt update the view properly otherwise
            }
             */
            return
        }
        
        // Move forward on the main thread
        Task { @MainActor in
            self.currentView = views.popLast() ?? .init(EmptyView())
        }
    }
}
