//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ConsentSignatureForm {
    /// Configuration for the user-visible labels in a ``ConsentSignatureForm``.
    public struct Labels: Sendable {
        let givenNameTitle: LocalizedStringResource
        let givenNamePlaceholder: LocalizedStringResource
        let familyNameTitle: LocalizedStringResource
        let familyNamePlaceholder: LocalizedStringResource
        
        /// Creates a new ``Labels`` config for the ``ConsentSignatureForm``.
        ///
        /// - parameters:
        ///   - givenNameTitle: The text to use for the given (first) name field. May be set to `nil` or omitted, in which case the library will use a sensible default value.
        ///   - givenNamePlaceholder: The text to use for the given name field placeholder. May be set to `nil` or omitted, in which case the library will use a sensible default value.
        ///   - familyNameTitle: The text to use for the family (last) name field. May be set to `nil` or omitted, in which case the library will use a sensible default value.
        ///   - familyNamePlaceholder: The text to use for the family name field placeholder. May be set to `nil` or omitted, in which case the library will use a sensible default value.
        public init(
            givenNameTitle: LocalizedStringResource? = nil,
            givenNamePlaceholder: LocalizedStringResource? = nil,
            familyNameTitle: LocalizedStringResource? = nil,
            familyNamePlaceholder: LocalizedStringResource? = nil
        ) {
            self.givenNameTitle = givenNameTitle ?? .init("NAME_FIELD_GIVEN_NAME_TITLE", bundle: .atURL(from: .module))
            self.givenNamePlaceholder = givenNamePlaceholder ?? .init("NAME_FIELD_GIVEN_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
            self.familyNameTitle = familyNameTitle ?? .init("NAME_FIELD_FAMILY_NAME_TITLE", bundle: .atURL(from: .module))
            self.familyNamePlaceholder = familyNamePlaceholder ?? .init("NAME_FIELD_FAMILY_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
        }
    }
}
