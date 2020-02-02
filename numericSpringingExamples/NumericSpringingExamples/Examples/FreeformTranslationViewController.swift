//
//  FreeformTranslationViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 02/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit
import NumericSpringing

class FreeformTranslationViewController: UIViewController {
    private var spring: Spring<CGPoint>!
    private var movingView: UIView!
    private var targetPoint: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.createSpring()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
        
        self.movingView = UIView()
        self.movingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.movingView)
        self.movingView.backgroundColor = .systemPurple
        
        let viewSize: CGFloat = 80
        NSLayoutConstraint.activate([self.movingView.widthAnchor.constraint(equalToConstant: viewSize),
                                     self.movingView.heightAnchor.constraint(equalTo: self.movingView.widthAnchor, multiplier: 1)])
        self.movingView.layer.cornerRadius = viewSize / 4
    }
    
    private func createSpring() {
        self.spring = .createBasicSpring(startValue: self.view.center, animationClosure: { [weak self] (animationValue) in
            self?.movingView.center = animationValue
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
        self.spring.updateTargetValue(location)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.movingView.center = self.view.center
        self.spring.updateCurrentValue(self.view.center)
    }
}
