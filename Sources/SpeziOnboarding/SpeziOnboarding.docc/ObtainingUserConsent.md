# Obtaining User Consent

<!--
                  
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

Present your user a consent document to read and sign.

### Obtaining User Consent

The ``OnboardingConsentView`` can allow users to read and agree to a document, e.g., a consent document for a research study or a terms and conditions document for an app. The document can be signed using a family and given name and a hand-drawn signature. 

@Image(source: "ConsentView.png")

The following example demonstrates how the ``OnboardingConsentView`` shown above is constructed by providing a header, markdown content encoded as a [UTF8](https://www.swift.org/blog/utf8-string/) [`Data`](https://developer.apple.com/documentation/foundation/data) instance (which may be provided asynchronously), an action that should be performed once the consent has been given (which receives the exported consent form as a PDF), as well as a configuration defining the properties of the exported consent form.

```swift
OnboardingConsentView(
    markdown: {
        Data("This is a *markdown* **example**".utf8)
    },
    action: { exportedConsentPdf in
        // Action to perform once the user has given their consent.
        // Closure receives the exported consent PDF to persist or upload it.
    },
    title: "Consent",   // Configure the title of the consent view
    exportConfiguration: .init(paperSize: .usLetter),   // Configure the properties of the exported consent form.
    currentDateInSignature: true   // Indicates if the consent signature should include the current date.
)
```

### Using multiple consent forms

If you want to show multiple consent documents to the user, that need to be signed separately, you can add multiple instances of ``OnboardingConsentView``.
If used within a [`ManagedNavigationStack`](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/main/documentation/speziviews/managednavigationstack), it might be necessary to specify a unique `View/navigationStepIdentifier(_:)` for each ``OnboardingConsentView`` (you can omit the explicit identifiers if you don't perform any manual navigation other than simply advancing the stack to the next step).


```swift
ManagedNavigationStack {
    OnboardingConsentView(
        markdown: { Data("This is a *markdown* **example**".utf8) },
        action: { firstConsentPdf in
            // Store or share the first signed consent form.
            // Use the `OnboardingNavigationPath` from the SwiftUI `@Environment` to navigate to the next `OnboardingConsentView`.
        }
    )
        .navigationStepIdentifier("firstConsentView") // Set an identifier (String) for the `View`, to distinguish it from other `View`s of the same type.

    OnboardingConsentView(
        markdown: { Data("This is a *markdown* **example**".utf8) },
        action: { secondConsentPdf in
            // Store or share the second signed consent form.
        }
    )
        .navigationStepIdentifier("secondConsentView"), // Set an identifier for the `View`, to distinguish it from other `View`s of the same type.
}
```

## Topics

### Views

- ``OnboardingConsentView``
- ``ConsentDocument``
- ``SignatureView``

### Export

- ``ConsentViewState``
- ``ConsentDocumentExportRepresentation``
