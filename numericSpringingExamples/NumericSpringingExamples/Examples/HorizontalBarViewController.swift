//
//  HorizontalBarViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 02/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit
import NumericSpringing

class HorizontalBarViewController: UIViewController {
    private var springBar: UIView!
    private var springWidthConstraint: NSLayoutConstraint!
    private var directBar: UIView!
    private var directWidthConstraint: NSLayoutConstraint!
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
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        
        self.springBar = UIView()
        self.springBar.translatesAutoresizingMaskIntoConstraints = false
        self.springBar.backgroundColor = .systemBlue
        self.springWidthConstraint = self.springBar.widthAnchor.constraint(equalToConstant: 20)
        stackView.addArrangedSubview(self.springBar)
        
        self.directBar = UIView()
        self.directBar.translatesAutoresizingMaskIntoConstraints = false
        self.directBar.backgroundColor = .systemYellow
        self.directWidthConstraint = self.directBar.widthAnchor.constraint(equalToConstant: 20)
        stackView.addArrangedSubview(self.directBar)
        
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                                     self.springWidthConstraint,
                                     self.directWidthConstraint])
    }
    
    private func createSpring() {
        self.spring = .createBasicSpring(startValue: 20, animationClosure: { [weak self] (animationValue) in
            guard let self = self else { return }
            var newWidth = animationValue
            newWidth = max(newWidth, 0)
            newWidth = min(newWidth, self.view.frame.width)
            self.springWidthConstraint.constant = newWidth
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
        let width = location.x
        self.spring.updateTargetValue(width)
        self.directWidthConstraint.constant = width
    }
}
