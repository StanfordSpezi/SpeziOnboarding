//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PencilKit
import SpeziPersonalInfo
import SpeziViews
import SwiftUI

/// Display markdown-based consent documents that can be signed and exported.
///
/// Allows the display markdown-based consent documents that can be signed using a family and given name and a hand drawn signature.
/// In addition, it enables the export of the signed form as a PDF document.
///
/// To observe and control the current state of the `ConsentDocument`, the view requires passing down a ``ConsentViewState`` as a SwiftUI `Binding` in the
/// ``init(markdown:viewState:givenNameTitle:givenNamePlaceholder:familyNameTitle:familyNamePlaceholder:exportConfiguration:)`` initializer.
/// This `Binding` can then be used to trigger the export of the consent form via setting the state to ``ConsentViewState/export``.
/// After the rendering completes, the finished `PDFDocument` from Apple's PDFKit is accessible via the associated value of the view state in ``ConsentViewState/exported(document:)``.
/// Other possible states of the `ConsentDocument` are the SpeziViews `ViewState`'s accessible via the associated value in ``ConsentViewState/base(_:)``.
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
///     exportConfiguration: .init(paperSize: .usLetter)   // Configure the properties of the exported consent form
/// )
/// ```
public struct ConsentDocument: View {
    /// The maximum width such that the drawing canvas fits onto the PDF.
    static let maxWidthDrawing: CGFloat = 550

    let asyncMarkdown: () async -> Data
    private let givenNameTitle: LocalizedStringResource
    private let givenNamePlaceholder: LocalizedStringResource
    private let familyNameTitle: LocalizedStringResource
    private let familyNamePlaceholder: LocalizedStringResource
    let exportConfiguration: ExportConfiguration

    @Environment(\.colorScheme) var colorScheme
    @State var name = PersonNameComponents()
    #if !os(macOS)
    @State var signature = PKDrawing()
    #else
    @State var signature = String()
    #endif
    @State var signatureSize: CGSize = .zero
    @Binding private var viewState: ConsentViewState
    public static var checked: [String: String] = [:]
    @State public var checkboxSnapshot: UIImage?
    @State public var allElements = [MarkdownElement]()

    public enum MarkdownElement: Hashable {
        case signature(String)
        case checkbox(String, [String])
        case text(String)
    }
    @State private var markdownStrings: [String] = []
    @State public var cleanedMarkdownData: Data?

    private var nameView: some View {
        VStack {
            Divider()
            Group {
                #if !os(macOS)
                nameInputView
                #else
                // Need to wrap the `NameFieldRow` from SpeziViews into a SwiftUI `Form, otherwise the Label is omitted
                Form {
                    nameInputView
                }
                #endif
            }
            .disabled(inputFieldsDisabled)
            .onChange(of: name) {
                if !(name.givenName?.isEmpty ?? true) && !(name.familyName?.isEmpty ?? true) {
                    viewState = .namesEntered
                } else {
                    viewState = .base(.idle)
                    // Reset all strokes if name fields are not complete anymore
                    #if !os(macOS)
                    signature.strokes.removeAll()
                    #else
                    signature.removeAll()
                    #endif
                }
            }
            Divider()
        }
    }

    private func extractMarkdownCB() async -> [MarkdownElement] {
        let data = await asyncMarkdown()
        let dataString = String(data: data, encoding: .utf8)!

        var elements = [MarkdownElement]()
        var textBeforeCB = ""
        var searchForOptions = false
        var textCB = ""
        var options: [String] = []

        let lines = dataString.split(separator: "\n", omittingEmptySubsequences: false)
        print(lines)

        for line in lines {
            print("plain line: " + line)
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            print("trimmed line: " + trimmedLine)

            if trimmedLine.hasPrefix("- [ ]") {
                if !textBeforeCB.isEmpty {
                    print("currentText:")
                    print(textBeforeCB)
                    elements.append(.text(textBeforeCB))
                    print(elements)
                    textBeforeCB = ""
                }

                textCB = trimmedLine.dropFirst(5).trimmingCharacters(in: .whitespaces)
                print("task:")
                print(textCB)
                searchForOptions = true

            } else if searchForOptions {
                print("search for options")

                if trimmedLine.hasPrefix(">") {
                    print("an option")
                    let option = trimmedLine.dropFirst(1).trimmingCharacters(in: .whitespaces)
                    options.append(option)

                } else {
                    searchForOptions = false

                    if !options.isEmpty {
                        elements.append(.checkbox(textCB, options))
                        options = []
                        textCB = ""
                    } else {
                        elements.append(.checkbox(textCB, ["Yes", "No"]))
                        textCB = ""
                    }

                    textBeforeCB += line + "\n"
                }

            } else {
                searchForOptions = false
                textBeforeCB += line + "\n"
            }
        }

        if !textBeforeCB.isEmpty {
            elements.append(.text(textBeforeCB))
        }

        return elements
    }

    struct CheckBoxView: View {
        // TODO: add validation
        let question: String
        let options: [String]

        @State private var elementSelected = "-"
        
        var body: some View {
            VStack {
                HStack {
                    Text(question)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Menu {
                        ForEach(options, id: \.self) { theElement in
                            Button(theElement) {
                                withAnimation {
                                    elementSelected = theElement
                                    ConsentDocument.checked[question] = theElement
                                }
                            }
                        }
                    } label: {
                        Text(elementSelected)
                            .font(.system(size: 17))
                            .padding(5)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                Divider()
                    .gridCellUnsizedAxes(.horizontal)
            }
        }
    }

    private var nameInputView: some View {
        Grid(horizontalSpacing: 15) {
            NameFieldRow(name: $name, for: \.givenName) {
                Text(givenNameTitle)
            } label: {
                Text(givenNamePlaceholder)
            }
            Divider()
                .gridCellUnsizedAxes(.horizontal)
            NameFieldRow(name: $name, for: \.familyName) {
                Text(familyNameTitle)
            } label: {
                Text(familyNamePlaceholder)
            }
        }
    }

    private var signatureView: some View {
        Group {
            #if !os(macOS)
            SignatureView(signature: $signature, isSigning: $viewState.signing, canvasSize: $signatureSize, name: name)
            #else
            SignatureView(signature: $signature, name: name)
            #endif
        }
        .padding(.vertical, 4)
        .disabled(inputFieldsDisabled)
        .onChange(of: signature) {
            #if !os(macOS)
            let isSignatureEmpty = signature.strokes.isEmpty
            #else
            let isSignatureEmpty = signature.isEmpty
            #endif
            if !(isSignatureEmpty || (name.givenName?.isEmpty ?? true) || (name.familyName?.isEmpty ?? true)) {
                viewState = .signed
            } else {
                viewState = .namesEntered
            }
        }
    }

    public var body: some View {
        ScrollView {
            ForEach(allElements, id: \.self) { element in
                switch element {
                case .text(let text):
                    if let data = text.data(using: .utf8) {
                        MarkdownView(asyncMarkdown: {data}, state: $viewState.base)
                    }
                case .checkbox(let question, let options):
                    CheckBoxView(
                        question: question,
                        options: options
                    )
                    .onAppear {
                        if let selectedOption = ConsentDocument.checked[question] {
                            ConsentDocument.checked[question] = selectedOption
                        } else {
                            ConsentDocument.checked[question] = "-"
                        }
                    }
                case .signature:
                    signatureView
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: viewState == .namesEntered)
        .onChange(of: viewState) { newState in
            if case .export = newState {
                // TODO: add export logic
            } else if case .base(let baseViewState) = newState, case .idle = baseViewState {
                #if !os(macOS)
                let isSignatureEmpty = signature.strokes.isEmpty
                #else
                let isSignatureEmpty = signature.isEmpty
                #endif
                if !isSignatureEmpty {
                    viewState = .signed
                } else if !(name.givenName?.isEmpty ?? true) || !(name.familyName?.isEmpty ?? true) {
                    viewState = .namesEntered
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: viewState == .namesEntered)
        .onAppear {
            Task {
                let elements = await extractMarkdownCB()
                allElements = elements
                for case let .checkbox(question, options) in elements {
                    ConsentDocument.checked[question] = "-"
                }
            }
        }
    }

    private var inputFieldsDisabled: Bool {
        viewState == .base(.processing) || viewState == .export
    }

    /// Creates a `ConsentDocument` which renders a consent document with a markdown view.
    ///
    /// The passed ``ConsentViewState`` indicates in which state the view currently is.
    /// This is especially useful for exporting the consent form as well as error management.
    /// - Parameters:
    ///   - markdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - viewState: A `Binding` to observe the ``ConsentViewState`` of the ``ConsentDocument``.
    ///   - givenNameTitle: The localization to use for the given (first) name field.
    ///   - givenNamePlaceholder: The localization to use for the given name field placeholder.
    ///   - familyNameTitle: The localization to use for the family (last) name field.
    ///   - familyNamePlaceholder: The localization to use for the family name field placeholder.
    ///   - exportConfiguration: Defines the properties of the exported consent form via ``ConsentDocument/ExportConfiguration``.
    public init(
        markdown: @escaping () async -> Data,
        viewState: Binding<ConsentViewState>,
        givenNameTitle: LocalizedStringResource = LocalizationDefaults.givenNameTitle,
        givenNamePlaceholder: LocalizedStringResource = LocalizationDefaults.givenNamePlaceholder,
        familyNameTitle: LocalizedStringResource = LocalizationDefaults.familyNameTitle,
        familyNamePlaceholder: LocalizedStringResource = LocalizationDefaults.familyNamePlaceholder,
        exportConfiguration: ExportConfiguration = .init()
    ) {
        self.asyncMarkdown = markdown
        self._viewState = viewState
        self.givenNameTitle = givenNameTitle
        self.givenNamePlaceholder = givenNamePlaceholder
        self.familyNameTitle = familyNameTitle
        self.familyNamePlaceholder = familyNamePlaceholder
        self.exportConfiguration = exportConfiguration
    }

#if DEBUG
#Preview {
    @Previewable @State var viewState: ConsentViewState = .base(.idle)


    NavigationStack {
        ConsentDocument(
            markdown: {
                Data("This is a *markdown* **example**".utf8)
            },
            viewState: $viewState
        )
        .navigationTitle(Text(verbatim: "Consent"))
        .padding()
    }
}
#endif
}
