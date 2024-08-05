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

The following example demonstrates how the ``OnboardingConsentView`` shown above is constructed by providing a header, markdown content encoded as a [UTF8](https://www.swift.org/blog/utf8-string/) [`Data`](https://developer.apple.com/documentation/foundation/data) instance (which may be provided asynchronously), and an action that should be performed once the consent has been given.

```swift
OnboardingConsentView(
    markdown: {
        Data("This is a *markdown* **example**".utf8)
    },
    action: {
        // Action to perform once the user has given their consent
    },
    identifier: "MyFirstConsentForm", // Specify an optional unique identifier for the consent form, helpful for distinguishing consent forms when storing.
    exportConfiguration: .init(paperSize: .usLetter)   // Configure the properties of the exported consent form
)
```

### Using multiple consent forms

If you want to show multiple consent documents to the user, that need to be signed separately, you can add multiple instances of ``OnboardingConsentView``.
In that case, it is important that you provide each instance with an unique ``ConsentDocumentIdentifier``, to distinguish the two consent documents when they are stored. Consider the example code below.

First, you should define an enum which holds a ``ConsentDocumentIdentifier`` for each of the two (or more) documents. We recommend using an enum to hold the
identifier strings to avoid having to write them explicitly throughout your App (e.g., in the ``OnboardingConsentView`` and the ``Standard``).

```swift
enum ConsentDocumentIdentifier {
    static let first = ConsentDocumentIdentifier("firstConsentDocument")
    static let second = ConsentDocumentIdentifier("secondConsentDocument")
}
```

Next, you can use the identifier to instantiate two consent views with separate documents.
Note, that you will also have to set the "onboardingIdentifier", so that Spezi can distinguish the views. You can reuse your ConsentDocumentIdentifier for the onboardingIdentifier by retrieving a String representation of the identifier using the "id" property.

```swift
OnboardingConsentView(
    markdown: {
        Data("This is a *markdown* **example**".utf8)
    },
    action: {
        // Action to perform once the user has given their consent
    },
    identifier: ConsentDocumentIdentifier.first, // Specify an optional unique identifier for the consent form, helpful for distinguishing consent forms when storing.
    exportConfiguration: .init(paperSize: .usLetter)   // Configure the properties of the exported consent form
)
    .onboardingIdentifier(ConsentDocumentIdentifier.first.id) // Set an identifier (String) for the view, to distinguish it from other views of the same type.

OnboardingConsentView(
    markdown: {
        Data("This is a *markdown* **example**".utf8)
    },
    action: {
        // Action to perform once the user has given their consent
    },
    identifier: ConsentDocumentIdentifier.second, // Specify an optional unique identifier for the consent form, helpful for distinguishing consent forms when storing.
    exportConfiguration: .init(paperSize: .usLetter)   // Configure the properties of the exported consent form
)
    .onboardingIdentifier(ConsentDocumentIdentifier.second.id) // Set an identifier for the view, to distinguish it from other views of the same type.
```

## Topics

### Views

- ``OnboardingConsentView``
