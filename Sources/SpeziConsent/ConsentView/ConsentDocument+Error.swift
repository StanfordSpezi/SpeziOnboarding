//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ConsentDocument {
    /// Represents possible errors occurring within the ``ConsentDocument`` during the export of the signed consent form.
    public enum Error: LocalizedError {
        case memoryAllocationError

        
        public var errorDescription: String? {
            LocalizedStringResource("CONSENT_EXPORT_ERROR_DESCRIPTION", bundle: .atURL(from: .module)).localizedString()
        }
        
        public var recoverySuggestion: String? {
            LocalizedStringResource("CONSENT_EXPORT_ERROR_RECOVERY_SUGGESTION", bundle: .atURL(from: .module)).localizedString()
        }

        public var failureReason: String? {
            LocalizedStringResource("CONSENT_EXPORT_ERROR_FAILURE_REASON", bundle: .atURL(from: .module)).localizedString()
        }
    }
}
