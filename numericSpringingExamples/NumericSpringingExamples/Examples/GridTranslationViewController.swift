//
//  GridTranslationViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 02/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit
import NumericSpringing

class GridTranslationViewController: UIViewController {
    private var buttons: [UIButton] = []
    private var movingView: UIView!
    private var spring: Spring<CGPoint>!
    private var selectedButtonIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.createSpring()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
        
        let mainStackView = UIStackView()
        mainStackView.distribution = .fillEqually
        mainStackView.axis = .vertical
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([mainStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     mainStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     mainStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                                     mainStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)])
        
        let numColumns = 5
        let numRows = 5
        for y in 0..<numRows {
            let horizontalStackView = UIStackView()
            horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
            horizontalStackView.distribution = .fillEqually
            horizontalStackView.axis = .horizontal
            mainStackView.addArrangedSubview(horizontalStackView)
            
            for x in 0..<numColumns {
                let button = UIButton(type: .system)
                button.translatesAutoresizingMaskIntoConstraints = false
                horizontalStackView.addArrangedSubview(button)
                let buttonIndex = y * numRows + x
                button.setTitle("Here", for: .normal)
                button.tag = buttonIndex
                button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
                self.buttons.append(button)
            }
        }
        
        self.movingView = UIView()
        self.movingView.translatesAutoresizingMaskIntoConstraints = false
        self.movingView.backgroundColor = .systemTeal
        self.view.addSubview(self.movingView)
        let viewSize: CGFloat = 72
        self.movingView.layer.cornerRadius = viewSize / 4
        NSLayoutConstraint.activate([self.movingView.widthAnchor.constraint(equalToConstant: viewSize),
                                     self.movingView.heightAnchor.constraint(equalTo: self.movingView.widthAnchor, multiplier: 1)])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.movingView.center = self.currentTargetPoint
        self.spring.updateCurrentValue(self.currentTargetPoint)
    }
    
    private func createSpring() {
        self.spring = .createCustomSpring(startValue: self.currentTargetPoint,
                                          oscillationFrequency: 2.4,
                                          halfLife: 0.1,
                                          animationClosure: { [weak self] (animationValue) in
                                            self?.movingView.center = animationValue
            }, completion: nil)
    }
    
    private var currentTargetPoint: CGPoint {
        let currentButton = self.buttons[self.selectedButtonIndex]
        return currentButton.superview!.convert(currentButton.center, to: self.view)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        self.selectedButtonIndex = sender.tag
        self.spring.updateTargetValue(self.currentTargetPoint)
    }
}
