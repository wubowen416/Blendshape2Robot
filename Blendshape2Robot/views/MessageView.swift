//
//  MessageView.swift
//  Blendshape2Robot
//
//  Created by liu on 2021/05/20.
//

import SwiftUI

struct MessageView: View {
    @EnvironmentObject var arViewModel: ArViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(arViewModel.messages.indices.reversed(), id: \.self) { i in
                        Text(arViewModel.messages[i])
                            .foregroundColor(.secondary)
//                            .id(text.self)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
            .environmentObject(ArViewModel())
    }
}
