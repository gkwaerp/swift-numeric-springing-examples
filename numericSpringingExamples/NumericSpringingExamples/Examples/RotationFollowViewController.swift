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
        let springAngle = self.getAngle(from: location, to: self.springRotateView)
        let directAngle = self.getAngle(from: location, to: self.directRotateView)
        
        self.spring.updateTargetValue(springAngle)
        self.directRotateView.transform = CGAffineTransform(rotationAngle: directAngle)
    }
    
    // TODO: Has issues when crossing 0 -- doesn't take shortest route.
    private func getAngle(from position: CGPoint, to view: UIView) -> CGFloat {
        let offset = CGPoint(x: view.center.x - position.x, y: view.center.y - position.y)
        // Offset by 45 since the corner of the box is pointing towards the location.
        let angleOffset: CGFloat = -45.0 / 180 * CGFloat.pi
        let angle = atan2(offset.y, offset.x) + angleOffset
        
        return angle
    }
}
