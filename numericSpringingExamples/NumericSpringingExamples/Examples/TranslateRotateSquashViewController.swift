//
//  TranslateRotateSquashViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 02/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit
import NumericSpringing

class TranslateRotateSquashViewController: UIViewController {
    private var translateView: UIView!
    private var translateCenterXConstraint: NSLayoutConstraint!
    private var translateSpring: Spring<CGFloat>!
    private var translateToggled = false
    
    private var rotateView: UIView!
    private var rotateSpring: Spring<CGFloat>!
    private var rotateToggled = false
    
    private var squashView: UIView!
    private var squashHeightConstraint: NSLayoutConstraint!
    private var squashWidthConstraint: NSLayoutConstraint!
    private var originalSquashArea: CGFloat = 0
    private var squashSpring: Spring<CGFloat>!
    private var squashToggled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.createSprings()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
        self.title = "Translate, Rotate, Squash"
        
        let viewSize: CGFloat = 90
        
        self.translateView = UIView()
        self.translateView.translatesAutoresizingMaskIntoConstraints = false
        self.translateView.backgroundColor = .systemRed
        self.view.addSubview(self.translateView)
        self.translateView.layer.cornerRadius = viewSize / 4
        self.translateCenterXConstraint = self.translateView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: self.translateXConstant)
        
        NSLayoutConstraint.activate([self.translateCenterXConstraint,
                                     self.translateView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -self.view.frame.height / 3),
                                     self.translateView.widthAnchor.constraint(equalToConstant: viewSize),
                                     self.translateView.heightAnchor.constraint(equalTo: self.translateView.widthAnchor, multiplier: 1)])
        self.translateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.translateViewTapped)))
        
        
        self.rotateView = UIView()
        self.rotateView.translatesAutoresizingMaskIntoConstraints = false
        self.rotateView.backgroundColor = .systemBlue
        self.view.addSubview(self.rotateView)
        self.rotateView.layer.cornerRadius = viewSize / 4
        self.rotateView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        NSLayoutConstraint.activate([self.rotateView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                                     self.rotateView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     self.rotateView.widthAnchor.constraint(equalToConstant: viewSize),
                                     self.rotateView.heightAnchor.constraint(equalTo: self.rotateView.widthAnchor, multiplier: 1)])
        self.rotateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rotateViewTapped)))
        
        self.squashView = UIView()
        self.squashView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.squashView)
        self.squashView.backgroundColor = .systemGreen
        self.squashView.layer.cornerRadius = viewSize / 2
        
        self.squashWidthConstraint = self.squashView.widthAnchor.constraint(equalToConstant: viewSize)
        self.squashHeightConstraint = self.squashView.heightAnchor.constraint(equalToConstant: viewSize)
        self.originalSquashArea = viewSize * viewSize
        NSLayoutConstraint.activate([self.squashView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                     self.squashView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: self.view.frame.height / 3),
                                     self.squashHeightConstraint,
                                     self.squashWidthConstraint])
        self.squashView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.squashViewTapped)))
    }
    
    private var translateXConstant: CGFloat {
        return self.view.frame.width / 4 * (self.translateToggled ? 1 : -1)
    }
    
    @objc func translateViewTapped() {
        self.translateToggled.toggle()
        self.translateSpring.updateTargetValue(self.translateXConstant)
    }
    
    private var rotationValue: CGFloat {
        return self.rotateToggled ? CGFloat.pi / 2 : 0
    }
    
    @objc func rotateViewTapped() {
        self.rotateToggled.toggle()
        self.rotateSpring.updateTargetValue(self.rotationValue)
    }
    
    private var squashHeight: CGFloat {
        return self.squashToggled ? 48 : 90
    }
    
    @objc func squashViewTapped() {
        self.squashToggled.toggle()
        self.squashSpring.updateTargetValue(self.squashHeight)
    }
    
    private func createSprings() {
        self.translateSpring = .createBasicSpring(startValue: self.translateXConstant, animationClosure: { [weak self] (animationValue) in
            self?.translateCenterXConstraint.constant = animationValue
        })
        
        self.rotateSpring = .createBasicSpring(startValue: self.rotationValue, animationClosure: { [weak self] (animationValue) in
            self?.rotateView.transform = CGAffineTransform(rotationAngle: animationValue)
        })
        
        self.squashSpring = .createBasicSpring(startValue: self.squashHeight, animationClosure: { [weak self] (animationValue) in
            guard let self = self else { return }
            self.squashHeightConstraint.constant = animationValue
            self.squashWidthConstraint.constant = self.originalSquashArea / self.squashHeightConstraint.constant
            let minConstant = min(self.squashHeightConstraint.constant, self.squashWidthConstraint.constant)
            self.squashView.layer.cornerRadius = minConstant / 2
        })
    }
}
