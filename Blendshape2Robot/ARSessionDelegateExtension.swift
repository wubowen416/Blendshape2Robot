//
//  ARSessionDelegateExtension.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/02/17.
//

import Foundation
import ARKit
import RealityKit

extension ARViewWithDelegate: ARSessionDelegate {
    static let sceneUnderstandingQuery = EntityQuery(where: .has(SceneUnderstandingComponent.self) && .has(ModelComponent.self))
    
    func make_face_material() -> PhysicallyBasedMaterial {
        let cgImage = #imageLiteral(resourceName: "wireframeTexture").cgImage!
        let faceTexture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
        
        var faceMaterial = PhysicallyBasedMaterial()
        faceMaterial.roughness = 0.2
        faceMaterial.metallic = 1.0
        faceMaterial.blending = .transparent(opacity: .init(1.0))
        faceMaterial.baseColor.texture = PhysicallyBasedMaterial.Texture.init(faceTexture!)
        
        return faceMaterial
    }
    
    func init_face_tracking() {
        self.session.delegate = self
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        if showStatistics {
            self.debugOptions = [.showStatistics]
        }
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if !isRecording || videoWriter == nil || videoWriter?.status != .writing {
            return
        }
        if writerInput?.isReadyForMoreMediaData ?? false {
            bufferAdaptor!.append(frame.capturedImage, withPresentationTime: frameTime)
        }
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor
        else { return }

        parent!.arViewModel.faceBlendShapes[FaceBlendShape.headRoll.rawValue]
        = atan2(faceAnchor.transform[0][1], faceAnchor.transform[1][1])
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.headPitch.rawValue]
        = asin(faceAnchor.transform[2][1])
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.headYaw.rawValue]
        = atan2(faceAnchor.transform[2][0], faceAnchor.transform[2][2])
        
        parent!.arViewModel.faceMeshVertices = faceAnchor.geometry.vertices
        
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeBlinkLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeBlinkLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeLookDownLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookDownLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeLookInLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookInLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeLookOutLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookOutLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeLookUpLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookUpLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeSquintLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeWideLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeWideLeft] as! Float
        
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeBlinkRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeBlinkRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeLookDownRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookDownRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeLookInRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookInRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeLookOutRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookOutRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeLookUpRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookUpRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeSquintRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.eyeWideRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeWideRight] as! Float
        
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.jawForward.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.jawForward] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.jawLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.jawLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.jawRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.jawRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.jawOpen.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.jawOpen] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthClose.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthClose] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthFunnel.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthFunnel] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthPucker.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthPucker] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthSmileLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthSmileLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthSmileRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthSmileRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthFrownLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthFrownLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthFrownRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthFrownRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthDimpleLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthDimpleLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthDimpleRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthDimpleRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthStretchLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthStretchLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthStretchRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthStretchRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthRollLower.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthRollLower] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthRollUpper.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthRollUpper] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthShrugLower.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthShrugLower] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthShrugUpper.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthShrugUpper] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthPressLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthPressLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthPressRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthPressRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthLowerDownLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthLowerDownLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthLowerDownRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthLowerDownRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthUpperUpLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthUpperUpLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.mouthUpperUpRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthUpperUpRight] as! Float
        
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.browDownLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.browDownLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.browDownRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.browDownRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.browInnerUp.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.browInnerUp] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.browOuterUpLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.browOuterUpLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.browOuterUpRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.browOuterUpRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.cheekPuff.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.cheekPuff] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.cheekSquintLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.cheekSquintLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.cheekSquintRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.cheekSquintRight] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.noseSneerLeft.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.noseSneerLeft] as! Float
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.noseSneerRight.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.noseSneerRight] as! Float
        
        parent!.arViewModel.faceBlendShapes[FaceBlendShape.tongueOut.rawValue]
        = faceAnchor.blendShapes[ARFaceAnchor.BlendShapeLocation.tongueOut] as! Float
            
        if parent!.arViewModel.showStatistics != showStatistics {
            showStatistics = parent!.arViewModel.showStatistics
            if showStatistics == true {
                self.debugOptions.insert(.showStatistics)
            } else {
                self.debugOptions.remove(.showStatistics)
            }
        }
        if parent!.arViewModel.showFaceMesh != showFaceMesh {
            showFaceMesh = parent!.arViewModel.showFaceMesh
            session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
        if showFaceMesh {
            self.scene.performQuery(ARViewWithDelegate.sceneUnderstandingQuery).forEach { entity in
                if entity.components[SceneUnderstandingComponent.self]?.entityType == .face {
                    (entity as! HasModel).model!.materials = [faceMaterial!]
                }
            }
        }
    }
    
    func setup_writer() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd_HHmmss"
        let date = Date()
        let filename = dateFormatter.string(from: date)
        
        let fileUrl = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(filename + ".mp4")
        
        do {
            videoWriter = try AVAssetWriter(outputURL: fileUrl, fileType: .mp4)
            let videoSetting: [String: Any] = [
                AVVideoCodecKey : AVVideoCodecType.h264,
                AVVideoWidthKey : 1280,
                AVVideoHeightKey : 720,
            ]
            writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSetting)
            writerInput?.expectsMediaDataInRealTime = true
            bufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput!)
            
            if videoWriter?.canAdd(writerInput!) ?? false {
                videoWriter!.add(writerInput!)
            }
            
            videoWriter?.startWriting()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func start_record() {
        if isRecording { return }
        setup_writer()
        isRecording = true
        
    }
    
    func stop_record() {
        if !isRecording { return }
        isRecording = false
        writerInput?.markAsFinished()
        videoWriter?.finishWriting {
            if let error = self.videoWriter?.error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
