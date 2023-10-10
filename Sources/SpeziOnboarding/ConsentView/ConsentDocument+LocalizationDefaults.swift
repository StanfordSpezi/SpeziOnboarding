//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziViews


extension ConsentDocument {
    /// Provides default localization values for necessary fields in the ``ConsentDocument``.
    public enum LocalizationDefaults {
        /// Default localized value for the given name field of the consent form in the ``ConsentDocument``.
        public static var givenName: FieldLocalizationResource {
            FieldLocalizationResource(
                title: LocalizedStringResource("NAME_FIELD_GIVEN_NAME_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("NAME_FIELD_GIVEN_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
            )
        }
        
        /// Default localized value for the family name field of the consent form in the ``ConsentDocument``.
        public static var familyName: FieldLocalizationResource {
            FieldLocalizationResource(
                title: LocalizedStringResource("NAME_FIELD_FAMILY_NAME_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("NAME_FIELD_FAMILY_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
            )
        }
        
        /// Default localized value for the title of the exported consent form.
        public static var exportedConsentFormTitle: LocalizedStringResource {
            LocalizedStringResource("CONSENT_TITLE", bundle: .atURL(from: .module))
        }
    }
}
