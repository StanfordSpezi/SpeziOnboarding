//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order line_length

import SpeziOnboarding
import SpeziViews
import SwiftUI


struct ScreenshotsFlow: View {
    var body: some View {
        ManagedNavigationStack {
            Welcome()
            InterestingModules()
            HealthKitPermissions()
        }
    }
}


private struct Welcome: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    var body: some View {
        OnboardingView(
            title: "Spezi Template Application",
            subtitle: "This application demonstrates several Spezi features & modules",
            areas: [
                .init(
                    iconSymbol: "apps.iphone",
                    title: "The Spezi Framework",
                    description: "The Spezi Framework builds the foundation of this template application."
                ),
                .init(
                    iconSymbol: "shippingbox",
                    title: "Swift Package Manager",
                    description: "Spezi is imported into applications using the Swift Package Manager."
                ),
                .init(
                    iconSymbol: "square.3.layers.3d",
                    title: "Spezi Modules",
                    description: "Spezi offers several modules including HealthKit integration, questionnaires, account management, and more."
                ),
                .init(
                    iconSymbol: "shuffle",
                    title: "HL7 FHIR Integration",
                    description: "Many of Spezi's modules offer native support for FHIR-based data sharing with existing systems and workflows."
                )
            ],
            actionText: "Learn More"
        ) {
            path.nextStep()
        }
    }
}


private struct InterestingModules: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    var body: some View {
        SequentialOnboardingView(
            title: "Interesting Modules",
            subtitle: "Here are a few key Spezi modules and features",
            steps: [
                .init(title: "Onboarding", description: "The Onboarding module allows you to build an onboarding flow like this one."),
                .init(title: "Account", description: "SpeziAccount enabled user log in and sign up, using Firebase and other services."),
                .init(title: "HealthKit", description: "Work with Health data collected by the user's iPhone and Watch."),
                .init(title: "Scheduler", description: "Via Spezi's Scheduler module, users can be prompted to complete tasks based on schedules.")
            ],
            actionText: "Continue"
        ) {
            path.nextStep()
        }
    }
}


private struct HealthKitPermissions: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    var body: some View {
        OnboardingView {
            OnboardingTitleView(title: "Health Access", subtitle: "")
        } content: {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 150))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
                .padding(.bottom, 40)
            VStack(alignment: .leading) {
                Text(
                    """
                    Grant read-only permission to access your Health data, in order to view Health summaries and stats in the app, and to perform background processing of your Health data.
                    
                    You can revoke this at any time.
                    """
                )
            }
        } footer: {
            OnboardingActionsView(
                primaryText: "Grant Access",
                primaryAction: {
                    path.nextStep()
                },
                secondaryText: "Later",
                secondaryAction: {
                    path.nextStep()
                }
            )
        }
    }
}
