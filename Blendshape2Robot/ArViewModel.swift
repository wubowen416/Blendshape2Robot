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
    var solverTesterModel: RigSolverTester?
    @Published var nikolaHost: String
    @Published var nikolaPort: Int
    @Published var solverHost: String
    @Published var solverPort: Int
    @Published var showStatistics: Bool
    @Published var showFaceMesh: Bool
    @Published var connected: Bool
    @Published var solverConnected: Bool
    @Published var messages: [String] = []
    @Published var faceBlendShapes = [Float](repeating: 0.0, count: FaceBlendShape.allCases.count)
    @Published var nikolaRigs: [Int] = [Int](repeating: 0, count: 35)
    @Published var isRecording: Bool = false
    @Published var numSamples: Int = 1000
    @Published var rigMaximum: Int = 170
    @Published var safeRig: Bool = true
    @Published var numSamplesSolverTester: Int = 100
    @Published var rigMaximumSolverTester: Int = 170
    @Published var safeRigSolverTester: Bool = true
    
    // Solver args
    @Published var solverRate: Float = 0.1
    var rateOptions: [Float] = [0.1, 0.01, 0.001]
    @Published var solverNIterations: Int = 1000
    
    var faceMeshVertices = [vector_float3](repeating: vector_float3(repeating: 0.0), count: 1220)

    init() {
        showStatistics = blendshapeCvtModel.setting.showStatistics
        showFaceMesh = blendshapeCvtModel.setting.showFaceMesh
        nikolaHost = blendshapeCvtModel.setting.nikolaHost
        nikolaPort = blendshapeCvtModel.setting.nikolaPort
        solverHost = blendshapeCvtModel.setting.solverHost
        solverPort = blendshapeCvtModel.setting.solverPort
        connected = false
        solverConnected = false
        init_nikola_rigs(&nikolaRigs)
        self.sampleModel = SampleModel(arViewModel: self)
        self.solverTesterModel = RigSolverTester(arViewModel: self)
        collect_messages()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500),
                                      execute: sync_setting)
    }
    
    private func sync_setting() {
        showStatistics = blendshapeCvtModel.setting.showStatistics
        showFaceMesh = blendshapeCvtModel.setting.showFaceMesh
        nikolaHost = blendshapeCvtModel.setting.nikolaHost
        nikolaPort = blendshapeCvtModel.setting.nikolaPort
        solverHost = blendshapeCvtModel.setting.solverHost
        solverPort = blendshapeCvtModel.setting.solverPort
    }
    
    private func collect_messages() {
        if !blendshapeCvtModel.nikolaClient.messages.isEmpty {
            for msg in blendshapeCvtModel.nikolaClient.messages {
                messages.append(msg)
            }
            blendshapeCvtModel.nikolaClient.messages.removeAll()
        }
        connected = blendshapeCvtModel.nikolaClient.connected
        
        if !blendshapeCvtModel.solverClient.messages.isEmpty {
            for msg in blendshapeCvtModel.solverClient.messages {
                messages.append(msg)
            }
            blendshapeCvtModel.solverClient.messages.removeAll()
        }
        solverConnected = blendshapeCvtModel.solverClient.connected
        
        if let msgs = sampleModel?.messages, !msgs.isEmpty {
            for msg in msgs {
                messages.append(msg)
            }
            sampleModel?.messages.removeAll()
        }
        
        if let msgs = solverTesterModel?.messages, !msgs.isEmpty {
            for msg in msgs {
                messages.append(msg)
            }
            solverTesterModel?.messages.removeAll()
        }
        
        // Keep last 500 messages
        if messages.count == 500 {
            messages.remove(at: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250),
                                      execute: collect_messages)
    }
    
    func init_nikola_rigs(_ rigs: inout [Int]) {
        for i in 0 ..< rigs.count {
            rigs[i] = 0
        }
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
    
    func nikola_host_changed(to host: String) {
        nikolaHost = host
        blendshapeCvtModel.setting.nikolaHost = host
        blendshapeCvtModel.change_setting()
    }
    
    func nikola_port_changed(to port: Int) {
        nikolaPort = port
        blendshapeCvtModel.setting.nikolaPort = port
        blendshapeCvtModel.change_setting()
    }
    
    func request_connect_to_nikola() {
        blendshapeCvtModel.connect_to_nikola()
    }
    
    func request_disconnect_from_nikola() {
        blendshapeCvtModel.disconnect_from_nikola()
    }
    
    func solver_host_changed(to host: String) {
        solverHost = host
        blendshapeCvtModel.setting.solverHost = host
        blendshapeCvtModel.change_setting()
    }
    
    func solver_port_changed(to port: Int) {
        solverPort = port
        blendshapeCvtModel.setting.solverPort = port
        blendshapeCvtModel.change_setting()
    }
    
    func request_connect_to_solver() {
        blendshapeCvtModel.connect_to_solver()
    }
    
    func request_disconnect_from_solver() {
        blendshapeCvtModel.disconnect_from_solver()
    }
    
    func request_save_config() {
        blendshapeCvtModel.setting.showStatistics = showStatistics
        blendshapeCvtModel.setting.nikolaHost = nikolaHost
        blendshapeCvtModel.setting.nikolaPort = nikolaPort
        blendshapeCvtModel.setting.solverHost = solverHost
        blendshapeCvtModel.setting.solverPort = solverPort
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
            self.blendshapeCvtModel.nikolaClient.send_ctl_cmd(self.nikolaRigs)
        }
    }
    
    func start_rig_test() {
        for i in 0 ..< nikolaRigs.count {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(i+1)) {
                var dumyRigs = [Int](repeating: 0, count: 35)
                self.init_nikola_rigs(&dumyRigs)
                dumyRigs[i] = 255
                self.blendshapeCvtModel.nikolaClient.send_ctl_cmd(dumyRigs)
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
    
    func num_samples_solver_tester_changed(to num: Int) {
        numSamplesSolverTester = num
    }
    
    func rig_maximum_changed(to value: Int) {
        rigMaximum = value
    }
    
    func rig_maximum_solver_tester_changed(to value: Int) {
        rigMaximumSolverTester = value
    }
    
    func solver_rate_changed(to value: Float) {
        solverRate = value
    }
    
    func solver_n_iteration_changed(to value: Int) {
        solverNIterations = value
    }
    
    func start_sampling() {
        sampleModel?.start_sampling(numSamples: numSamples,
                                    nikolaClient: blendshapeCvtModel.nikolaClient)
    }
    
    func stop_sampling() {
        sampleModel?.stop_sampling()
    }
    
    func start_solver_test() {
        solverTesterModel?.start_test(numSamples: numSamplesSolverTester,
                                      solverClient: blendshapeCvtModel.solverClient,
                                      nikolaClient: blendshapeCvtModel.nikolaClient)
    }
    
    func stop_solver_test() {
        solverTesterModel?.stop_testing()
    }
    
    func map_current_blendshape () {
        solverTesterModel?.map_current_blendshape(solverClient: blendshapeCvtModel.solverClient,
                                                  nikolaClient: blendshapeCvtModel.nikolaClient)
    }
}
