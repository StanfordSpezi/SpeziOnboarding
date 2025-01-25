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
///     name: name
/// )
/// ```
public struct SignatureView: View {
    #if !os(macOS)
    @Environment(\.undoManager) private var undoManager
    @Binding private var signature: PKDrawing
    @Binding private var canvasSize: CGSize
    @Binding private var isSigning: Bool
    @State private var canUndo = false
    #else
    @Binding private var signature: String
    #endif
    private let name: PersonNameComponents
    private let formattedDate: String?
    private let lineOffset: CGFloat
    
    
    public var body: some View {
        VStack {
            ZStack(alignment: .bottomLeading) {
                SignatureViewBackground(
                    name: name,
                    formattedDate: formattedDate,
                    lineOffset: lineOffset
                )

                #if !os(macOS)
                CanvasView(drawing: $signature, isDrawing: $isSigning, showToolPicker: .constant(false))
                    .accessibilityLabel(Text("SIGNATURE_FIELD", bundle: .module))
                    .accessibilityAddTraits(.allowsDirectInteraction)
                    .onPreferenceChange(CanvasView.CanvasSizePreferenceKey.self) { size in
                        runOrScheduleOnMainActor {
                            // for some reason, the preference won't update on visionOS if placed in a parent view
                            self.canvasSize = size
                        }
                    }
                #else
                signatureTextField
                #endif
            }
                .frame(height: 120)
            
            #if !os(macOS)
            Button(
                action: {
                    undoManager?.undo()
                    canUndo = undoManager?.canUndo ?? false
                },
                label: {
                    Text("SIGNATURE_VIEW_UNDO", bundle: .module)
                }
            )
                .disabled(!canUndo)
            #endif
        }
            #if !os(macOS)
            .onChange(of: isSigning) {
                runOrScheduleOnMainActor {
                    canUndo = undoManager?.canUndo ?? false
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: canUndo)
            #endif
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
    ///   - name: The name that is displayed under the signature line.
    ///   - formattedDate: The formatted date that is displayed under the signature line.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    public init(
        signature: Binding<PKDrawing> = .constant(PKDrawing()),
        isSigning: Binding<Bool> = .constant(false),
        canvasSize: Binding<CGSize> = .constant(.zero),
        name: PersonNameComponents = PersonNameComponents(),
        formattedDate: String? = nil,
        lineOffset: CGFloat = 30
    ) {
        self._signature = signature
        self._isSigning = isSigning
        self._canvasSize = canvasSize
        self.name = name
        self.formattedDate = formattedDate
        self.lineOffset = lineOffset
    }

    /// Creates a new instance of an ``SignatureView``  with `String`-based name components.
    /// - Parameters:
    ///   - signature: A `Binding` containing the current signature as an `PKDrawing`.
    ///   - isSigning: A `Binding` indicating if the user is currently signing.
    ///   - canvasSize: The size of the canvas as a Binding.
    ///   - givenName: The given name that is displayed under the signature line.
    ///   - familyName: The family name that is displayed under the signature line.
    ///   - formattedDate: The formatted date that is displayed under the signature line.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    public init(
        signature: Binding<PKDrawing> = .constant(PKDrawing()),
        isSigning: Binding<Bool> = .constant(false),
        canvasSize: Binding<CGSize> = .constant(.zero),
        givenName: String = "",
        familyName: String = "",
        formattedDate: String? = nil,
        lineOffset: CGFloat = 30
    ) {
        self.init(
            signature: signature,
            isSigning: isSigning,
            canvasSize: canvasSize,
            name: .init(givenName: givenName, familyName: familyName),
            formattedDate: formattedDate,
            lineOffset: lineOffset
        )
    }
    #else
    /// Creates a new instance of an ``SignatureView``.
    /// - Parameters:
    ///   - signature: A `Binding` containing the current text-based signature as a `String`.
    ///   - name: The name that is displayed under the signature line.
    ///   - formattedDate: The formatted date that is displayed under the signature line.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    public init(
        signature: Binding<String> = .constant(String()),
        name: PersonNameComponents = PersonNameComponents(),
        formattedDate: String? = nil,
        lineOffset: CGFloat = 30
    ) {
        self._signature = signature
        self.name = name
        self.formattedDate = formattedDate
        self.lineOffset = lineOffset
    }

    /// Creates a new instance of an ``SignatureView`` with `String`-based name components.
    /// - Parameters:
    ///   - signature: A `Binding` containing the current text-based signature as a `String`.
    ///   - givenName: The given name that is displayed under the signature line.
    ///   - familyName: The family name that is displayed under the signature line.
    ///   - formattedDate: The formatted date that is displayed under the signature line.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    public init(
        signature: Binding<String> = .constant(String()),
        givenName: String = "",
        familyName: String = "",
        formattedDate: String? = nil,
        lineOffset: CGFloat = 30
    ) {
        self.init(
            signature: signature,
            name: .init(givenName: givenName, familyName: familyName),
            formattedDate: formattedDate,
            lineOffset: lineOffset
        )
    }
    #endif
}


#if DEBUG
#Preview("Base Signature View") {
    SignatureView()
}

#Preview("Including PersonNameComponents") {
    SignatureView(name: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))
}

#Preview("Including String-based names") {
    SignatureView(givenName: "Leland", familyName: "Stanford")
}

#Preview("Including PersonNameComponents and Date") {
    SignatureView(
        name: PersonNameComponents(givenName: "Leland", familyName: "Stanford"),
        formattedDate: "01/22/25"
    )
}

#Preview("Including PersonNameComponents and Date with custom format") {
    SignatureView(
        name: PersonNameComponents(givenName: "Leland", familyName: "Stanford"),
        formattedDate: "01/22/25"
    )
}
#endif
