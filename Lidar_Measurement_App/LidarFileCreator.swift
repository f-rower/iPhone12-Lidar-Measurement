//
//  filecreator.swift
//  Lidar_Measurement_App_2
//
//  Created by Maisha Mohamed on 26/02/2021.
//

import Foundation
import UIKit
import ARKit

final class LidarFileCreator {
    private let session: ARSession
    
    init(session: ARSession)
    {
        self.session = session
        guard let currentFrame = session.currentFrame
        else {
            print("this is empty")
            return //it's just returning! why is this?? is it because I am not enabling ARWorldtracking?
            
        }
        print("\(currentFrame)")
        print("hello")
        updateDepthTextures(frame: currentFrame)
    }
    
    private func updateDepthTextures(frame: ARFrame) -> Bool {
        guard let depthMap = frame.sceneDepth?.depthMap
            //let confidenceMap = frame.sceneDepth?.confidenceMap
        else {
                return false
        }
        print("test")
        return true
    }
    
}
