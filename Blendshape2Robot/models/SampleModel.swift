//
//  SampleModel.swift
//  Blendshape2Robot
//
//  Created by Bowen Wu on 2023/11/03.
//

import Foundation
import Combine

class SampleModel {
    var arViewModel: ArViewModel
    var isSampling: Bool = false
    var messages: [String] = []
    var faceBlendShapes = [Float](repeating: 0.0, count: FaceBlendShape.allCases.count)
    internal var csvFile = CsvFile()
    
    init(arViewModel: ArViewModel) {
        self.arViewModel = arViewModel
    }
    
    func start_sampling(numSamples: Int, motionClient: MotionTcpClient) {
        if isSampling {
            messages.append("Sampling has already started.")
            return
        }
        messages.append("Sampling started.")
        isSampling = true
        
        var targetRig = [Int](repeating: 0, count: 35)
        
        // Background sampling
        DispatchQueue.global(qos: .userInitiated).async() {
            // Main loop
            for i in 0 ..< numSamples {
                // Perform inital pose
//              motionClient.send_ctl_cmd(initialRigs)
                sleep(1) // Wait 1 second for control to complete

                // Perform randomly sampled pose
                for j in 0 ..< targetRig.count {
                    targetRig[j] = Int.random(in: 0 ... 255)
                }
//              motionClient.send_ctl_cmd(targetRigs)
                sleep(1) // Wait 1 second for control to complete
    
                // Cache data
                self.csvFile.update_nikola_rig(targetRig)
                self.csvFile.update_blendshape(self.arViewModel.faceBlendShapes)
                
                // Info
                if self.isSampling {
                    self.messages.append(String(format: "Current sample count: %d", i + 1))
                } else {
                    break
                }
            }
            self.messages.append("Sampling stopped.")
            
            // Save cached data to file
            self.csvFile.save_and_empty_nikola_rig()
            self.csvFile.save_and_empty_blendshape()
            self.messages.append("Cached data saved.")
            
            // Reset state
            self.isSampling = false
        }
    }
    
    func stop_sampling() {
        if !isSampling {
            messages.append("Sampling has already stopped.")
            return
        }
        isSampling = false
    }
}
