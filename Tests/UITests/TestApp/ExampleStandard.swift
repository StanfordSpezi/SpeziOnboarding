//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import Spezi


/// An example `Standard` used for the configuration.
actor ExampleStandard: Standard, EnvironmentAccessible {
    @MainActor var firstConsentDocument: PDFDocument?
    @MainActor var secondConsentDocument: PDFDocument?
}
