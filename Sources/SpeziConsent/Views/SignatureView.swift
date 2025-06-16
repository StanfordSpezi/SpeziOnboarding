//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PencilKit
import SpeziFoundation
import SpeziViews
import SwiftUI


/// Input freeform signatures using a finger or the Apple Pencil.
///
/// Use SwiftUI `Bindings` provide storage for the signature itself (a `PKDrawing`) and to keep track of whether the user is currently signing their signature:
/// ```swift
/// @State var signature = PKDrawing()
/// @State var isSigning = false
///
/// SignatureView(signature: $signature, isSigning: $isSigning)
/// ```
///
/// You can optionally also keep track of the size of the canvas, and provide text that should be displayed in the ``SignatureView``'s footer:
/// ```swift
/// @State var signature = PKDrawing()
/// @State var isSigning = false
/// @State var canvasSize: CGSize = .zero
/// let name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
///
/// SignatureView(
///     signature: $signature,
///     isSigning: $isSigning,
///     canvasSize: $canvasSize,
///     footer: .init(
///         leading: Text(name, format: .name(style: .long)),
///         trailing: Text(Date.now, format: Date.FormatStyle(date: .numeric))
///     )
/// )
/// ```
public struct SignatureView: View {
    /// The ``SignatureView``'s footer configuration
    public struct Footer: Sendable {
        let nameText: String
        let dateText: String
        
        /// Creates a new `Footer`, with optional leading and trailing texts.
        public init(name: String = "", date: String = "") {
            self.nameText = name
            self.dateText = date
        }
    }
    
    #if !os(macOS)
    @Binding private var signature: PKDrawing
    @Binding private var canvasSize: CGSize
    @Binding private var isSigning: Bool
    @State private var observedCanvasSizes = AsyncStream.makeStream(of: CGSize.self)
    private var canClear: Bool {
        !signature.strokes.isEmpty
    }
    #else
    @Binding private var signature: String
    #endif
    private let footer: Footer
    private let lineOffset: CGFloat
    
    
    public var body: some View {
        VStack {
            ZStack(alignment: .bottomLeading) {
                SignatureViewBackground(footer: footer, lineOffset: lineOffset)
                #if !os(macOS)
                signatureCanvas
                #else
                signatureTextField
                #endif
            }
            .frame(height: 120)
            #if !os(macOS)
            Button {
                signature = .init()
            } label: {
                Text("SIGNATURE_VIEW_CLEAR", bundle: .module)
            }
            .disabled(!canClear)
            #endif
        }
    }
    
    #if !os(macOS)
    private var signatureCanvas: some View {
        CanvasView(
            drawing: $signature,
            isDrawing: $isSigning,
            showToolPicker: .constant(false)
        )
        .accessibilityLabel(Text("SIGNATURE_FIELD", bundle: .module))
        .accessibilityAddTraits(.allowsDirectInteraction)
        .onPreferenceChange(CanvasView.CanvasSizePreferenceKey.self) { size in
            observedCanvasSizes.continuation.yield(size)
        }
        .task {
            for await size in observedCanvasSizes.stream {
                self.canvasSize = size
            }
            observedCanvasSizes = AsyncStream.makeStream()
        }
    }
    #else
    private var signatureTextField: some View {
        TextField(text: $signature) {
            Text("SIGNATURE_FIELD", bundle: .module)
        }
        .accessibilityLabel(Text("SIGNATURE_FIELD", bundle: .module))
        .accessibilityAddTraits(.allowsDirectInteraction)
        .font(.custom("Snell Roundhand", size: 32))
        .textFieldStyle(PlainTextFieldStyle())
        .background(Color.clear)
        .padding(.bottom, lineOffset + 2)
        .padding(.leading, 46)
        .padding(.trailing, 24)
    }
    #endif
    
    
    #if !os(macOS)
    /// Creates a new instance of an ``SignatureView``.
    /// - Parameters:
    ///   - signature: A `Binding` containing the current signature as an `PKDrawing`.
    ///   - isSigning: A `Binding` indicating if the user is currently signing.
    ///   - canvasSize: The size of the canvas as a Binding.
    ///   - footer: The footer's content.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    public init(
        signature: Binding<PKDrawing>,
        isSigning: Binding<Bool>,
        canvasSize: Binding<CGSize> = .constant(.zero),
        footer: Footer = .init(),
        lineOffset: CGFloat = 30
    ) {
        self._signature = signature
        self._isSigning = isSigning
        self._canvasSize = canvasSize
        self.footer = footer
        self.lineOffset = lineOffset
    }
    #else
    /// Creates a new instance of an ``SignatureView``.
    /// - Parameters:
    ///   - signature: A `Binding` containing the current text-based signature as a `String`.
    ///   - footer: The footer's content.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    public init(
        signature: Binding<String> = .constant(String()),
        footer: Footer = .init(),
        lineOffset: CGFloat = 30
    ) {
        self._signature = signature
        self.footer = footer
        self.lineOffset = lineOffset
    }
    #endif
}


#if DEBUG && !os(macOS)
#Preview("Base Signature View") {
    @Previewable @State var signature = PKDrawing()
    @Previewable @State var isSigning = false
    SignatureView(signature: $signature, isSigning: $isSigning)
}

#Preview("Including PersonNameComponents") {
    @Previewable @State var signature = PKDrawing()
    @Previewable @State var isSigning = false
    let name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    SignatureView(
        signature: $signature,
        isSigning: $isSigning,
        footer: .init(
            name: name.formatted(.name(style: .long))
        )
    )
}

#Preview("Including PersonNameComponents and Date") {
    @Previewable @Environment(\.calendar) var cal
    @Previewable @State var signature = PKDrawing()
    @Previewable @State var isSigning = false
    let name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    SignatureView(
        signature: $signature,
        isSigning: $isSigning,
        footer: .init(
            name: name.formatted(.name(style: .long)),
            // swiftlint:disable:next force_unwrapping
            date: cal.date(from: .init(year: 2025, month: 1, day: 22))!.formatted(date: .numeric, time: .omitted)
        )
    )
}

#Preview("Including PersonNameComponents and Date with different format") {
    @Previewable @Environment(\.calendar) var cal
    @Previewable @State var signature = PKDrawing()
    @Previewable @State var isSigning = false
    let name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    SignatureView(
        signature: $signature,
        isSigning: $isSigning,
        footer: .init(
            name: name.formatted(.name(style: .abbreviated)),
            // swiftlint:disable:next force_unwrapping
            date: cal.date(from: .init(year: 2025, month: 1, day: 22))!.ISO8601Format()
        )
    )
}
#endif
