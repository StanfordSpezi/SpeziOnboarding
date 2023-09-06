//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// The ``OnboardingActionsView`` allows developers to present a unified style for action buttons in an onboarding flow.
/// The ``OnboardingActionsView`` can contain one primary button and a optional secondary button below the primary button.
///
/// ```swift
/// OnboardingActionsView(
///     primaryText: "Primary Text",
///     primaryAction: {
///         // ...
///     },
///     secondaryText: "Secondary Text",
///     secondaryAction: {
///         // ...
///     }
/// )
/// ```
public struct OnboardingActionsView: View {
    public enum Orientation {
        case vertical
        case horizontal(proportions: Double)
    }
    
    
    private let primaryView: any View
    private let _primaryAction: () async -> Void
    private let secondaryView: (any View)?
    private let _secondaryAction: (() async -> Void)?
    private let orientation: Orientation
    
    @State private var primaryActionLoading = false
    @State private var secondaryActionLoading = false
    
    
    public var body: some View {
        switch orientation {
        case .vertical:
            verticalBody
        case .horizontal(let proportions):
            horizontalBody(proportions: proportions)
        }
    }
    
    var verticalBody: some View {
        VStack {
            Button(action: primaryAction) {
                Group {
                    if primaryActionLoading {
                        ProgressView()
                    } else {
                        AnyView(primaryView)
                    }
                }
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
            
            if let secondaryView, _secondaryAction != nil {
                Button(action: secondaryAction) {
                    Group {
                        if secondaryActionLoading {
                            ProgressView()
                        } else {
                            AnyView(secondaryView)
                        }
                    }
                }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 10)
            }
        }
            .disabled(primaryActionLoading || secondaryActionLoading)
    }
    
    @ViewBuilder
    func horizontalBody(proportions: Double) -> some View {
        VStack {
            /*
            Spacer()
                .frame(maxWidth: .infinity)
             */
            
            GeometryReader { geometry in
                HStack {
                    Button(action: primaryAction) {
                        Group {
                            if primaryActionLoading {
                                ProgressView()
                            } else {
                                AnyView(primaryView)
                            }
                        }
                            .frame(maxWidth: geometry.size.width * proportions, minHeight: 38)
                    }
                    
                    if let secondaryView, _secondaryAction != nil {
                        Button(action: secondaryAction) {
                            Group {
                                if secondaryActionLoading {
                                    ProgressView()
                                } else {
                                    AnyView(secondaryView)
                                }
                            }
                                .frame(maxWidth: geometry.size.width * (1 - proportions), minHeight: 38)
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(primaryActionLoading || secondaryActionLoading)
        }
    }
    
    /// Creates an ``OnboardingActionsView`` instance that only contains a primary button.
    /// - Parameters:
    ///   - text: The title ot the primary button.
    ///   - action: The action that should be performed when pressing the primary button
    public init<Text: StringProtocol>(
        _ text: Text,
        action: @escaping () async -> Void
    ) {
        self.primaryView = SwiftUI.Text(text.localized)
        self._primaryAction = action
        self.secondaryView = nil
        self._secondaryAction = nil
        self.orientation = .vertical
    }
    
    /// Creates an ``OnboardingActionsView`` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryText: The title ot the primary button.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The title ot the secondary button.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    public init<PrimaryText: StringProtocol, SecondaryText: StringProtocol>(
        primaryText: PrimaryText,
        primaryAction: @escaping () async -> Void,
        secondaryText: SecondaryText,
        secondaryAction: @escaping () async -> Void,
        orientation: Orientation = .vertical
    ) {
        self.primaryView = Text(primaryText.localized)
        self._primaryAction = primaryAction
        self.secondaryView = Text(secondaryText.localized)
        self._secondaryAction = secondaryAction
        self.orientation = orientation
    }
    
    /// Creates an ``OnboardingActionsView`` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryText: The title ot the primary button.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The title ot the secondary button.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    public init<PrimaryView: View, SecondaryView: View>(
        primaryView: PrimaryView,
        primaryAction: @escaping () async -> Void,
        secondaryView: SecondaryView,
        secondaryAction: @escaping () async -> Void,
        orientation: Orientation = .vertical
    ) {
        self.primaryView = primaryView
        self._primaryAction = primaryAction
        self.secondaryView = secondaryView
        self._secondaryAction = secondaryAction
        self.orientation = orientation
    }
    
    
    private func primaryAction() {
        Task {
            withAnimation(.easeOut(duration: 0.2)) {
                primaryActionLoading = true
            }
            await _primaryAction()
            withAnimation(.easeIn(duration: 0.2)) {
                primaryActionLoading = false
            }
        }
    }
    
    private func secondaryAction() {
        Task {
            withAnimation(.easeOut(duration: 0.2)) {
                secondaryActionLoading = true
            }
            await _secondaryAction?()
            withAnimation(.easeIn(duration: 0.2)) {
                secondaryActionLoading = false
            }
        }
    }
}


#if DEBUG
struct OnboardingActionsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OnboardingActionsView("PRIMARY") {
                print("Primary!")
            }
            OnboardingActionsView(
                primaryText: "PRIMARY",
                primaryAction: {
                    print("Primary")
                },
                secondaryText: "SECONDARY",
                secondaryAction: {
                    print("Secondary")
                }
            )
        }
    }
}
#endif
