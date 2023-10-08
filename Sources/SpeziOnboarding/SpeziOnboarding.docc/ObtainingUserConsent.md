# Obtaining User Consent

<!--
                  
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

Present your user a consent document to read and sign.

### Obtaining User Consent

The ``ConsentView`` can allow users to read and agree to a document, e.g., a consent document for a research study or a terms and conditions document for an app. The document can be signed using a family and given name and a hand-drawn signature. 

![ConsentView](ConsentView.png)

The following example demonstrates how the ``ConsentView`` shown above is constructed by providing a header, markdown content encoded as a [UTF8](https://www.swift.org/blog/utf8-string/) [`Data`](https://developer.apple.com/documentation/foundation/data) instance (which may be provided asynchronously), and an action that should be performed once the consent has been given.

```swift
ConsentView(
    header: {
        OnboardingTitleView(title: "Consent", subtitle: "Version 1.0")
    },
    asyncMarkdown: {
        Data("This is a *markdown* **example**".utf8)
    },
    action: {
        // Action to perform once the user has given their consent
    }
)
```


## Topics

### Views

- ``ConsentView``
