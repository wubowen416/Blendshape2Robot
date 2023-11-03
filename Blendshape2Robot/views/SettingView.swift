//
//  SettingView.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/02/08.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var arViewModel: ArViewModel
    
    var body: some View {
        TabView {
            MainSettingView()
                .tabItem {
                    Text("Main Setting")
                }
            FaceBlendShapeView()
                .tabItem {
                    Text("Face Blend Shape")
                }
            RigTestView()
                .tabItem {
                    Text("Rig Test")
                }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(ArViewModel())
    }
}
