//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import SpeziViews
import SwiftUI


/// The ``ConsentViewState`` indicates in what state the ``ConsentDocument`` currently is.
/// It can be used to observe and control the behaviour of the ``ConsentDocument``, especially in regards
/// to the export functionality.
public enum ConsentViewState: Equatable {
    /// The ``ConsentViewState/base(_:)`` state utilizes the
    /// SpeziViews `ViewState`'s to indicate the state of the ``ConsentDocument``, either `.idle`, `.processing`, or `.error(_:)`.
    case base(SpeziViews.ViewState)
    /// The ``ConsentViewState/namesEntered`` state signifies that all required name fields in the ``ConsentDocument`` view have been completed.
    case namesEntered
    /// The ``ConsentViewState/signing`` state indicates that the ``ConsentDocument`` is currently being signed by the user.
    case signing
    /// The ``ConsentViewState/signed`` state indicates that the ``ConsentDocument`` is signed by the user.
    case signed
    /// The ``ConsentViewState/export`` state can be set by an outside view
    /// encapsulating the ``ConsentDocument`` to trigger the export of the consent document as a PDF.
    /// The previous state must be ``ConsentViewState/signed``, indicating that the consent document is signed.
    case export
    /// The ``ConsentViewState/exported(document:)`` state indicates that the
    /// ``ConsentDocument`` has been successfully exported. The rendered `PDFDocument` can be found as the associated value of the state.
    /// The export procedure (resulting in the ``ConsentViewState/exported(document:)`` state) can be triggered via setting the ``ConsentViewState/export`` state of the ``ConsentDocument``    .
    case exported(document: PDFDocument)
}
