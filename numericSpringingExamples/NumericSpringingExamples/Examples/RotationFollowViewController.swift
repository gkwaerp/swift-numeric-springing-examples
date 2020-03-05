//
//  RotationFollowViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 03/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit
import NumericSpringing

class RotationFollowViewController: UIViewController {
    private var springRotateView: UIView!
    private var spring: Spring<CGFloat>!
    private var directRotateView: UIView!
    
    private lazy var targetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        self.view.addSubview(view)
        let size: CGFloat = 20
        NSLayoutConstraint.activate([view.widthAnchor.constraint(equalToConstant: size),
                                     view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)])
        view.layer.cornerRadius = size / 2
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.createSpring()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
        self.springRotateView = self.createView()
        self.directRotateView = self.createView()
        
        self.springRotateView.backgroundColor = .systemRed
        self.directRotateView.backgroundColor = .systemBlue
        
        let offset = self.view.frame.width / 4
        NSLayoutConstraint.activate([self.springRotateView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -offset),
                                     self.directRotateView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: offset)])
    }
    
    private func createView() -> UIView {
        let newView = UIView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(newView)
        
        let viewSize: CGFloat = 92
        NSLayoutConstraint.activate([newView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                                     newView.widthAnchor.constraint(equalToConstant: viewSize),
                                     newView.heightAnchor.constraint(equalTo: newView.widthAnchor, multiplier: 1)])
        
        newView.layer.cornerRadius = viewSize / 2
        newView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        return newView
    }
    
    private func createSpring() {
        self.spring = .createBasicSpring(startValue: 0, animationClosure: { [weak self] (animationValue) in
            self?.springRotateView.transform = CGAffineTransform(rotationAngle: animationValue)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.handleTouch(touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.handleTouch(touch)
        }
    }
    
    private func handleTouch(_ touch: UITouch) {
        let location = touch.location(in: self.view)
        self.targetView.center = location
        
        // Offset by 1/4 since the corner of the 'box' is pointing towards the touch location.
        let angleOffset = -CGFloat.pi / 4
        let springAngle = self.getAngle(from: self.springRotateView, to: location, angleOffset: angleOffset)
        let directAngle = self.getAngle(from: self.directRotateView, to: location, angleOffset: angleOffset)
        
        self.updateSpringAngle(to: springAngle)
        self.directRotateView.transform = CGAffineTransform(rotationAngle: directAngle)
    }
    
    private func getAngle(from view: UIView, to position: CGPoint, angleOffset: CGFloat) -> CGFloat {
        let delta = CGPoint(x: view.center.x - position.x, y: view.center.y - position.y)
        return self.clampAngle(atan2(delta.y, delta.x) + angleOffset)
    }
    
    private func updateSpringAngle(to originalTargetAngle: CGFloat) {
        let pi2 = CGFloat.pi * 2
        let clampedAngle = self.clampAngle(self.spring.currentValue)
        self.spring.updateCurrentValue(clampedAngle)
        
        let bestAngle = [0.0, pi2, -pi2].map { (offset) -> (targetAngle: CGFloat, delta: CGFloat) in
            let targetAngle = originalTargetAngle + offset
            let delta = abs(clampedAngle - targetAngle)
            return (targetAngle: targetAngle, delta: delta)
            }.sorted(by: {$0.delta < $1.delta})
            .first!
            .targetAngle
        
        self.spring.updateTargetValue(bestAngle)
    }
    
    private func clampAngle(_ angle: CGFloat) -> CGFloat {
        let pi2 = CGFloat.pi * 2
        var adjustedAngle = angle
        if adjustedAngle < -CGFloat.pi {
            let numRevolutions = Int(abs(adjustedAngle) / pi2) + 1
            adjustedAngle += CGFloat(numRevolutions) * pi2
        } else if adjustedAngle > CGFloat.pi {
            let numRevolutions = Int(adjustedAngle / pi2) + 1
            adjustedAngle -= CGFloat(numRevolutions) * pi2
        }
        return adjustedAngle
    }
}
