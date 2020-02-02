//
//  VerticalBarViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 02/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit
import NumericSpringing

class VerticalBarViewController: UIViewController {
    private var springBar: UIView!
    private var springHeightConstraint: NSLayoutConstraint!
    private var directBar: UIView!
    private var directHeightConstraint: NSLayoutConstraint!
    private var spring: Spring<CGFloat>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.createSpring()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.distribution = .fillEqually
        
        self.springBar = UIView()
        self.springBar.translatesAutoresizingMaskIntoConstraints = false
        self.springBar.backgroundColor = .systemBlue
        self.springHeightConstraint = self.springBar.heightAnchor.constraint(equalToConstant: 20)
        stackView.addArrangedSubview(self.springBar)
        
        self.directBar = UIView()
        self.directBar.translatesAutoresizingMaskIntoConstraints = false
        self.directBar.backgroundColor = .systemYellow
        self.directHeightConstraint = self.directBar.heightAnchor.constraint(equalToConstant: 20)
        stackView.addArrangedSubview(self.directBar)
        
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                                     self.springHeightConstraint,
                                     self.directHeightConstraint])
    }
    
    private func createSpring() {
        self.spring = .createBasicSpring(startValue: 20, animationClosure: { [weak self] (animationValue) in
            guard let self = self else { return }
            var newHeight = animationValue
            newHeight = max(newHeight, 0)
            newHeight = min(newHeight, self.view.frame.height)
            self.springHeightConstraint.constant = newHeight
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
        let height = self.view.frame.height - location.y
        self.spring.updateTargetValue(height)
        self.directHeightConstraint.constant = height
    }
}
