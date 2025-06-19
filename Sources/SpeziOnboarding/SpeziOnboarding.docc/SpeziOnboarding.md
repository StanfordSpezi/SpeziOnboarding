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
            An [`OnboardingConsentView`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/speziconsent/onboardingconsentview) can be used to allow your users to read and agree to a document as well as exporting it.
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



## Topics

### Articles

- <doc:DisplayingInformation>

### Structuring an Onboarding Flow

- ``OnboardingNavigationPath``
- ``OnboardingViewBuilder``

### Onboarding Views

- ``OnboardingView``
- ``SequentialOnboardingView``
- ``OnboardingActionsView``
- ``OnboardingInformationView``
- ``OnboardingTitleView``
