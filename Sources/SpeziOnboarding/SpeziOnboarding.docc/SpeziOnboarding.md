# ``SpeziOnboarding``

<!--
                  
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

Provides SwiftUI views for onboarding users onto a digital health application.

## Overview

The ``SpeziOnboarding`` module provides views that can be used for performing onboarding tasks, such as providing an overview of your app and asking a user to read and sign a consent document.

@Row {
    @Column {
        @Image(source: "OnboardingView", alt: "Screenshot displaying the onboarding view.") {
            An ``OnboardingView`` allows you to separate information into areas on a screen, each with a title, description, and icon
        }
        @Image(source: "SequentialOnboardingView", alt: "Screenshot displaying the sequential onboarding view.") {
            A ``SequentialOnboardingView`` allows you to display information step-by-step with each additional area appearing when the user taps the `Continue` button.
        }
        @Image(source: "ConsentView", alt: "Screenshot displaying the consent view.") {
            A ``ConsentView`` can be used to allow your users to read and agree to a document.
        }
    }
}

## Topics

### Creating an Onboarding Flow

- <doc:DisplayingInformation>
- <doc:ObtainingUserConsent>

### Views

- ``ConsentView``
- ``OnboardingActionsView``
- ``OnboardingInformationView``
- ``OnboardingTitleView``
- ``OnboardingView``
- ``SequentialOnboardingView``
- ``SignatureView``
