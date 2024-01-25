//
//  RigSafer.swift
//  Blendshape2Robot
//
//  Created by Bowen Wu on 2024/01/19.
//

import Foundation

class RigSafer {
    
    func safen_rig(rig: inout [Int], maxValue: Int) {
        var coin: Float = 0.0
        
        // 17, 22, and 23
        coin = Float.random(in: 0.0 ..< 1.0)
        if coin < 0.5 {
            rig[16] = 0
            rig[21] = 0
        } else {
            rig[22] = 0
        }

        // 16, 18 and 19
        coin = Float.random(in: 0.0 ..< 1.0)
        if coin < 0.5 {
            rig[15] = 0
            rig[17] = 0
        } else {
            rig[18] = 0
        }

        // 12 and 13
        coin = Float.random(in: 0.0 ..< 1.0)
        if coin < 0.5 {
            rig[11] = 0
        } else {
            rig[12] = 0
        }

        // 8 and 9
        coin = Float.random(in: 0.0 ..< 1.0)
        if coin < 0.5 {
            rig[7] = 0
        } else {
            rig[8] = 0
        }

        // 26 and 16, 17, 20, 24, 19, 23, 18, 22
        coin = Float.random(in: 0.0 ..< 1.0)
        if coin < 0.5 {
            rig[25] = 0
        } else {
            rig[15] = 0
            rig[16] = 0
            rig[19] = 0
            rig[23] = 0
            rig[18] = 0
            rig[22] = 0
            rig[17] = 0
            rig[21] = 0
        }

        // 27 and 16, 17, 20, 24, 18, 22
        coin = Float.random(in: 0.0 ..< 1.0)
        if coin < 0.5 {
            rig[26] = 0
        } else {
            rig[15] = 0
            rig[16] = 0
            rig[19] = 0
            rig[23] = 0
            rig[18] = 0
            rig[22] = 0
            rig[17] = 0
            rig[21] = 0
        }

        // 29 and 18, 22
        coin = Float.random(in: 0.0 ..< 1.0)
        if coin < 0.5 {
            rig[28] = 0
        } else {
            rig[17] = 0
            rig[21] = 0
        }

        // 28 and 19, 23
        coin = Float.random(in: 0.0 ..< 1.0)
        if coin < 0.5 {
            rig[27] = 0
        } else {
            rig[18] = 0
            rig[22] = 0
        }
    }
}
