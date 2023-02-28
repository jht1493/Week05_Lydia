//
//  ViewController.swift
//  ARkitTest
//
//  Created by ldy on 2/22/23.
//
//https://www.appcoda.com/arkit-face-tracking/

import UIKit
import SceneKit
import ARKit
import AVFoundation

func loadUrlAudio(_ urlString:String) -> AVAudioPlayer? {
    let url = URL(string: urlString)
    do {
        let data = try Data(contentsOf: url!)
        return try AVAudioPlayer(data: data)
    } catch {
        print("loadUrlSound error", error)
    }
    return nil
}

let urlSounds = [
    "https://www.youraccompanist.com/images/stories/Reference%20Scales_On%20A%20Flat-G%20Sharp.mp3",
    "https://www.youraccompanist.com/images/stories/Reference%20Scales_Pentatonic%20on%20F%20Sharp.mp3",
    "https://www.youraccompanist.com/images/stories/Reference%20Scales_Chromatic%20Scale%20On%20F%20Sharp.mp3",
]

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var analysis = ""
    var player: AVAudioPlayer? = nil

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var faceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelView.layer.cornerRadius = 10
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        guard ARFaceTrackingConfiguration.isSupported else{
            fatalError("Face Tracking is not supported on this device")
        }
        
        // Set the view's delegate
//        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
                    
            DispatchQueue.main.async {
                self.faceLabel.text = self.analysis
            }
        }
    }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func expression(anchor: ARFaceAnchor) {
        // 1
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let tongue = anchor.blendShapes[.tongueOut]
        self.analysis = ""
     
        // 2
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            self.analysis += "You are smiling. "
            self.player = loadUrlAudio(urlSounds[0])
            print("player", player as Any)
            // Loop indefinitely
            self.player?.numberOfLoops = -1
            self.player?.play()
        }
     
        if cheekPuff?.decimalValue ?? 0.0 > 0.1 {
            self.analysis += "Your cheeks are puffed. "
            self.player = loadUrlAudio(urlSounds[1])
            print("player", player as Any)
            // Loop indefinitely
            self.player?.numberOfLoops = -1
            self.player?.play()
        }
     
        if tongue?.decimalValue ?? 0.0 > 0.1 {
            self.analysis += "Don't stick your tongue out! "
            self.player = loadUrlAudio(urlSounds[2])
            print("player", player as Any)
            // Loop indefinitely
            self.player?.numberOfLoops = -1
            self.player?.play()
        }
    }

}

