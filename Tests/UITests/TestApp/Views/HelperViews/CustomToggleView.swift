//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CustomToggleView: View {
    var text: String
    @Binding var condition: Bool
    
    
    var body: some View {
        HStack {
            Button {
                condition.toggle()
            } label: {
                Text(text)
            }
            
            Rectangle()
                .fill(condition ? Color.green : Color.red)
                .frame(width: 20, height: 20)
        }
    }
}


#if DEBUG
struct CustomToggleView_Previews: PreviewProvider {
    static var previews: some View {
        CustomToggleView(
            text: "Test toggle",
            condition: .constant(false)
        )
    }
}
#endif
