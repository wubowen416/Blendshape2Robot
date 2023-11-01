//
//  File.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/02/16.
//

import Foundation

enum FaceBlendShape: Int, CaseIterable {
    // Left Eye
    case eyeBlinkLeft = 0
    case eyeLookDownLeft
    case eyeLookInLeft
    case eyeLookOutLeft
    case eyeLookUpLeft
    case eyeSquintLeft
    case eyeWideLeft
    // Right Eye
    case eyeBlinkRight
    case eyeLookDownRight
    case eyeLookInRight
    case eyeLookOutRight
    case eyeLookUpRight
    case eyeSquintRight
    case eyeWideRight
    // Mouth and Jaw
    case jawForward
    case jawLeft
    case jawRight
    case jawOpen
    case mouthClose
    case mouthFunnel
    case mouthPucker
    case mouthLeft
    case mouthRight
    case mouthSmileLeft
    case mouthSmileRight
    case mouthFrownLeft
    case mouthFrownRight
    case mouthDimpleLeft
    case mouthDimpleRight
    case mouthStretchLeft
    case mouthStretchRight
    case mouthRollLower
    case mouthRollUpper
    case mouthShrugLower
    case mouthShrugUpper
    case mouthPressLeft
    case mouthPressRight
    case mouthLowerDownLeft
    case mouthLowerDownRight
    case mouthUpperUpLeft
    case mouthUpperUpRight
    // Eyebrows, CHeeks, and Nose
    case browDownLeft
    case browDownRight
    case browInnerUp
    case browOuterUpLeft
    case browOuterUpRight
    case cheekPuff
    case cheekSquintLeft
    case cheekSquintRight
    case noseSneerLeft
    case noseSneerRight
    // Tongue
    case tongueOut
    // head
    case headRoll
    case headPitch
    case headYaw
}
