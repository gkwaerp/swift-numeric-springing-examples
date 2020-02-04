//
//  LottieAnimationViewController.swift
//  NumericSpringingExamples
//
//  Created by Geir-Kåre S. Wærp on 04/02/2020.
//  Copyright © 2020 GK. All rights reserved.
//

import UIKit
import NumericSpringing
import Lottie

class LottieAnimationViewController: UIViewController {
    private var sliderBarView: UIView!
    private var sliderKnobView: UIView!
    private var isDragging = false
    
    private let horizontalPadding: CGFloat = 32
    private let sliderKnobSize: CGFloat = 32
    private var knobHorizontalConstraint: NSLayoutConstraint!
    
    private var animationView = AnimationView(name: "radialMeter")
    private var spring: Spring<CGFloat>!
    
    private var sliceLabel: UILabel!
    
    private var numSlices = 1 {
        didSet {
            self.numSlices = max(1, self.numSlices)
            self.numSlices = min(10, self.numSlices)
        }
    }
    
    private var currentSlice = 0 {
        didSet {
            self.currentSlice = min(self.currentSlice, self.numSlices)
            self.currentSlice = max(0, self.currentSlice)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.createSpring()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .systemBackground
        
        self.createLabel()
        self.createSlider()
        self.configureLottieView()
        self.createSliceControls()
    }
    
    private func createLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = """
        Radial Meter by Aaron Cecchini-Butler
        https://lottiefiles.com/14941-radial-meter
        """
        
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                                     label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                                     label.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -32)])
    }
    
    private func createSlider() {
        let sliderBarHeight: CGFloat = 6
        self.sliderBarView = UIView()
        self.sliderBarView.backgroundColor = .systemGray
        self.sliderBarView.translatesAutoresizingMaskIntoConstraints = false
        self.sliderBarView.layer.cornerRadius = sliderBarHeight / 2
        self.view.addSubview(self.sliderBarView)
        
        let verticalPadding: CGFloat = 132
        NSLayoutConstraint.activate([self.sliderBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.horizontalPadding),
                                     self.sliderBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.horizontalPadding),
                                     self.sliderBarView.heightAnchor.constraint(equalToConstant: sliderBarHeight),
                                     self.sliderBarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -verticalPadding)])
        
        
        self.sliderKnobView = UIView()
        self.sliderKnobView.translatesAutoresizingMaskIntoConstraints = false
        self.sliderKnobView.backgroundColor = .systemPurple
        self.sliderKnobView.layer.cornerRadius = self.sliderKnobSize / 2
        self.view.addSubview(self.sliderKnobView)
        
        self.knobHorizontalConstraint = self.sliderKnobView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
                                                                                     constant: self.getHorizontalConstant(for: 0))
        
        NSLayoutConstraint.activate([self.sliderKnobView.centerYAnchor.constraint(equalTo: self.sliderBarView.centerYAnchor),
                                     self.sliderKnobView.heightAnchor.constraint(equalToConstant: self.sliderKnobSize),
                                     self.sliderKnobView.widthAnchor.constraint(equalTo: self.sliderKnobView.heightAnchor, multiplier: 1),
                                     self.knobHorizontalConstraint])
    }
    
    private func configureLottieView() {
        self.animationView.translatesAutoresizingMaskIntoConstraints = false
        self.animationView.loopMode = .loop
        self.view.addSubview(self.animationView)
        
        NSLayoutConstraint.activate([self.animationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                                     self.animationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 16),
                                     self.animationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100)])
    }
    
    private func createSliceControls() {
        self.sliceLabel = UILabel()
        self.sliceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.sliceLabel.textColor = .label
        self.updateSliceLabel()
        
        let mainStackView = self.createStackView()
        mainStackView.axis = .vertical
        
        self.view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(self.sliceLabel)
        
        for stackViewIndex in 0...1 {
            let stackView = self.createStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            mainStackView.addArrangedSubview(stackView)
            
            let label = UILabel()
            label.textColor = .label
            label.text = stackViewIndex == 1 ? "Current slice" : "Num slices   "
            stackView.addArrangedSubview(label)
            for buttonIndex in 0...1 {
                let button = UIButton(type: .system)
                button.setTitle(buttonIndex == 0 ? "-" : "+", for: .normal)
                button.tag = (buttonIndex == 0) ? -1 : 1
                if stackViewIndex == 1 {
                    button.addTarget(self, action: #selector(self.currentSliceButtonPressed(_:)), for: .touchUpInside)
                } else {
                    button.addTarget(self, action: #selector(self.numSliceButtonPressed(_:)), for: .touchUpInside)
                }
                stackView.addArrangedSubview(button)
            }
        }
        
        let jumpButton = UIButton(type: .system)
        jumpButton.setTitle("JUMP!", for: .normal)
        jumpButton.addTarget(self, action: #selector(self.goToSliceBasedProgress), for: .touchUpInside)
        mainStackView.addArrangedSubview(jumpButton)
        
        let playButton = UIButton(type: .system)
        playButton.setTitle("Play normally", for: .normal)
        playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        mainStackView.addArrangedSubview(playButton)
        
        NSLayoutConstraint.activate([mainStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                                     mainStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 20),
                                     mainStackView.topAnchor.constraint(equalTo: self.animationView.bottomAnchor, constant: 30)])
    }
    
    private func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }
    
    @objc private func currentSliceButtonPressed(_ button: UIButton) {
        self.currentSlice += button.tag
        self.updateSliceLabel()
    }
    
    @objc private func numSliceButtonPressed(_ button: UIButton) {
        self.numSlices += button.tag
        self.updateSliceLabel()
    }
    
    private func updateSliceLabel() {
        self.sliceLabel.text = "\(self.currentSlice) / \(self.numSlices)"
    }
    
    @objc private func goToSliceBasedProgress() {
        let progress = CGFloat(self.currentSlice) / CGFloat(self.numSlices)
        self.spring.updateTargetValue(progress)
        self.knobHorizontalConstraint.constant = self.getHorizontalConstant(for: progress)
    }
    
    @objc private func playButtonPressed() {
        self.spring.stop()
        self.animationView.play()
    }
    
    private var sliderBarWidth: CGFloat {
        return self.view.frame.width - (2 * self.horizontalPadding)
    }
    
    private func getHorizontalConstant(for progress: CGFloat) -> CGFloat {
        return progress * self.sliderBarWidth + self.horizontalPadding - self.sliderKnobSize / 2
    }
    
    private func updateKnobPosition(for progress: CGFloat) {
        self.knobHorizontalConstraint.constant = self.getHorizontalConstant(for: progress)
    }
    
    private func createSpring() {
        self.spring = .createBasicSpring(startValue: 0, animationClosure: { [weak self] (animationValue) in
            guard let self = self else { return }
            var progress = animationValue
            progress = max(0, progress)
            progress = min(1, progress)
            
            self.animationView.currentProgress = progress
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, !self.isDragging {
            let location = touch.location(in: self.view)
            if self.sliderKnobView.frame.contains(location) {
                self.isDragging = true
                self.updateSlider(from: location)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, self.isDragging {
            let location = touch.location(in: self.view)
            self.updateSlider(from: location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDragging = false
    }
    
    private func updateSlider(from position: CGPoint) {
        let xPos = position.x
        var progress = (xPos - self.horizontalPadding) / self.sliderBarWidth
        progress = min(progress, 1)
        progress = max(progress, 0)
        
        self.spring.updateTargetValue(progress)
        self.updateKnobPosition(for: progress)
    }
}
