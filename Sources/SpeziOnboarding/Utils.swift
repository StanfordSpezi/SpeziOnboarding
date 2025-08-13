//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


enum _CompatGlassEffect { // swiftlint:disable:this type_name
    case regular
}

extension View {
    @ViewBuilder
    func applyGlassEffect(_ effect: _CompatGlassEffect, interactive: Bool) -> some View {
        #if swift(>=6.2) && !os(visionOS)
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, *) {
            let glass: Glass = switch effect {
            case .regular: .regular
            }
            self.glassEffect(glass.interactive(interactive))
        } else {
            self
        }
        #else
        self
        #endif
    }
}


extension ProcessInfo {
    static let isIOS26 = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
}
