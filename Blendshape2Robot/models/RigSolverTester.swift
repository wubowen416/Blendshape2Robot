//
//  RigSolverTest.swift
//  Blendshape2Robot
//
//  Created by Bowen Wu on 2024/01/19.
//

import Foundation
import NIO

class RigSolverTester{
    var arViewModel: ArViewModel
    var rigSafer = RigSafer()
    var isTesting: Bool = false
    var messages: [String] = []
    private var csvFile = CsvFile()
    private var target_blendshape: String?
    
    init(arViewModel: ArViewModel) {
        self.arViewModel = arViewModel
    }
    
    func map_current_blendshape(solverClient: SolverTcpClient, nikolaClient: NikolaTcpClient) {
        DispatchQueue.global(qos: .userInitiated).async() {
            var request: String
            var targetBlendshapeString: String
            var solvedRigString: String
            var stringArray: [String.SubSequence]
            var rig: [Int]
            
            if !solverClient.connected {
                self.messages.append("solver server not connected.")
                return
            }
            self.messages.append("Request blendshape")
            targetBlendshapeString = Array(self.arViewModel.faceBlendShapes.prefix(51)).map { String($0) }.joined(separator: ",")
            
            self.messages.append("Request solving blendshape")
            request = "--task solve_rig_from_blendshape --rate \(self.arViewModel.solverRate) --n_iterations \(self.arViewModel.solverNIterations) --target_blendshape \(targetBlendshapeString) --progress True"
            solvedRigString = solverClient.request_data_from_server(request)
            solvedRigString += ",128,128,128" // Append fixed necks
            
            // String "0,1,2,3" to [Int]
            stringArray = solvedRigString.split(separator: ",")
            rig = stringArray.compactMap { Int($0) }
            
            if self.arViewModel.safeRigSolverTester {
                self.rigSafer.safen_rig(rig: &rig, maxValue: self.arViewModel.rigMaximumSolverTester)
            }
            
            // Send command
            if !nikolaClient.connected {
                self.messages.append("nikola server not connected.")
                return
            }
            self.messages.append("Send cmd to nikola")
            nikolaClient.send_ctl_cmd(rig)
        }
    }
    
    func start_test(numSamples: Int, solverClient: SolverTcpClient, nikolaClient: NikolaTcpClient) {
        if isTesting {
            messages.append("Testing has already started.")
            return
        }
        messages.append("Testing started.")
        isTesting = true
        
        DispatchQueue.global(qos: .userInitiated).async() {
            var request: String
            var targetBlendshapeString: String
            var solvedRigString: String
            var stringArray: [String.SubSequence]
            var rig: [Int]
            let start = DispatchTime.now()
            for i in 0 ..< numSamples {
                // Request a target blendshape from the server
                self.messages.append("Request blendshape")
                request = "--task retrieve_blendshape_random"
                targetBlendshapeString = solverClient.request_data_from_server(request)
                
                self.messages.append("Request solving blendshape")
                request = "--task solve_rig_from_blendshape --rate \(self.arViewModel.solverRate) --n_iterations \(self.arViewModel.solverNIterations) --target_blendshape \(targetBlendshapeString) --progress True"
                solvedRigString = solverClient.request_data_from_server(request)
                solvedRigString += ",128,128,128" // Append fixed necks
                
                // String "0,1,2,3" to [Int]
                stringArray = solvedRigString.split(separator: ",")
                rig = stringArray.compactMap { Int($0) }
                
                if self.arViewModel.safeRigSolverTester {
                    self.rigSafer.safen_rig(rig: &rig, maxValue: self.arViewModel.rigMaximumSolverTester)
                }
                
                // Send command
                nikolaClient.send_ctl_cmd(rig)
                sleep(1) // Wait 1 second for control to complete
                
                // Record target and solved blendshapes
                stringArray = targetBlendshapeString.split(separator: ",")
                self.csvFile.update_solved_nikola_rig(rig)
                self.csvFile.update_target_blendshape(stringArray.compactMap { Float($0) })
                self.csvFile.update_solved_blendshape(self.arViewModel.faceBlendShapes)
                
                if self.isTesting {
                    self.messages.append("Current test count: \(i+1)")
                } else {
                    break
                }
            }
            self.messages.append("Testing stopped.")
            
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000 // May overflow
            self.messages.append("Elapsed time: \(timeInterval) seconds")

            // Save cached data to file
            self.csvFile.save_and_empty_solved_nikola_rig()
            self.csvFile.save_and_empty_target_blendshape()
            self.csvFile.save_and_empty_solved_blendshape()
            self.messages.append("Cached data saved.")
            
            // Reset state
            self.isTesting = false
        }
    }
    
    func stop_testing() {
        if !isTesting {
            messages.append("Testing has already stopped.")
            return
        }
        isTesting = false
    }
}
