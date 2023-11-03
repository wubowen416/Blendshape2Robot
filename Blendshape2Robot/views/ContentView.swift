//
//  ContentView.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/02/08.
//

import SwiftUI
import ARKit
import RealityKit

struct ContentView: View {
    @StateObject var arViewModel = ArViewModel()
    @State private var showSetting = false
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .ignoresSafeArea()
                .environmentObject(arViewModel)
                .sheet(isPresented: $showSetting, onDismiss: {
                    arViewModel.request_save_config()
                }) {
                    SettingView()
                        .presentationDetents([.fraction(0.6), .large])
                        .environmentObject(arViewModel)
                }
            VStack {
                Spacer()
                HStack {
                    Image(systemName: arViewModel.connected ? "record.circle" : "record.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                        .onTapGesture {
                            
                        }
                        .padding()
                    Image(systemName: (arViewModel.sampleModel?.isSampling ?? true) ? "play.circle" : "play.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                        .padding()
                }
                
            }
        }.onLongPressGesture { // double tap is not working!
            if showSetting == false {
                showSetting = true
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var arViewModel: ArViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARViewWithDelegate(self, frame: .zero)
        arView.init_face_tracking()
        
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

class ARViewWithDelegate: ARView {
    internal var showStatistics = true
    internal var showFaceMesh = false
    internal var parent: ARViewContainer?
    
    internal var videoWriter: AVAssetWriter?
    internal var writerInput: AVAssetWriterInput?
    internal var bufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    internal var isRecording: Bool = false
    internal let frameTime = CMTimeMake(value: 1, timescale: 60)
    
    var faceMaterial: PhysicallyBasedMaterial?
    let configuration = ARFaceTrackingConfiguration()
    
    init(_ parent: ARViewContainer, frame frameRect: CGRect) {
        super.init(frame: frameRect)
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        }
        configuration.isLightEstimationEnabled = true
        
        faceMaterial = make_face_material()
        self.parent = parent
        
        showStatistics = parent.arViewModel.showStatistics
        showFaceMesh = parent.arViewModel.showFaceMesh
    }
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ArViewModel())
    }
}
