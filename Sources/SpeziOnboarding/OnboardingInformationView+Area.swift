//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziViews
import SwiftUI


extension OnboardingInformationView {
    /// An ``Area`` defines the way that information is displayed in an ``OnboardingInformationView``.
    ///
    /// ## Topics
    ///
    /// ### Initializers
    public struct Area {
        /// The icon of the area in the ``OnboardingInformationView``.
        let icon: AnyView
        /// The title of the area in the ``OnboardingInformationView``.
        let title: Text
        /// The description of the area in the ``OnboardingInformationView``.
        let description: Text
        
        /// Creates a new ``Area``
        public init(
            @ViewBuilder icon: () -> some View,
            @ViewBuilder title: () -> Text,
            @ViewBuilder description: () -> Text
        ) {
            self.icon = AnyView(icon())
            self.title = title()
            self.description = description()
        }
    }
}


extension OnboardingInformationView.Area {
    /// Creates a new content for an area in the ``OnboardingInformationView``.
    /// - Parameters:
    ///   - icon: The icon of the area in the ``OnboardingInformationView``.
    ///   - title: The title of the area in the ``OnboardingInformationView`` without localization.
    ///   - description: The description of the area in the ``OnboardingInformationView`` without localization.
    @_disfavoredOverload
    public init(@ViewBuilder icon: () -> some View, title: some StringProtocol, description: some StringProtocol) {
        self.init {
            icon()
        } title: {
            Text(title)
        } description: {
            Text(description)
        }
    }
    
    /// Creates a new content for an area in the ``OnboardingInformationView``.
    /// - Parameters:
    ///   - icon: The icon of the area in the ``OnboardingInformationView``.
    ///   - title: The localized title of the area in the ``OnboardingInformationView``.
    ///   - description: The localized description of the area in the ``OnboardingInformationView``.
    public init(@ViewBuilder icon: () -> some View, title: LocalizedStringResource, description: LocalizedStringResource) {
        self.init {
            icon()
        } title: {
            Text(title)
        } description: {
            Text(description)
        }
    }
    
    /// Creates a new content for an area in the ``OnboardingInformationView``.
    /// - Parameters:
    ///   - systemSymbol: SF Symbol name to be used as the area's icon.
    ///   - title: The title of the area in the ``OnboardingInformationView`` without localization.
    ///   - description: The description of the area in the ``OnboardingInformationView`` without localization.
    @_disfavoredOverload
    public init(systemSymbol: String, title: some StringProtocol, description: some StringProtocol) {
        self.init(icon: { Image(systemName: systemSymbol) }, title: title, description: description)
    }
    
    /// Creates a new content for an area in the ``OnboardingInformationView``.
    /// - Parameters:
    ///   - systemSymbol: SF Symbol name to be used as the area's icon.
    ///   - title: The localized title of the area in the ``OnboardingInformationView``.
    ///   - description: The localized description of the area in the ``OnboardingInformationView``.
    public init(systemSymbol: String, title: LocalizedStringResource, description: LocalizedStringResource) {
        self.init(icon: { Image(systemName: systemSymbol) }, title: title, description: description)
    }
}
