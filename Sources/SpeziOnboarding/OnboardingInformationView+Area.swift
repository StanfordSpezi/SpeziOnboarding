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
    /// A block of content within an `OnboardingInformationView`
    ///
    /// ## Topics
    /// ### Initializers
    /// - ``init(iconSymbol:title:description:)-(_,LocalizedStringResource,_)``
    /// - ``init(iconSymbol:title:description:)-(_,StringProtocol,_)``
    /// - ``init(icon:title:description:)-(_,LocalizedStringResource,_)``
    /// - ``init(icon:title:description:)-(_,StringProtocol,_)``
    /// - ``init(icon:title:description:)-(_,()->Text,_)``
    public struct Area {
        let icon: AnyView
        let title: Text
        let description: Text
        
        /// Creates a new area, using custom icon, title, and description views.
        ///
        /// - parameter icon: The area's icon, displayed at its left edge.
        /// - parameter title: The area's title, displayed to the right of the `icon`.
        /// - parameter description: The area's description, displayed below its `title`.
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
    /// Creates a new area, using a custom icon view and localized string contents.
    ///
    /// - parameter icon: The area's icon, displayed at its left edge.
    /// - parameter title: The area's localized title, displayed to the right of the `icon`.
    /// - parameter description: The area's localized description, displayed below its `title`.
    public init(@ViewBuilder icon: () -> some View, title: LocalizedStringResource, description: LocalizedStringResource) {
        self.init {
            icon()
        } title: {
            Text(title)
        } description: {
            Text(description)
        }
    }
    
    /// Creates a new area, using a custom icon view and non-localized string contents.
    ///
    /// - parameter icon: The area's icon, displayed at its left edge.
    /// - parameter title: The area's localized title, displayed to the right of the `icon`.
    /// - parameter description: The area's localized description, displayed below its `title`.
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
    
    /// Creates a new area, using a system symbol icon and localized string contents.
    ///
    /// - parameter iconSymbol: SF Symbol name to be used as the area's icon.
    /// - parameter title: The area's localized title, displayed to the right of the `icon`.
    /// - parameter description: The area's localized description, displayed below its `title`.
    public init(iconSymbol: String, title: LocalizedStringResource, description: LocalizedStringResource) {
        self.init(icon: { Image(systemName: iconSymbol) }, title: title, description: description)
    }
    
    /// Creates a new area, using a system symbol icon and non-localized string contents.
    ///
    /// - parameter iconSymbol: SF Symbol name to be used as the area's icon.
    /// - parameter title: The area's title, displayed to the right of the `icon`.
    /// - parameter description: The area's description, displayed below its `title`.
    @_disfavoredOverload
    public init(iconSymbol: String, title: some StringProtocol, description: some StringProtocol) {
        self.init(icon: { Image(systemName: iconSymbol) }, title: title, description: description)
    }
}
