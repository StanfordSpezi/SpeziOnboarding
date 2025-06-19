//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PencilKit
import SpeziPersonalInfo
import SpeziViews
import SwiftUI


/// A Signature Form consisting of text fields for name entry, and a canvas for drawing a signature.
public struct ConsentSignatureForm: View {
    /// The maximum width such that the drawing canvas fits onto the PDF.
    static let maxWidthDrawing: CGFloat = 550

    private let labels: Labels
    private let signatureDate: Date?
    private let signatureDateFormat: Date.FormatStyle

    @Binding private var storage: ConsentDocument.SignatureStorage
    private var isSigning: Binding<Bool>?
    @FocusState private var nameInputIsFocused
    
    private let dividerId = UUID()
    
    private var nameView: some View {
        VStack {
            Divider()
            Group {
                #if !os(macOS)
                nameInputView
                #else
                // Need to wrap the `NameFieldRow` from SpeziViews into a SwiftUI `Form`, otherwise the Label is omitted
                Form {
                    nameInputView
                }
                #endif
            }
            .onChange(of: storage.name) {
                if !storage.didEnterNames {
                    // Reset all strokes if name fields are not complete anymore
                    self.storage.clearSignature()
                }
            }
            Divider()
                .id(dividerId)
        }
    }
    
    @ViewBuilder private var nameInputView: some View {
        Grid(horizontalSpacing: 15) {
            NameFieldRow(name: $storage.name, for: \.givenName) {
                Text(labels.givenNameTitle)
                    .fontWeight(.medium)
            } label: {
                Text(labels.givenNamePlaceholder)
            }
            Divider()
                .gridCellUnsizedAxes(.horizontal)
            NameFieldRow(name: $storage.name, for: \.familyName) {
                Text(labels.familyNameTitle)
                    .fontWeight(.medium)
            } label: {
                Text(labels.familyNamePlaceholder)
            }
        }
        .focused($nameInputIsFocused)
    }
    
    private var signatureView: some View {
        Group {
            let footer = SignatureView.Footer(
                name: storage.name.formatted(.name(style: .long)),
                date: signatureDate.map { $0.formatted(signatureDateFormat) } ?? ""
            )
            #if !os(macOS)
            SignatureView(
                signature: $storage.signature,
                isSigning: isSigning ?? .constant(false),
                canvasSize: $storage.size,
                footer: footer
            )
            #else
            SignatureView(
                signature: $storage.signature,
                footer: footer
            )
            #endif
        }
        .padding(.vertical, 4)
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            Group {
                nameView
                signatureView
            }
            .frame(maxWidth: Self.maxWidthDrawing) // Limit the max view size so it fits on the PDF
            .transition(.opacity)
            .animation(.easeInOut, value: storage.didEnterNames)
            .onChange(of: nameInputIsFocused) { old, new in
                if !old && new {
                    proxy.scrollTo(dividerId, anchor: .top) // this works, but seemingly only by accident???
                }
            }
        }
    }

    
    /// Creates a `ConsentDocument` which renders a consent document with a markdown view.
    ///
    /// - parameter labels: Allows customizing which text should be used for the signature field's labels.
    /// - parameter storage: A `Binding` to the storage that manages the data input into this view (i.e., the name and the signature).
    /// - parameter isSigning: An optional `Binding<Bool>` that will be updated by this view to indicate whether the user is currently entering their signature into the field.
    /// - parameter signatureDate: The date that is displayed under the signature line.
    /// - parameter signatureDateFormat: The date format used to format the `signatureDate`.
    public init(
        labels: Labels = .init(), // swiftlint:disable:this function_default_parameter_at_end
        storage: Binding<ConsentDocument.SignatureStorage>,
        isSigning: Binding<Bool>? = nil,
        signatureDate: Date? = nil,
        signatureDateFormat: Date.FormatStyle = .init(date: .numeric)
    ) {
        self._storage = storage
        self.labels = labels
        self.isSigning = isSigning
        self.signatureDate = signatureDate
        self.signatureDateFormat = signatureDateFormat
    }
}


#if DEBUG
#Preview {
    @Previewable @State var storage = ConsentDocument.SignatureStorage()
    NavigationStack {
        ConsentSignatureForm(
            storage: $storage,
            signatureDate: .now
        )
        .navigationTitle(Text(verbatim: "Consent"))
        .padding()
    }
}
#endif
