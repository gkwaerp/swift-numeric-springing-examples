//
//  CGShapeLayerViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 07/03/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit
import NumericSpringing

class CAShapeLayerViewController: UIViewController {
    private let shapeLayer = CAShapeLayer()
    private let startingLineWidth: CGFloat = 40
    private let radius: CGFloat = 80
    private var spring: Spring<CGFloat>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.configureShapeLayer()
        self.createSpring()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
    }
    
    private func configureShapeLayer() {
        let size = self.radius * 2
        
        self.shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size, height: size), cornerRadius: self.radius).cgPath
        self.shapeLayer.position = CGPoint(x: self.view.frame.midX - self.radius, y: self.view.frame.midY - self.radius)
        self.shapeLayer.fillColor = UIColor.systemGray.cgColor
        self.shapeLayer.strokeColor = UIColor.systemGray2.cgColor
//        self.shapeLayer.fillRule = .nonZero
        self.shapeLayer.lineWidth = startingLineWidth
        self.view.layer.addSublayer(self.shapeLayer)
    }
    
    private func createSpring() {
        self.spring = .createBasicSpring(startValue: startingLineWidth, animationClosure: { [weak self] (animationValue) in
            guard let self = self else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.shapeLayer.lineWidth = animationValue
            CATransaction.commit()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.handleTouch(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.handleTouch(touch)
    }
    
    private func handleTouch(_ touch: UITouch) {
        let location = touch.location(in: self.view)
        let x = abs(location.x - self.view.frame.midX)
        let y = abs(location.y - self.view.frame.midY)
        let distance = sqrt(x * x + y * y)
        let newWidth = (distance - self.radius) * 2
        self.spring.updateTargetValue(newWidth)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            self.resetAnim()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            self.resetAnim()
        }
    }
    
    private func resetAnim() {
        self.spring.updateTargetValue(self.startingLineWidth)
    }
}
