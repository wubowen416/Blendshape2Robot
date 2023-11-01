//
//  temp.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/03/16.
//

import Foundation
import UIKit
import RealityKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARView!
    
    // Create a capture session
    let captureSession = AVCaptureSession()
    
    // Create an asset writer
    var assetWriter: AVAssetWriter?
    
    // Create an asset writer input
    var assetWriterInput: AVAssetWriterInput?
    
    // Create a pixel buffer adaptor
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    // Create a URL for saving the video file
    let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("video.mov")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up capture session
        captureSession.sessionPreset = .hd1280x720
        
        // Set up asset writer
        do {
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            
            // Set up asset writer input
            let outputSettings: [String : Any] = [
                AVVideoCodecKey : AVVideoCodecType.h264,
                AVVideoWidthKey : 1280,
                AVVideoHeightKey : 720,
            ]
            
            assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
            assetWriterInput?.expectsMediaDataInRealTime = true
            
            // Set up pixel buffer adaptor
            let sourcePixelBufferAttributes: [String : Any] = [
                kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String : 1280,
                kCVPixelBufferHeightKey as String : 720,
            ]
            
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput!, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
            
            // Add input to writer
            if assetWriter!.canAdd(assetWriterInput!) {
                assetWriter!.add(assetWriterInput!)
            }
            
        } catch {
            print("Error setting up asset writer:", error.localizedDescription)
        }
        
        // Start writing session
        if !assetWriter!.startWriting() {
           print("Error starting writing session:", assetWriter!.error?.localizedDescription ?? "unknown error")
       }
        
       // Start capture session
       captureSession.startRunning()
        
       // Start AR session (you can customize this with your own configuration)
       sceneView.session.run(ARWorldTrackingConfiguration())
       
       // Subscribe to scene updates
        sceneView.scene.subscribe(to: SceneEvents.Update.self, on: nil) { event in
        
           guard let frame = self.scene.session.currentFrame else { return }
           
           if self.assetWriter?.status == .unknown {
               print("Starting writing at time \(frame.timestamp)")
               self.assetWriter?.startSession(atSourceTime:
                   CMTime(seconds:frame.timestamp , preferredTimescale:
                       1000000000))
           }
           
           if let input = self.assetWriterInput, input.isReadyForMoreMediaData {
               
               if let buffer = frame.capturedImage.imageBuffer as CVPixelBuffer? {
                   
                   print("Appending buffer at time \(frame.timestamp)")
                   self.pixelBufferAdaptor?.append(buffer, withPresentationTime:
                       CMTime(seconds:frame.timestamp , preferredTimescale:
                           1000000000))
               }
               
           } else {
               print("Not ready for more media data")
           }
           
       }

   }
}
