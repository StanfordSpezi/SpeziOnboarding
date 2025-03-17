//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


extension ConsentDocumentExportRepresentation.Configuration {
    /// Provides default values for fields related to the ``ConsentDocumentExportRepresentation/Configuration``.
    public enum Defaults {
        /// Default localized value for the title of the exported consent form.
        public static let exportedConsentFormTitle = LocalizedStringResource("CONSENT_TITLE", bundle: .atURL(from: .module))
    }
}
