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
    
    private var progressTargetLabel: UILabel!
    
    private let maxProgressSlices = 10
    
    private var displayLink: CADisplayLink?
    
    private var progressTarget = 0 {
        didSet {
            self.progressTarget = max(0, self.progressTarget)
            self.progressTarget = min(maxProgressSlices, self.progressTarget)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.createSpring()
        self.displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkUpdate))
        self.displayLink?.add(to: .current, forMode: .default)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.animationView.pause()
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    deinit {
        self.displayLink?.invalidate()
        self.displayLink = nil
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
        self.progressTargetLabel = UILabel()
        self.progressTargetLabel.translatesAutoresizingMaskIntoConstraints = false
        self.progressTargetLabel.textColor = .label
        self.updateProgressTargetLabel()
        
        let mainStackView = self.createStackView()
        mainStackView.axis = .vertical
        
        self.view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(self.progressTargetLabel)
        
        let stackView = self.createStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        mainStackView.addArrangedSubview(stackView)
        
        let progressPerTap = Int(1.0 / Double(self.maxProgressSlices) * 100)
        for buttonIndex in 0...1 {
            let button = UIButton(type: .system)
            button.setTitle(buttonIndex == 0 ? "- \(progressPerTap)%" : "+ \(progressPerTap)%", for: .normal)
            button.tag = (buttonIndex == 0) ? -1 : 1
            button.addTarget(self, action: #selector(self.adjustProgressButtonTapped), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        let jumpButton = UIButton(type: .system)
        jumpButton.setTitle("Jump", for: .normal)
        jumpButton.addTarget(self, action: #selector(self.jumpToSlicedBasedProgress), for: .touchUpInside)
        mainStackView.addArrangedSubview(jumpButton)
        
        let scrubButton = UIButton(type: .system)
        scrubButton.setTitle("Scrub", for: .normal)
        scrubButton.addTarget(self, action: #selector(self.scrubToSliceBasedProgress), for: .touchUpInside)
        mainStackView.addArrangedSubview(scrubButton)
        
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
    
    @objc private func adjustProgressButtonTapped(_ button: UIButton) {
        self.progressTarget += button.tag
        self.updateProgressTargetLabel()
    }
    
    private func updateProgressTargetLabel() {
        self.progressTargetLabel.text = "\(Int(self.sliceProgress * 100))%"
    }
    
    private var sliceProgress: CGFloat {
        return CGFloat(self.progressTarget) / CGFloat(self.maxProgressSlices)
    }
    
    @objc private func displayLinkUpdate() {
        if self.animationView.isAnimationPlaying {
            self.updateKnobPosition(for: self.animationView.realtimeAnimationProgress)
        }
    }
    
    @objc private func scrubToSliceBasedProgress() {
        if self.animationView.isAnimationPlaying {
            self.spring.updateCurrentValue(self.animationView.realtimeAnimationProgress)
        }
        let progress = self.sliceProgress
        self.spring.updateTargetValue(progress)
        self.updateKnobPosition(for: progress)
    }
    
    @objc private func jumpToSlicedBasedProgress() {
        let progress = self.sliceProgress
        self.spring.updateCurrentValue(progress)
        self.spring.stop()
        self.animationView.currentProgress = progress
        self.updateKnobPosition(for: progress)
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
        
        if self.animationView.isAnimationPlaying {
            self.spring.updateCurrentValue(self.animationView.realtimeAnimationProgress)
        }
        self.spring.updateTargetValue(progress)
        self.updateKnobPosition(for: progress)
    }
}
