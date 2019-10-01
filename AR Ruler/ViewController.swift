//
//  ViewController.swift
//  AR Ruler
//
//  Created by June Nam on 9/27/19.
//  Copyright © 2019 Jun Nam. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Set Debug Options
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //clear existing dots on new measure start
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            
            dotNodes.removeAll()
            textNode.removeFromParentNode()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitTestResult = hitTestResults.first {
                addDot(at: hitTestResult)
            }
        }
    }
    
    func addDot(at hitReulst: ARHitTestResult) {
        
        //Create Dot Geometry
        let dotGeometry = SCNSphere(radius: 0.005)
        let redMaterial = SCNMaterial();
        redMaterial.diffuse.contents = UIColor.red
        dotGeometry.materials = [redMaterial]
        //dotGeometry.radius = 0.005
        
        let dotNode = SCNNode(geometry: dotGeometry)
        //dotNode.geometry = dotGeometry
        let location = hitReulst.worldTransform.columns.3
        dotNode.position = SCNVector3(location.x, location.y, location.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let xDiff = start.position.x - end.position.x
        let yDiff = start.position.y - end.position.y
        let zDiff = start.position.z - end.position.z
        
        let distance = sqrt(pow(xDiff, 2) + pow(yDiff, 2) + pow(zDiff, 2))
        
        updateText(text: String(distance), at: end.position)
//        print(start.position)
//        print(end.position)
//        print(distance)
    }
    
    func updateText(text: String, at position: SCNVector3) {
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.03, position.z)
        textNode.scale = SCNVector3(0.0007, 0.0007, 0.0007)
          
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
