<!--

This source file is part of the Stanford Spezi open-source project.

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
  
-->

# Spezi Onboarding

[![Build and Test](https://github.com/StanfordSpezi/SpeziOnboarding/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordSpezi/SpeziOnboarding/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordSpezi/SpeziOnboarding/branch/main/graph/badge.svg?token=lsRIXi5IXY)](https://codecov.io/gh/StanfordSpezi/SpeziOnboarding)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7806970.svg)](https://doi.org/10.5281/zenodo.7806970)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziOnboarding%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StanfordSpezi/SpeziOnboarding)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziOnboarding%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/StanfordSpezi/SpeziOnboarding)

Provides UI components for Onboarding and Consent.


## Overview

The SpeziOnboarding module provides user interface components to onboard a user to an application, including the possibility of retrieving consent for study participation.

|![Screenshot displaying the onboarding view.](Sources/SpeziOnboarding/SpeziOnboarding.docc/Resources/OnboardingView.png#gh-light-mode-only) ![Screenshot displaying the onboarding view.](Sources/SpeziOnboarding/SpeziOnboarding.docc/Resources/OnboardingView~dark.png#gh-dark-mode-only)|![Screenshot displaying the sequential onboarding view.](Sources/SpeziOnboarding/SpeziOnboarding.docc/Resources/SequentialOnboardingView.png#gh-light-mode-only) ![Screenshot displaying the sequential onboarding view.](Sources/SpeziOnboarding/SpeziOnboarding.docc/Resources/SequentialOnboardingView~dark.png#gh-dark-mode-only)|![Screenshot displaying the consent view.](Sources/SpeziOnboarding/SpeziOnboarding.docc/Resources/ConsentView.png#gh-light-mode-only) ![Screenshot displaying the consent view.](Sources/SpeziOnboarding/SpeziOnboarding.docc/Resources/ConsentView~dark.png#gh-dark-mode-only)
|:--:|:--:|:--:|
|[`OnboardingView`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/spezionboarding/onboardingview)|[`SequentialOnboardingView`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/spezionboarding/sequentialonboardingview)|[`OnboardingConsentView`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/speziconsent/onboardingconsentview)|


## Setup

### Add Spezi Onboarding as a Dependency

You need to add the Spezi Onboarding Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).


## Examples

### Onboarding View

The [`OnboardingView`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/spezionboarding/onboardingview) allows you to separate information into areas on a screen, each with a title, description, and icon.

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

The [`SequentialOnboardingView`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/spezionboarding/sequentialonboardingview) allows you to display information step-by-step with each additional area appearing when the user taps the `Continue` button.

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


### Onboarding Consent View

The [`OnboardingConsentView`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/speziconsent/onboardingconsentview) can be used to allow your users to read and agree to a document, e.g., a consent document for a research study or a terms and conditions document for an app. The document can be signed using a family and given name and a hand-drawn signature. The signed consent form can then be exported and shared as a PDF file.

The following example demonstrates how the [`OnboardingConsentView`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/speziconsent/onboardingconsentview) shown above is constructed by reading a consent form from a markdown file, creating a [`ConsentDocument`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/speziconsent/consentdocument) and passing it to the `OnboardingConsentView`, and  an action that should be performed once the consent has been given (which receives the exported consent form as a PDF), as well as a configuration defining the properties of the exported consent form.

The following example demonstrates using the  [`OnboardingConsentView`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/speziconsent/onboardingconsentview) to present a consent form to the user as part of an onboarding flow.
Once the consent if completed (i.e., the user signed it and filled out all required form elements), the user can continue to the next onboarding step.
The view also uses the [`ConsentShareButton`](https://swiftpackageindex.com/stanfordspezi/spezionboarding/documentation/speziconsent/consentsharebutton) to allow the user to obtain a PDF-exported copy of their signed consent document. 

```swift
import SpeziConsent
import SwiftUI

struct Consent: View {
    let url: URL
    
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    @State private var consentDocument: ConsentDocument?
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        OnboardingConsentView(consentDocument: consentDocument) {
            // advance your Onboarding flow in response to the user having confirmed a completed consent document 
            path.nextStep()
        }
        .viewStateAlert(state: $viewState)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // give your user the ability to obtain a PDF version of the consent document they just signed 
                ConsentShareButton(
                    consentDocument: consentDocument,
                    viewState: $viewState
                )
            }
        }
        .task {
            do {
                consentDocument = try ConsentDocument(contentsOf: url)
            } catch {
                viewState = .error(AnyLocalizedError(error: error))
            }
        }
    }
}
```

For more information, please refer to the [API documentation](https://swiftpackageindex.com/StanfordSpezi/SpeziOnboarding/documentation).


## The Spezi Template Application

The [Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication) provides a great starting point and example using the `SpeziOnboarding` module.



## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziOnboarding/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
