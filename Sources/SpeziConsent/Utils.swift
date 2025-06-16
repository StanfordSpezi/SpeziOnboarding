//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


protocol NavigatableFormField: CaseIterable, RawRepresentable, Comparable where RawValue: Comparable, AllCases: BidirectionalCollection {}

extension NavigatableFormField {
    var prev: Self? {
        Self.allCases.last { $0 < self }
    }
    
    var next: Self? {
        Self.allCases.first { $0 > self }
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}


extension View {
    @ToolbarContentBuilder
    func focusToolbarItems(for focusedField: FocusState<(some NavigatableFormField)?>.Binding) -> some ToolbarContent {
        ToolbarItem(placement: .keyboard) {
            HStack {
                Spacer()
                Button {
                    focusedField.wrappedValue = focusedField.wrappedValue?.prev
                } label: {
                    Image(systemName: "chevron.left")
                        .accessibilityLabel("Go to previous field")
                }
                .disabled(focusedField.wrappedValue?.prev == nil)
                Button {
                    focusedField.wrappedValue = focusedField.wrappedValue?.next
                } label: {
                    Image(systemName: "chevron.right")
                        .accessibilityLabel("Go to next field")
                }
                .disabled(focusedField.wrappedValue?.next == nil)
            }
        }
    }
}


private struct IdentifiableAdaptor<Value, ID: Hashable>: Identifiable {
    let value: Value
    private let _id: (Value) -> ID
    
    var id: ID { _id(value) }
    
    init(value: Value, id: @escaping (Value) -> ID) {
        self.value = value
        self._id = id
    }
}

extension View {
    public func sheet<Item, ID: Hashable>(
        item: Binding<Item?>,
        id: @escaping (Item) -> ID,
        onDismiss: (@MainActor () -> Void)? = nil,
        @ViewBuilder content: @MainActor @escaping (Item) -> some View
    ) -> some View {
        let binding = Binding<IdentifiableAdaptor<Item, ID>?> {
            if let item = item.wrappedValue {
                IdentifiableAdaptor(value: item, id: id)
            } else {
                nil
            }
        } set: { newValue in
            if let newValue {
                item.wrappedValue = newValue.value
            } else {
                item.wrappedValue = nil
            }
        }
        return self.sheet(item: binding, onDismiss: onDismiss) { item in
            content(item.value)
        }
    }
}
