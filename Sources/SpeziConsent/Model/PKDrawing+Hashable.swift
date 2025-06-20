//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PencilKit


extension PKDrawing: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dataRepresentation())
    }
}
