# ``SpeziOnboarding``

<!--
                  
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

Provides SwiftUI views for onboarding users onto a digital health application.

## Overview

The `SpeziOnboarding` module provides views that can be used for performing onboarding tasks, such as providing an overview of your app and asking a user to read and sign a consent document.

@Row {
    @Column {
        @Image(source: "OnboardingView", alt: "Screenshot displaying the onboarding view.") {
            An ``OnboardingView`` allows you to separate information into areas on a screen, each with a title, description, and icon.
        }
    }
    @Column {
        @Image(source: "SequentialOnboardingView", alt: "Screenshot displaying the sequential onboarding view.") {
            A ``SequentialOnboardingView`` allows you to display information step-by-step with each additional area appearing when the user taps the "Continue" button.
        }
    }
    @Column {
        @Image(source: "ConsentView", alt: "Screenshot displaying the consent view.") {
            A ``OnboardingConsentView`` can be used to allow your users to read and agree to a document as well as exporting it.
        }
    }
}


## Setup

### Add Spezi Onboarding as a Dependency

You need to add the Spezi Onboarding Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).


## Examples

### Onboarding View

The ``OnboardingView`` allows you to separate information into areas on a screen, each with a title, description, and icon.

```swift
import SpeziOnboarding
import SwiftUI


struct OnboardingViewExample: View {
    var body: some View {
        OnboardingView(
            title: "Welcome",
            subtitle: "This is an example onboarding view",
            areas: [
                .init(
                    icon: Image(systemName: "tortoise.fill"), 
                    title: "Tortoise", 
                    description: "A Tortoise!"
                ),
                .init(
                    icon: {
                        Image(systemName: "lizard.fill")
                            .foregroundColor(.green)
                    },
                    title: "Lizard", 
                    description: "A Lizard!"
                ),
                .init(
                    icon: {
                        Circle().fill(.orange)
                    }, 
                    title: "Circle", 
                    description: "A Circle!"
                )
            ],
            actionText: "Learn More",
            action: {
                // Action to perform when the user taps the action button.
            }
        )
    }
}
```


### Sequential Onboarding View

The ``SequentialOnboardingView`` allows you to display information step-by-step, with each additional area appearing when the user taps the `Continue` button.

```swift
import SpeziOnboarding
import SwiftUI


struct SequentialOnboardingViewExample: View {
    var body: some View {
        SequentialOnboardingView(
            title: "Things to know",
            subtitle: "And you should pay close attention ...",
            content: [
                .init(
                    title: "A thing to know", 
                    description: "This is a first thing that you should know; read carefully!"
                ),
                .init(
                    title: "Second thing to know", 
                    description: "This is a second thing that you should know; read carefully!"
                ),
                .init(
                    title: "Third thing to know", 
                    description: "This is a third thing that you should know; read carefully!"
                )
            ],
            actionText: "Continue"
        ) {
            // Action to perform when the user has viewed all the steps
        }
    }
}
```


### Consent View

The ``OnboardingConsentView`` can allow users to read and agree to a document, e.g., a consent document for a research study or a terms and conditions document for an app. The document can be signed using a family and given name and a hand-drawn signature. The signed consent form can then be exported as a PDF document and shared.

The following example demonstrates how the ``OnboardingConsentView`` shown above is constructed by providing a header, markdown content encoded as a [UTF8](https://www.swift.org/blog/utf8-string/) [`Data`](https://developer.apple.com/documentation/foundation/data) instance (which may be provided asynchronously), and an action that should be performed once the consent has been given.

```swift
import SpeziOnboarding
import SwiftUI


struct ConsentViewExample: View {
    var body: some View {
        OnboardingConsentView(
            markdown: {
                Data("This is a *markdown* **example**".utf8)
            },
            action: {
                // Action to perform once the user has given their consent
            },
            exportConfiguration: .init(paperSize: .usLetter)   // Configure the properties of the exported consent form
        )
    }
}
```


## Topics

### Articles

- <doc:DisplayingInformation>
- <doc:ObtainingUserConsent>

### Structuring an Onboarding Flow

- ``OnboardingStack``
- ``OnboardingNavigationPath``
- ``OnboardingViewBuilder``

### Onboarding Views

- ``OnboardingActionsView``
- ``OnboardingInformationView``
- ``OnboardingTitleView``
- ``OnboardingConsentView``
- ``OnboardingView``
- ``SequentialOnboardingView``

### Consent Views

- ``ConsentDocument``
- ``ConsentViewState``
- ``SignatureView``

### Data Flow

- ``OnboardingDataSource``
- ``OnboardingConstraint``
