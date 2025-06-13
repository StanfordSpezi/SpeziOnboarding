//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if os(macOS)
import AppKit
#endif
import Foundation
import PDFKit
import Spezi
import SpeziOnboarding
import SpeziViews
import SwiftUI


/// Onboarding view to display markdown-based consent documents that can be signed and exported.
///
/// The ``OnboardingConsentView`` provides a convenient onboarding `View` for the display of markdown-based documents that can be
/// signed using a family and given name and a hand drawn signature.
///
/// Furthermore, the `View` includes an export functionality, enabling users to share and store the signed consent form.
/// The exported consent form PDF is received via the `action` closure on the ``OnboardingConsentView/init(markdown:action:title:currentDateInSignature:exportConfiguration:)``.
///
/// The ``OnboardingConsentView`` builds on top of the SpeziOnboarding ``ConsentDocument``
/// by providing a more developer-friendly, convenient API with additional functionalities like the share consent option.
///
/// ```swift
/// OnboardingConsentView(
///     markdown: {
///         Data("This is a *markdown* **example**".utf8)
///     },
///     action: { exportedConsentPdf in
///         // The action that should be performed once the user has provided their consent.
///         // Closure receives the exported consent PDF to persist or upload it.
///     },
///     title: "Consent",   // Configure the title of the consent view
///     exportConfiguration: .init(paperSize: .usLetter),   // Configure the properties of the exported consent form
///     currentDateInSignature: true   // Indicates if the consent signature should include the current date
/// )
/// ```
public struct OnboardingConsentView: View {
    public typealias Action = @MainActor (_ document: PDFDocument) async throws -> Void
    
    /// Provides default localization values for necessary fields in the ``OnboardingConsentView``.
    public enum LocalizationDefaults {
        /// Default localized value for the title of the consent form.
        public static var consentFormTitle: LocalizedStringResource {
            LocalizedStringResource("CONSENT_VIEW_TITLE", bundle: .atURL(from: .module))
        }
    }
    
    private enum ConsentDocumentStorage {
        case pending(() async throws -> ConsentDocument)
        case processed(Result<ConsentDocument, any Swift.Error>)
    }
    
    private struct ExportResult: Identifiable, Equatable {
        let pdf: PDFKit.PDFDocument
        
        var id: ObjectIdentifier { ObjectIdentifier(pdf) }
    }
    
    private let title: LocalizedStringResource?
    private let action: Action
    private let currentDateInSignature: Bool
    private let exportConfiguration: ConsentDocument.ExportConfiguration
    
    @State private var consentDocumentStorage: ConsentDocumentStorage
    @State private var viewState: ViewState = .idle
    @State private var exportResult: ExportResult?
    
    private var consentDocument: ConsentDocument? {
        switch consentDocumentStorage {
        case .processed(.success(let document)):
            document
        case .pending, .processed(.failure):
            nil
        }
    }
    
    public var body: some View {
        // TODO bring back the scrolling!
        ScrollViewReader { proxy in // swiftlint:disable:this closure_body_length
            OnboardingView {
                if let title {
                    OnboardingTitleView(title: title)
                }
            } content: {
                Group {
                    switch consentDocumentStorage {
                    case .pending:
                        EmptyView()
                    case .processed(.success(let document)):
                        ConsentDocumentView(
                            consentDocument: document,
                            consentSignatureDate: currentDateInSignature ? .now : nil
                        )
                    case .processed(.failure):
                        EmptyView() // ???
                    }
                }
                .padding(.bottom)
            } footer: {
                AsyncButton(state: $viewState) {
                    try withAnimation(.easeOut(duration: 0.2)) {
                        exportResult = try (consentDocument?.export(config: exportConfiguration)).map { .init(pdf: $0) }
                    }
                } label: {
                    Text("CONSENT_ACTION", bundle: .module)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .processingOverlay(isProcessing: backButtonHidden)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!actionButtonsEnabled)
                .animation(.easeInOut(duration: 0.2), value: actionButtonsEnabled)
                .id("ActionButton")
            }
            .task {
                await loadConsentDocumentIfNecessary()
            }
            .scrollDisabled(consentDocument?.isSigning == true)
            .navigationBarBackButtonHidden(backButtonHidden)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let consentDocument {
                    AsyncButton(state: $viewState) {
                        exportResult = .init(pdf: try consentDocument.export(config: exportConfiguration))
                    } label: {
                        if consentDocument.isExporting {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Label {
                                Text("CONSENT_SHARE", bundle: .module)
                            } icon: {
                                Image(systemName: "square.and.arrow.up")
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .disabled(!actionButtonsEnabled)
                }
            }
        }
        #if !os(macOS)
        .sheet(item: $exportResult) { exportResult in
            ShareSheet(sharedItem: exportResult.pdf)
                .presentationDetents([.medium])
        }
        #else
        .onChange(of: exportResult) { _, exportResult in
            guard let pdf = exportResult?.pdf else {
                return
            }
            let shareSheet = ShareSheet(sharedItem: pdf)
            shareSheet.show()
            self.exportResult = nil
        }
        // `NSSharingServicePicker` doesn't provide a completion handler as `UIActivityViewController` does,
        // therefore necessitating the deletion of the temporary file on disappearing.
        .onDisappear {
            try? FileManager.default.removeItem(
                at: FileManager.default.temporaryDirectory.appendingPathComponent(
                    LocalizedStringResource("FILE_NAME_EXPORTED_CONSENT_FORM", bundle: .atURL(from: .module)).localizedString() + ".pdf"
                )
            )
        }
        #endif
    }

    private var backButtonHidden: Bool {
        guard let consentDocument else {
            return false
        }
        return (consentDocument.isExporting || exportResult != nil)
    }

    private var actionButtonsEnabled: Bool {
        if let consentDocument {
            !consentDocument.isExporting && consentDocument.completionState == .complete
        } else {
            false
        }
    }
    
    
    /// Creates an `OnboardingConsentView` which provides a convenient onboarding view for visualizing, signing, and exporting a consent form.
    /// - Parameters:
    ///   - markdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - action: The action that should be performed once the consent is given. Action is called with the exported consent document as a parameter.
    ///   - title: The title of the view displayed at the top. Can be `nil`, meaning no title is displayed.
    ///   - initialNameComponents: Allows prefilling the first and last name fields in the consent document.
    ///   - currentDateInSignature: Indicates if the consent document should include the current date in the signature field. Defaults to `true`.
    ///   - exportConfiguration: Defines the properties of the exported consent form via ``ConsentDocumentExportRepresentation/Configuration``.
    public init(
        markdown: @escaping () async -> Data,
        enableCustomElements: Bool = false,
        title: LocalizedStringResource? = LocalizationDefaults.consentFormTitle,
        initialName: PersonNameComponents? = nil,
        currentDateInSignature: Bool = true,
        exportConfiguration: ConsentDocument.ExportConfiguration = .init(),
        action: @escaping Action
    ) {
        self._consentDocumentStorage = .init(initialValue: .pending {
            try ConsentDocument(
                markdown: await markdown(),
                initialName: initialName,
                enableCustomElements: enableCustomElements
            )
        })
        self.title = title
        self.action = action
        self.currentDateInSignature = currentDateInSignature
        self.exportConfiguration = exportConfiguration
    }
    
    public init(
        consentDocumentUrl url: URL,
        enableCustomElements: Bool = false,
        title: LocalizedStringResource? = LocalizationDefaults.consentFormTitle,
        initialName: PersonNameComponents? = nil,
        currentDateInSignature: Bool = true,
        exportConfiguration: ConsentDocument.ExportConfiguration = .init(),
        action: @escaping Action
    ) {
        self._consentDocumentStorage = .init(initialValue: .pending {
            try ConsentDocument(
                contentsOf: url,
                initialName: initialName,
                enableCustomElements: enableCustomElements
            )
        })
        self.title = title
        self.action = action
        self.currentDateInSignature = currentDateInSignature
        self.exportConfiguration = exportConfiguration
    }
    
    
    private func loadConsentDocumentIfNecessary() async {
        switch consentDocumentStorage {
        case .pending(let makeDocument):
            do {
                consentDocumentStorage = .processed(.success(try await makeDocument()))
            } catch {
                consentDocumentStorage = .processed(.failure(error))
            }
        case .processed:
            break
        }
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        OnboardingConsentView(markdown: { Data("This is a *markdown* **example**".utf8) }) { _ in
            print("Next")
        }
    }
}
#endif
