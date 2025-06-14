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
/// Use SwiftUI `Bindings` to obtain information like the content of the signature and if the user is currently signing:
/// ```swift
/// @State var signature = PKDrawing()
/// @State var isSigning = false
/// 
///
/// SignatureView(
///     signature: $signature,
///     isSigning: $isSigning,
///     name: name,
///     formattedDate: "01/23/25"
/// )
/// ```
public struct SignatureView: View {
    /// The ``SignatureView``'s footer configuration
    public struct Footer: Sendable {
        let leadingText: Text?
        let trailingText: Text?
        
        /// Creates a new `Footer`, with optional leading and trailing texts.
        public init(leading: Text? = nil, trailing: Text? = nil) {
            self.leadingText = leading
            self.trailingText = trailing
        }
    }
    
    #if !os(macOS)
    @Binding private var signature: PKDrawing
    @Binding private var canvasSize: CGSize
    @Binding private var isSigning: Bool
    @State private var observedCanvasSizes = AsyncStream.makeStream(of: CGSize.self)
    #else
    @Binding private var signature: String
    #endif
    private let footer: Footer
    private let lineOffset: CGFloat
    
    private var canClear: Bool {
        !signature.strokes.isEmpty
    }
    
    
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
        // TODO?
//        #if !os(macOS)
//        .transition(.opacity)
//        .animation(.easeInOut, value: canUndo)
//        #endif
    }
    
    @available(macOS, unavailable)
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
            fatalError()
        }
    }
    
    #if os(macOS)
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
        signature: Binding<PKDrawing> = .constant(PKDrawing()),
        isSigning: Binding<Bool> = .constant(false),
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


#if DEBUG
#Preview("Base Signature View") {
    SignatureView()
}

#Preview("Including PersonNameComponents") {
    let name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    SignatureView(footer: .init(
        leading: Text(name, format: .name(style: .long))
    ))
}

#Preview("Including PersonNameComponents and Date") {
    @Previewable @Environment(\.calendar) var cal
    let name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    SignatureView(footer: .init(
        leading: Text(name, format: .name(style: .long)),
        // swiftlint:disable:next force_unwrapping
        trailing: Text(cal.date(from: .init(year: 2025, month: 1, day: 22))!, format: Date.FormatStyle(date: .numeric))
    ))
}

#Preview("Including PersonNameComponents and Date with different format") {
    @Previewable @Environment(\.calendar) var cal
    let name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    SignatureView(footer: .init(
        leading: Text(name, format: .name(style: .abbreviated)),
        // swiftlint:disable:next force_unwrapping
        trailing: Text(cal.date(from: .init(year: 2025, month: 1, day: 22))!, format: .iso8601)
    ))
}
#endif
