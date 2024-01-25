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
                    Text("MainSetting")
                }
            FaceBlendShapeView()
                .tabItem {
                    Text("FaceBlendShape")
                }
            RigTestView()
                .tabItem {
                    Text("RigTest")
                }
            SampleFaceView()
                .tabItem {
                    Text("SampleFace")
                }
            TestSolverView()
                .tabItem {
                    Text("TestSolver")
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
