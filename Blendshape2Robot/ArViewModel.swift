//
//  ArViewModel.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/02/09.
//

import Foundation
import simd

class ArViewModel: ObservableObject {
    var blendshapeCvtModel: BlendshapeCvtModel = BlendshapeCvtModel()
    var sampleModel: SampleModel?
    @Published var remoteHost: String
    @Published var remotePort: Int
    @Published var showStatistics: Bool
    @Published var showFaceMesh: Bool
    @Published var connected: Bool
    @Published var messages: [String] = []
    @Published var faceBlendShapes = [Float](repeating: 0.0, count: FaceBlendShape.allCases.count)
    @Published var nikolaRigs: [Int] = [Int](repeating: 0, count: 35)
    @Published var isRecording: Bool = false
    @Published var numSamples: Int = 5
    
    var faceMeshVertices = [vector_float3](repeating: vector_float3(repeating: 0.0), count: 1220)

    init() {
        showStatistics = blendshapeCvtModel.setting.showStatistics
        showFaceMesh = blendshapeCvtModel.setting.showFaceMesh
        remoteHost = blendshapeCvtModel.setting.remoteHost
        remotePort = blendshapeCvtModel.setting.remotePort
        connected = false
        init_nikola_rigs(&nikolaRigs)
        self.sampleModel = SampleModel(arViewModel: self)
        collect_messages()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500),
                                      execute: sync_setting)
    }
    
    private func sync_setting() {
        showStatistics = blendshapeCvtModel.setting.showStatistics
        showFaceMesh = blendshapeCvtModel.setting.showFaceMesh
        remoteHost = blendshapeCvtModel.setting.remoteHost
        remotePort = blendshapeCvtModel.setting.remotePort
    }
    
    private func collect_messages() {
        if !blendshapeCvtModel.motionClient.messages.isEmpty {
            for msg in blendshapeCvtModel.motionClient.messages {
                messages.append(msg)
            }
            blendshapeCvtModel.motionClient.messages.removeAll()
        }
        connected = blendshapeCvtModel.motionClient.connected
        
        if let msgs = sampleModel?.messages, !msgs.isEmpty {
            for msg in msgs {
                messages.append(msg)
            }
            sampleModel?.messages.removeAll()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250),
                                      execute: collect_messages)
    }
    
    func init_nikola_rigs(_ rigs: inout [Int]) {
        rigs[0] = 64
        rigs[1] = 64
        rigs[2] = 128
        rigs[3] = 128
        rigs[4] = 128
        rigs[31] = 32
        rigs[32] = 128
        rigs[33] = 128
        rigs[34] = 128
    }
    
    func remote_host_changed(to host: String) {
        remoteHost = host
    }
    
    func remote_port_changed(to port: Int) {
        remotePort = port
    }
    
    func request_connect() {
        blendshapeCvtModel.connect_motion_server()
    }
    
    func request_disconnect() {
        blendshapeCvtModel.disconnect()
    }
    
    func request_save_config() {
        blendshapeCvtModel.setting.showStatistics = showStatistics
        blendshapeCvtModel.setting.remoteHost = remoteHost
        blendshapeCvtModel.setting.remotePort = remotePort
        blendshapeCvtModel.change_setting()
    }
    
    func safety_check() {
        for i in 0 ..< nikolaRigs.count {
            if nikolaRigs[i] > 255 { nikolaRigs[i] = 255 }
            if nikolaRigs[i] < 0 {nikolaRigs[i] = 0 }
        }
    }
    
    func request_command_sending() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.safety_check()
            self.blendshapeCvtModel.motionClient.send_ctl_cmd(self.nikolaRigs)
        }
    }
    
    func start_rig_test() {
        for i in 0 ..< nikolaRigs.count {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(i+1)) {
                var dumyRigs = [Int](repeating: 0, count: 35)
                self.init_nikola_rigs(&dumyRigs)
                dumyRigs[i] = 255
                self.blendshapeCvtModel.motionClient.send_ctl_cmd(dumyRigs)
            }
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .milliseconds(i * 1000 + 1500)) {
                self.blendshapeCvtModel.csvFile.update_blendshape(self.faceBlendShapes)
                self.blendshapeCvtModel.csvFile.update_mesh(self.faceMeshVertices)
            }
        }
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(nikolaRigs.count + 1)) {
            self.blendshapeCvtModel.csvFile.save_test_data()
        }
    }
    
    func start_record() {
        
    }
    
    func num_samples_changed(to num: Int) {
        numSamples = num
    }
    
    func start_sampling() {
        sampleModel?.start_sampling(
            numSamples: numSamples,
            motionClient: blendshapeCvtModel.motionClient
        )
    }
    
    func stop_sampling() {
        sampleModel?.stop_sampling()
    }
}
