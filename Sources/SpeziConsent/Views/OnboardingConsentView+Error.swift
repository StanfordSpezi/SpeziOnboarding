//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension OnboardingConsentView {
    enum Error: LocalizedError {
        case consentExportError


        var errorDescription: String? {
            switch self {
            case .consentExportError:
                String(localized: LocalizedStringResource("Consent document could not be exported.", bundle: .atURL(from: .module)))
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .consentExportError:
                String(localized: LocalizedStringResource("Please try exporting the consent document again.", bundle: .atURL(from: .module)))
            }
        }

        var failureReason: String? {
            switch self {
            case .consentExportError:
                String(localized: LocalizedStringResource("The PDF generation from the consent document failed. ", bundle: .atURL(from: .module)))
            }
        }
    }
}
