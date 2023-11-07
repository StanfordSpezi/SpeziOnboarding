//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ConsentDocument {
    /// Provides default localization values for necessary fields in the ``ConsentDocument``.
    public enum LocalizationDefaults {
        /// Default localized title for the given name field of the consent form in the ``ConsentDocument``.
        public static let givenNameTitle = LocalizedStringResource("NAME_FIELD_GIVEN_NAME_TITLE", bundle: .atURL(from: .module))
        /// Default localized placeholder for the given name field of the consent form in the ``ConsentDocument``.
        public static let givenNamePlaceholder = LocalizedStringResource("NAME_FIELD_GIVEN_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
        
        
        /// Default localized title for the family name field of the consent form in the ``ConsentDocument``.
        public static let familyNameTitle = LocalizedStringResource("NAME_FIELD_FAMILY_NAME_TITLE", bundle: .atURL(from: .module))
        /// Default localized placeholder for the family name field of the consent form in the ``ConsentDocument``.
        public static let familyNamePlaceholder = LocalizedStringResource("NAME_FIELD_FAMILY_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
        
        /// Default localized value for the title of the exported consent form.
        public static let exportedConsentFormTitle = LocalizedStringResource("CONSENT_TITLE", bundle: .atURL(from: .module))
    }
}
