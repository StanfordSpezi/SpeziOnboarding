//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI
import SpeziViews


public struct ConsentViewCapture<ContentView: View, Action: View>: View {
    let size: ConsentView<ContentView, Action>.PaperSize
    let wrappedView: ConsentView<ContentView, Action>
    
    
    public var body: some View {
        wrappedView
    }
    
    
    public init(
        size: ConsentView<ContentView, Action>.PaperSize = .usLetter,
        buildView: (() -> ConsentView<ContentView, Action>)
    ) where ContentView == AnyView, Action == OnboardingActionsView {
        self.size = size
        
        self.wrappedView = buildView()
    }
    
    
    public func render() async {
        await wrappedView.export()
    }
}
