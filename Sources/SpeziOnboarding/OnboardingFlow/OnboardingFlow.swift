//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public struct OnboardingFlow: View {
    @StateObject var onboardingViewController: OnboardingViewController

    public var body: some View {
        onboardingViewController.currentView
            .environmentObject(onboardingViewController)
    }
    
    public init(onboardingFlowComplete: Binding<Bool>, @OnboardingViewBuilder _ content: @escaping () -> OnboardingFlowViewCollection) {
        
        // Hacky
        /*
        let semaphore = DispatchSemaphore(value: 0)
        let box = Box<OnboardingFlowViewCollection>()
        Task {
            let result = await content()
            box.result = .success(result)
            semaphore.signal()
        }
        semaphore.wait()
         */

        
        let onboardingFlowViewCollection = content()
        //let onboardingFlowViewCollection = try! box.result!.get()
        
        self._onboardingViewController = StateObject(
            wrappedValue: OnboardingViewController(
                views: onboardingFlowViewCollection.views,
                complete: onboardingFlowComplete
            )
        )
    }
}

private final class Box<T> {
    var result: Result<T, Error>?
}
