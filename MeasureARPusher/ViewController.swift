//
//  ViewController.swift
//  MeasureARPusher
//
//  Created by Esteban Herrera on 7/20/17.
//  Copyright © 2017 Esteban Herrera. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PusherSwift

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusTextView: UITextView!
    
    let pusher = Pusher(
        key: "YOUR_PUSHER_APP_KEY",
        options: PusherClientOptions(
            authMethod: .inline(secret: "YOUR_PUSHER_APP_SECRET"),
            host: .cluster("YOUR_PUSHER_APP_CLUSTER")
        )
    )
    var channel: PusherChannel!
    var sendingTime : TimeInterval = 0
    
    var box: Box!
    var status: String!
    var startPosition: SCNVector3!
    var distance: Float!
    var trackingState: ARCamera.TrackingState!
    
    enum Mode {
        case waitingForMeasuring
        case measuring
    }
    
    
    var mode: Mode = .waitingForMeasuring {
        didSet {
            switch mode {
            case .waitingForMeasuring:
                status = "NOT READY"
            case .measuring:
                box.update(minExtents: SCNVector3Zero, maxExtents: SCNVector3Zero)
                box.isHidden = false
                startPosition = nil
                distance = 0.0
                setStatusText()
            }
        }
    }
    
    
    func setStatusText() {
        var text = "Status: \(status!)\n"
        text += "Tracking: \(getTrackigDescription())\n"
        text += "Distance: \(String(format: "%.2f cm", distance! * 100.0))"
        statusTextView.text = text
    }
    
    func getTrackigDescription() -> String {
        var description = ""
        if let t = trackingState {
            switch(t) {
            case .notAvailable:
                description = "TRACKING UNAVAILABLE"
            case .normal:
                description = "TRACKING NORMAL"
            case .limited(let reason):
                switch reason {
                case .excessiveMotion:
                    description = "TRACKING LIMITED - Too much camera movement"
                case .insufficientFeatures:
                    description = "TRACKING LIMITED - Not enough surface detail"
                case .initializing:
                    description = "INITIALIZING"
                }
            }
        }
        
        return description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Set a padding in the text view
        statusTextView.textContainerInset = UIEdgeInsetsMake(20.0, 10.0, 10.0, 0.0)
        
        // Instantiate the box and add it to the scene
        box = Box()
        box.isHidden = true;
        sceneView.scene.rootNode.addChildNode(box)
        
        // Set the initial mode
        mode = .waitingForMeasuring
        
        // Set the initial distance
        distance = 0.0
        
        // Display the initial status
        setStatusText()
        
        // subscribe to channel and connect
        channel = pusher.subscribe("private-channel")
        pusher.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration with plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Call the method asynchronously to perform
        //  this heavy task without slowing down the UI
        DispatchQueue.main.async {
            self.measure(time: time)
        }
    }
    
    func measure(time: TimeInterval) {
        let screenCenter : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        let planeTestResults = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent])
        if let result = planeTestResults.first {
            status = "READY"
            
            if mode == .measuring {
                status = "MEASURING"
                let worldPosition = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                
                if startPosition == nil {
                    startPosition = worldPosition
                    box.position = worldPosition
                }
                
                distance = calculateDistance(from: startPosition!, to: worldPosition)
                box.resizeTo(extent: distance)
                
                let angleInRadians = calculateAngleInRadians(from: startPosition!, to: worldPosition)
                box.rotation = SCNVector4(x: 0, y: 1, z: 0, w: -(angleInRadians + Float.pi))
                
                // Only send the Pusher event after the specified interval
                if time > sendingTime {
                    sendPusherEvent();
                    sendingTime = time + TimeInterval(0.2)
                }
            }
        } else {
            status = "NOT READY"
        }
        setStatusText()
    }
    
    func calculateDistance(from: SCNVector3, to: SCNVector3) -> Float {
        let x = from.x - to.x
        let y = from.y - to.y
        let z = from.z - to.z
        
        return sqrtf( (x * x) + (y * y) + (z * z))
    }
    
    func calculateAngleInRadians(from: SCNVector3, to: SCNVector3) -> Float {
        let x = from.x - to.x
        let z = from.z - to.z
        
        return atan2(z, x)
    }
    
    func sendPusherEvent() {
        channel.trigger(eventName: "client-new-measurement", data: String(format: "%.2f cm", distance * 100.0))
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            mode = .measuring
        } else {
            mode = .waitingForMeasuring
            sendPusherEvent()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

