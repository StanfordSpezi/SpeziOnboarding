//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


extension Binding where Value == ConsentViewState {
    /// Access to a `Binding` of the ``ConsentViewState/base(_:)``
    var base: Binding<SpeziViews.ViewState> {
        .init(
            get: {
                if case let .base(value) = self.wrappedValue {
                    return value
                }
                return .idle    // Default case
            },
            set: {
                if case .base = self.wrappedValue {
                    self.wrappedValue = .base($0)
                }
            }
        )
    }
    
    /// Access to a `Binding` of the ``ConsentViewState/signing``
    var signing: Binding<Bool> {
        .init(
            get: {
                if case .signing = self.wrappedValue {
                    return true
                }
                return false
            },
            set: {
                self.wrappedValue = $0 ? .signing : .signed
            }
        )
    }
}
