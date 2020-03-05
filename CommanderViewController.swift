//
//  CommanderViewController.swift
//  testing
//
//  Created by Faraz on 3/5/20.
//  Copyright © 2020 Anthrax.inc. All rights reserved.
//
import UIKit
import SceneKit
import ARKit

class CommanderViewController:UIViewController,ARSCNViewDelegate{
    
    @IBOutlet var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
            // Set the view's delegate
            sceneView.delegate = self
            
            sceneView.autoenablesDefaultLighting = true
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
        
         // Create a session configuration
         let configuration = ARWorldTrackingConfiguration()
         
         print("World tracking is supported = \(ARWorldTrackingConfiguration.isSupported)")
         // Run the view's session
         configuration.planeDetection = .horizontal
         sceneView.session.run(configuration)
         
     }
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         // Pause the view's session
         sceneView.session.pause()
     }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
           
           if anchor is ARPlaneAnchor {
               let planeAnchor = anchor as! ARPlaneAnchor
               let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
               
               let planeNode=SCNNode()
               planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
               planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
               let gridMaterial = SCNMaterial()
               gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/8.1 grid.png.png")
               
               plane.materials = [gridMaterial]
               planeNode.geometry = plane
               
                node.addChildNode(planeNode)
               
               
           }
           else {
               return
           }
       }
    
    
    
    
}
