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

/// Display a markdown-based ``ConsentDocument`` that can be filled out, signed, and exported.
///
/// Allows the display markdown-based consent documents that can be signed using a family and given name and a hand drawn signature.
///
/// Your app creates a ``ConsentDocument``, which acts as the model representing a markdown-based consent form.
/// This view displays the ``ConsentDocument``, and enables data entry into the document's interactive components, such as e.g. checkboxes, selection pickers, and signature fields.
///
/// - Important: A `ConsentDocumentView` should always be placed in a `ScrollView`.
///     Otherwise, the `ConsentDocumentView`'s contents will easily overflow the available screen space.
///     If you use a ``OnboardingConsentView``, the `ScrollView` is taken care of for you.
///
/// > Note: In the context of user onboarding, you might want to use the ``OnboardingConsentView`` instead.
public struct ConsentDocumentView: View {
    @Bindable private var consentDocument: ConsentDocument
    private let signatureFieldLabels: ConsentSignatureForm.Labels
    private let signatureDate: Date?
    private let signatureDateFormat: Date.FormatStyle
    
    public var body: some View {
        MarkdownDocumentView(
            markdownDocument: consentDocument.markdownDocument,
            dividerRule: .custom { _, sndBlockIdx -> Bool in
                !consentDocument.sections[sndBlockIdx].isSignature
            }
        ) { blockIdx, _ in
            let section = consentDocument.sections[blockIdx]
            if section.isSignature && blockIdx == consentDocument.sections.endIndex - 1 {
                // if the last section is a signature, we add a spacer.
                // this means that, if the consent is short, we push the signature field down all the way to the bottom of the screen.
                Spacer()
            }
            view(for: section)
        }
    }
    
    /// Creates a `ConsentDocumentView`, which renders a consent document with a markdown view.
    ///
    /// - parameter consentDocument: The consent document the view should display and edit.
    /// - parameter signatureFieldLabels: Allows customizing which text should be used for labels in signature fields within this ``ConsentDocumentView``.
    /// - parameter consentSignatureDate: The date that should be used for the signature.
    /// - parameter consentSignatureDateFormat: The `Date.FormatStyle` that should be used when rendering `consentSignatureDate`.
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
        case .markdown:
            let _ = preconditionFailure("unreachable") // swiftlint:disable:this redundant_discardable_let
        case .toggle(let config):
            let valueBinding = consentDocument.binding(for: config)
            Toggle(
                config.prompt,
                isOn: valueBinding
            )
            .accessibilityIdentifier(for: config)
            // Goal: we want a Toggle that can be toggled by tapping anywhere in its frame.
            // Issue: using only `.onTapGesture` doesn't quite work, since that'll only trigger for touches that are in the
            //     left part of the view, where the Toggle's text is, but not for eg above/below the Toggle, if the text is significantly taller
            //     than the Toggle itself.
            // Solution: this combination of using both `.onTapGesture` directly on the view and adding a custom clear background with a
            //     tap gesture of its own covers both scenarios. (Having only the background tap gesture, without the one directly on the view
            //     doesn't work, since that'll only trigger for interactions with the region above/below the Toggle, but not for taps in the text area.)
            // Alternative: We could also have placed the Toggle in a ZStack, and added a clear layer with a tap gesture on top of the Toggle,
            //     but that wouldn't let any touch events through to the toggle, meaning that you can't e.g. drag it via a long touch interaction.
            .background {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        valueBinding.wrappedValue.toggle()
                    }
            }
            .onTapGesture {
                valueBinding.wrappedValue.toggle()
            }
        case .select(let config):
            CustomPicker(
                config: config,
                selection: consentDocument.binding(for: config)
            )
        case .signature(let config):
            ConsentSignatureForm(
                labels: signatureFieldLabels,
                storage: consentDocument.binding(for: config),
                isSigning: $consentDocument.isSigning,
                signatureDate: signatureDate,
                signatureDateFormat: signatureDateFormat
            )
            .accessibilityIdentifier(for: config)
        }
    }
}


extension ConsentDocumentView {
    private struct CustomPicker: View {
        let config: ConsentDocument.SelectConfig
        @Binding var selection: String
        
        var body: some View {
            HStack {
                Text(config.prompt)
                Spacer()
                Picker("", selection: $selection) {
                    Text(ConsentDocument.SelectConfig.emptySelectionDefaultTitle)
                        .tag(ConsentDocument.SelectConfig.emptySelection)
                    ForEach(config.options, id: \.self) { option in
                        Text(option.title)
                            .foregroundStyle(.primary)
                            .tag(option.id)
                    }
                }
                .accessibilityIdentifier(for: config)
                .pickerStyle(.menu)
                .tint(tintColor)
            }
        }
        
        private var tintColor: Color? {
            switch config.expectedSelection {
            case .anything(allowEmptySelection: true):
                nil
            case .option, .anything(allowEmptySelection: false):
                selection == ConsentDocument.SelectConfig.emptySelection ? .red : nil
            }
        }
    }
}


extension View {
    fileprivate func accessibilityIdentifier(for section: some ConsentDocument.InteractiveSectionProtocol) -> some View {
        self.accessibilityIdentifier("ConsentForm:\(section.id)")
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
