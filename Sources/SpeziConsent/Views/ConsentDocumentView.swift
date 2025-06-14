//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import MarkdownUI
import PencilKit
import SpeziPersonalInfo
import SpeziViews
import SwiftUI

/// Display markdown-based consent documents that can be filled out, signed, and exported.
///
/// Allows the display markdown-based consent documents that can be signed using a family and given name and a hand drawn signature.
/// In addition, it enables the export of the signed form as a PDF document.
///
/// Your app creates a ``ConsentDocument``, which acts as the model representing a markdown-based consent form.
/// This view displays the ``ConsentDocument``, and enables data entry into the document's interactive components, such as e.g. checkboxes, selection pickers, and signature fields.
///
/// To observe and control the current state of the ``ConsentDocument``, the `View` requires passing down a ``ConsentViewState`` as a SwiftUI `Binding` in the
/// ``init(markdown:viewState:givenNameTitle:givenNamePlaceholder:familyNameTitle:familyNamePlaceholder:exportConfiguration:consentSignatureDate:consentSignatureDateFormatter:)`` initializer.
///
/// This `Binding` can then be used to trigger the creation of the export representation of the consent form via setting the state to ``ConsentViewState/export``.
/// After the export representation completes, the ``ConsentDocumentExportRepresentation`` is accessible via the associated value of the view state in ``ConsentViewState/exported(representation:)``.
/// The ``ConsentDocumentExportRepresentation`` can then be rendered to a PDF via ``ConsentDocumentExportRepresentation/render()``.
///
/// Other possible states of the ``ConsentDocument`` are the SpeziViews `ViewState`'s accessible via the associated value in ``ConsentViewState/base(_:)``.
/// In addition, the view provides information about the signing progress via the ``ConsentViewState/signing`` and ``ConsentViewState/signed`` states.
///
/// ```swift
/// // Enables observing the view state of the consent document
/// @State var state: ConsentDocument.ConsentViewState = .base(.idle)
///
/// ConsentDocument(
///     markdown: {
///         Data("This is a *markdown* **example**".utf8)
///     },
///     viewState: $state,
///     exportConfiguration: .init(paperSize: .usLetter),   // Configure the properties of the exported consent form
///     consentSignatureDate: .now
/// )
/// ```
public struct ConsentDocumentView: View {
    @Bindable private var consentDocument: ConsentDocument
    private let signatureFieldLabels: ConsentSignatureForm.Labels
    private let signatureDate: Date?
    private let signatureDateFormat: Date.FormatStyle
    
    public var body: some View {
        let sections = consentDocument.sections
        VStack(spacing: 12) {
            ForEach(Array(sections.indices), id: \.self) { sectionIdx in
                let section = sections[sectionIdx]
                view(for: section)
                    .id(section.id)
                let nextIsSignature = sections[safe: sectionIdx + 1]?.isSignature ?? false
                if sectionIdx == sections.endIndex - 2, nextIsSignature {
                    // if the last section is a signature, we add a spacer.
                    // this means that, if the consent is short, we push the signature field down all the way to the bottom of the screen.
                    Spacer()
                }
                if sectionIdx < sections.endIndex - 1 && !nextIsSignature {
                    Divider()
                }
            }
        }
    }
    
    /// Creates a `ConsentDocumentView`, which renders a consent document with a markdown view.
    ///
    /// - parameters:
    ///   - signatureFieldLabels: Allows customizing which text should be used for labels in signature fields within this ``ConsentDocumentView``.
    public init(
        consentDocument: ConsentDocument,
        signatureFieldLabels: ConsentSignatureForm.Labels = .init(),
        consentSignatureDate: Date? = nil,
        consentSignatureDateFormat: Date.FormatStyle = .init(date: .numeric)
    ) {
        self.consentDocument = consentDocument
        consentDocument.signatureDate = consentSignatureDate?.formatted(consentSignatureDateFormat)
        self.signatureFieldLabels = signatureFieldLabels
        self.signatureDate = consentSignatureDate
        self.signatureDateFormat = consentSignatureDateFormat
    }
    
    
    @ViewBuilder
    private func view(for section: ConsentDocument.Section) -> some View {
        switch section {
        case .markdown(let text):
            HStack {
                Markdown(text)
                Spacer()
                // we can't seem to get the `Markdown` view to make itself as wide as possible, so this is the next best option :/
            }
        case .toggle(let config):
            Toggle(
                config.prompt,
                isOn: consentDocument.binding(for: config)
            )
        case .select(let config):
            CustomPicker(
                title: config.prompt,
                selection: consentDocument.binding(for: config),
                options: config.options
            )
        case .signature(let config):
            ConsentSignatureForm(
                labels: signatureFieldLabels,
                storage: consentDocument.binding(for: config),
                isSigning: $consentDocument.isSigning,
                signatureDate: signatureDate,
                signatureDateFormat: signatureDateFormat
            )
        }
    }
}


extension ConsentDocumentView {
    private struct CustomPicker: View {
        let title: String
        @Binding var selection: ConsentDocument.SelectionOption?
        let options: [ConsentDocument.SelectionOption]
        
        var body: some View {
            HStack {
                Text(title)
                Spacer()
                Picker("", selection: $selection) {
                    Text(ConsentDocument.SelectConfig.emptySelectionDefaultTitle)
                        .tag(ConsentDocument.SelectionOption?.none)
                    ForEach(options, id: \.self) { option in
                        Text(option.title)
                            .foregroundStyle(.primary)
                            .tag(ConsentDocument.SelectionOption?.some(option))
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}


#if DEBUG
#Preview {
    let consentDocument = try! ConsentDocument(markdown: "This is a *markdown* **example**") // swiftlint:disable:this force_try
    NavigationStack {
        ConsentDocumentView(consentDocument: consentDocument)
            .navigationTitle(Text(verbatim: "Consent"))
            .padding()
    }
}
#endif
