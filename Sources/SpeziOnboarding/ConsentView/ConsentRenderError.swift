//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


public enum ConsentRenderError: LocalizedError {
    case memoryAllocationError

    public var errorDescription: String? {
        "Failed to render the consent form."
    }
    
    public var recoverySuggestion: String? {
        "Please try again or restart the application."
    }

    public var failureReason: String? {
        "The system wasn't able to reserve the necessary memory for rendering the consent form."
    }
}
