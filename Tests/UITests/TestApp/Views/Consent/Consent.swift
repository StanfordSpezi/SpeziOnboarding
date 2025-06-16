//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import class PDFKit.PDFDocument
import SpeziConsent
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct Consent: View {
    let url: URL
    
    @Environment(ManagedNavigationStack.Path.self)
    private var path
    
    @State private var consentDocument: ConsentDocument?
    @State private var exportPDF: ShareSheetInput?
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        OnboardingConsentView(consentDocument: consentDocument) {
            path.nextStep()
        }
        .viewStateAlert(state: $viewState)
        .shareSheet(item: $exportPDF)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                shareButton
            }
        }
        .task {
            do {
                consentDocument = try ConsentDocument(contentsOf: url)
            } catch {
                viewState = .error(AnyLocalizedError(error: error))
            }
        }
    }
    
    @ViewBuilder private var shareButton: some View {
        AsyncButton(state: $viewState) {
            guard let consentDocument else {
                return
            }
            exportPDF = .init(try consentDocument.export(using: .init()))
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
    }
}
