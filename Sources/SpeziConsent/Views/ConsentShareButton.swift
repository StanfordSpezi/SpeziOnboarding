//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PencilKit
import SpeziFoundation
import SpeziViews
import SwiftUI


/// Share a PDF representation of a ``ConsentDocument``.
///
/// The ``ConsentShareButton`` observes a consent document's state, automatically disabling itself if the document can't yet be exported (e.g., because it hasn't been completed yet).
public struct ConsentShareButton: View {
    private var consentDocument: ConsentDocument?
    private let exportConfiguration: ConsentDocument.ExportConfiguration
    @Binding private var viewState: ViewState
    @State private var exportPdf: ShareSheetInput?
    
    public var body: some View {
        AsyncButton(state: $viewState) {
            guard let consentDocument else {
                return
            }
            exportPdf = .init(try consentDocument.export(using: exportConfiguration).pdf)
        } label: {
            if let consentDocument, consentDocument.isExporting {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                Label {
                    Text("Share Consent Form")
                } icon: {
                    Image(systemName: "square.and.arrow.up")
                        .accessibilityHidden(true)
                }
            }
        }
        .disabled(consentDocument?.completionState != .complete || consentDocument?.isExporting == true)
        .shareSheet(item: $exportPdf)
    }
    
    /// Creates a new Consent Share Button
    ///
    /// - parameter consentDocument: The ``ConsentDocument`` this button should share
    /// - parameter exportConfiguration: The ``ConsentDocument/ExportConfiguration`` to use when creating the PDF.
    /// - parameter viewState: The `ViewState` to bind to. If the export fails, the error will be propagated to this view state.
    public init(
        consentDocument: ConsentDocument?,
        exportConfiguration: ConsentDocument.ExportConfiguration = .init(), // swiftlint:disable:this function_default_parameter_at_end
        viewState: Binding<ViewState>
    ) {
        self.consentDocument = consentDocument
        self.exportConfiguration = exportConfiguration
        self._viewState = viewState
    }
}
