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


@MainActor
public struct ConsentViewCapture<ContentView: View, Action: View>: View {
    let size: PaperSize
    var view: ConsentView<ContentView, Action>
    
    
    public var body: some View {
        view
    }
    
    
    public init(
        size: PaperSize = .usLetter,
        buildView: (() -> ConsentView<ContentView, Action>)
    ) where ContentView == AnyView, Action == OnboardingActionsView {
        self.size = size
        
        self.view = buildView()
    }
    
    
    public func render() async {
        await view.export()
    }
}


extension ConsentViewCapture {
    public enum PaperSize {
        case a4
        case usLetter

        var dimensions: (width: Double, height: Double) {
            switch self {
            case .a4:
                return (210.0, 297.0)
            case .usLetter:
                return (215.9, 279.4)
            }
        }
    }
}
