//
//  SceneKitRotationViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 02/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit
import SceneKit
import NumericSpringing

class SceneKitRotationViewController: UIViewController {
    private var sceneView: SCNView!
    private var boxNode: SCNNode!

    private var spring: Spring<Double>!
    private var touchPos: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupScene()
        self.createSpring()
    }

    private func setupScene() {
        self.sceneView = SCNView()
        self.sceneView.scene = SCNScene()
        self.sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.sceneView)

        NSLayoutConstraint.activate([self.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     self.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)])

        let ground = self.setupGround()
        self.setupCamera(lookAt: ground)
        self.setupBox()
    }

    private func setupGround() -> SCNNode {
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.gray
        groundGeometry.materials = [groundMaterial]

        let ground = SCNNode(geometry: groundGeometry)
        self.sceneView.scene?.rootNode.addChildNode(ground)

        return ground
    }

    private func setupCamera(lookAt: SCNNode) {
        let camera = SCNCamera()
        camera.zFar = 1000
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: -20, y: 15, z: 20)
        let constraint = SCNLookAtConstraint(target: lookAt)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]

        self.sceneView.scene?.rootNode.addChildNode(cameraNode)
        self.createLight(camera: cameraNode)
    }

    private func createLight(camera: SCNNode) {
        let ambientLight = SCNLight()
        ambientLight.color = UIColor.darkGray
        ambientLight.type = SCNLight.LightType.ambient
        camera.light = ambientLight

        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.spot
        spotLight.castsShadow = true
        spotLight.spotInnerAngle = 70.0
        spotLight.spotOuterAngle = 90.0
        spotLight.zFar = 500

        let lightNode = SCNNode()
        lightNode.light = spotLight
        lightNode.position = SCNVector3(x: 0, y: 25, z: 25)
        lightNode.constraints = camera.constraints

        self.sceneView.scene?.rootNode.addChildNode(lightNode)
    }

    private func setupBox() {
        let height: CGFloat = 5
        let boxGeometry = SCNBox(width: 6, height: height, length: 6, chamferRadius: 0.1)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor.red
        boxGeometry.materials = [boxMaterial]
        self.boxNode = SCNNode(geometry: boxGeometry)
        self.boxNode.position = SCNVector3(0, height / 2, 0)

        self.sceneView.scene?.rootNode.addChildNode(self.boxNode)
    }
    
    private func createSpring() {
        self.spring = .createBasicSpring(startValue: 0, animationClosure: { [weak self] (springValue) in
            guard let self = self else { return }
            let rotation = SCNVector4(0, 1, 0, springValue)
            self.boxNode.rotation = rotation
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self.sceneView)
            self.touchPos = location
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let originalPos = self.touchPos {
            let location = touch.location(in: self.sceneView)
            let delta = location.x - originalPos.x
            let transformedValue = Double(delta / 175)
            self.spring.updateTargetValue(transformedValue, startIfPaused: true)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchPos = nil
        self.spring.updateTargetValue(0, startIfPaused: true)
    }
}

