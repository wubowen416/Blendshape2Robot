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
    var rigSafer = RigSafer()
    var isSampling: Bool = false
    var messages: [String] = []
    private var csvFile = CsvFile()
    
    init(arViewModel: ArViewModel) {
        self.arViewModel = arViewModel
    }
    
    func safen_rig(rig: inout [Int]) {
        rigSafer.safen_rig(rig: &rig, maxValue: arViewModel.rigMaximum)
        
        // Do not move neck
        rig[32] = 128
        rig[33] = 128
        rig[34] = 128
    }
    
    func start_sampling(numSamples: Int, nikolaClient: NikolaTcpClient) {
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
            let start = DispatchTime.now()
            
            for i in 0 ..< numSamples {
                // Perform inital pose
                // motionClient.send_ctl_cmd(initialRigs)
                // sleep(1) // Wait 1 second for control to complete

                // Perform randomly sampled pose
                for j in 0 ..< targetRig.count {
                    targetRig[j] = Int.random(in: 0 ... self.arViewModel.rigMaximum)
                }
                
                if self.arViewModel.safeRig {
                    self.safen_rig(rig: &targetRig)
                }
                
                nikolaClient.send_ctl_cmd(targetRig)
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
            
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000 // May overflow
            self.messages.append("Elapsed time: \(timeInterval) seconds")
            
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
