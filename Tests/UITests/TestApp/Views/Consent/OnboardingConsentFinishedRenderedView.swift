//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct OnboardingConsentFinishedRenderedView: View {
    let consentTitle: String
    let documentIdentifier: ConsentDocumentIdentifiers

    @Environment(OnboardingNavigationPath.self) private var path
    @Environment(ExampleStandard.self) private var standard
    @State var exportedConsent: PDFDocument?

    
    var body: some View {
        VStack {
            if (exportedConsent?.pageCount ?? 0) == 0 {
                Circle()
                    .fill(Color.red)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("\(consentTitle) PDF rendering doesn't exist")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
            } else {
                Circle()
                    .fill(Color.green)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("\(consentTitle) PDF rendering exists")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
            }
             
            Button {
                path.nextStep()
            } label: {
                Text("Next")
            }
                .buttonStyle(.borderedProminent)
        }
            .padding()
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .task {
                // Read and then clean up the respective exported consent document from the `ExampleStandard`
                switch documentIdentifier {
                case ConsentDocumentIdentifiers.first:
                    exportedConsent = standard.firstConsentDocument.take()
                case ConsentDocumentIdentifiers.second:
                    exportedConsent = standard.secondConsentDocument.take()
                }
            }
    }
}


#if DEBUG
#Preview {
    OnboardingStack(startAtStep: OnboardingConsentFinishedRenderedView.self) {
        for onboardingView in OnboardingFlow.previewSimulatorViews {
            onboardingView
        }
    }
}
#endif
