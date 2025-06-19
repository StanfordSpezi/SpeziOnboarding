//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
@testable import SpeziConsent
import SpeziFoundation
import SwiftUI
import Testing


@Suite
struct ConsentParserTests {
    @Test
    func simpleParsing() throws {
        let input = """
            # Hello World
            
            This is our study.
            
            We look forward to welcoming you into the fold.
            - we
            - look
            - forward
            - to welcoming you
            """
        let result = try ConsentDocumentParser.parse(input)
        #expect(result.frontmatter.isEmpty)
        #expect(result.sections == [
            .markdown(input)
        ])
    }
    
    @Test
    @MainActor
    func frontmatterParsing() throws {
        let input = """
            ---
            title: abc
            version: 1.0.2
            ---
            
            First markdown block
            - abc
            - def
            """
        let document = try ConsentDocument(markdown: input)
        #expect(document.metadata == [
            "title": "abc",
            "version": "1.0.2"
        ])
        #expect(document.title == "abc")
        #expect(document.version == Version(1, 0, 2))
        #expect(document.sections == [
            .markdown("First markdown block\n- abc\n- def")
        ])
    }
    
    @Test
    func customElementParsing() throws {
        let input = """
            Hello *there* :)
            <toggle id=toggle1 initial-value=true expected-value=false>Prompt1</toggle>
            <toggle id=toggle2 initial-value=false expected-value=true>Prompt2</>
            <toggle id=toggle3 expected-value=true>Prompt3</>
            some more markdown
            <select id=select1 initial-value=option1>
                Please select your preference
                <option id=option1>Option1</>
                <option id=option2>Option2</>
            </select>
            even more mark down
            <signature id=sig1></signature>
            """
        let result = try ConsentDocumentParser.parse(input)
        #expect(result.frontmatter.isEmpty)
        #expect(result.sections == [
            .markdown("Hello *there* :)"),
            .toggle(.init(id: "toggle1", prompt: "Prompt1", initialValue: true, expectedValue: false)),
            .toggle(.init(id: "toggle2", prompt: "Prompt2", initialValue: false, expectedValue: true)),
            .toggle(.init(id: "toggle3", prompt: "Prompt3", initialValue: false, expectedValue: true)),
            .markdown("some more markdown"),
            .select(.init(
                id: "select1",
                prompt: "Please select your preference",
                options: [
                    .init(id: "option1", title: "Option1"),
                    .init(id: "option2", title: "Option2")
                ],
                initialValue: "option1",
                expectedSelection: .anything(allowEmptySelection: true)
            )),
            .markdown("even more mark down"),
            .signature(.init(id: "sig1"))
        ])
    }
    
    @Test(arguments: [
        "<signature id=sig></signature>",
        "<signature id=sig></>",
        "<signature id=sig />"
    ])
    func endOfTagHandling(input: String) throws {
        let result = try ConsentDocumentParser.parse(input)
        #expect(result == .init(frontmatter: [:], sections: [
            .signature(.init(id: "sig"))
        ]))
    }
    
    @Test
    func select0() throws {
        let input = """
            <select id=select1 initial-value=option1>
                <option id=option1>Text</>
            </select>
            """
        let result = try ConsentDocumentParser.parse(input)
        #expect(result == .init(sections: [
            .select(.init(
                id: "select1",
                prompt: "",
                options: [.init(id: "option1", title: "Text")],
                initialValue: "option1",
                expectedSelection: .anything(allowEmptySelection: true)
            ))
        ]))
    }
    
    @Test
    func select1() throws {
        let input = """
            <select id=select1 expected-value="*">
                Please select
                <option id=o1>T1</>
                your preferred option
                <option id=o2>T2</>
            </select>
            """
        let result = try ConsentDocumentParser.parse(input)
        #expect(result == .init(sections: [
            .select(.init(
                id: "select1",
                prompt: "Please select your preferred option",
                options: [.init(id: "o1", title: "T1"), .init(id: "o2", title: "T2")],
                initialValue: "",
                expectedSelection: .anything(allowEmptySelection: false)
            ))
        ]))
    }
    
    @Test
    func invalidInput0() throws {
        let input = """
            <select id=select1 initial-value=option1>
            </select>
            """
        #expect(throws: (any Error).self) {
            try ConsentDocumentParser.parse(input)
        }
    }
}
