//
//  LoadingView.swift
//  Binge
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class LoadingView: NSView {

    override init(frame: NSRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private let backgroundView: NSVisualEffectView = {
        let v = NSVisualEffectView(frame: NSZeroRect)
        
        v.material = .UltraDark
        v.blendingMode = .WithinWindow
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private let progressIndicator: NSProgressIndicator = {
        let pi = NSProgressIndicator()
        
        pi.indeterminate = true
        pi.controlSize = .RegularControlSize
        pi.translatesAutoresizingMaskIntoConstraints = false
        pi.style = .SpinningStyle
        pi.appearance = NSAppearance(named: "BingeProgressIndicator")
        pi.sizeToFit()
        
        return pi
    }()
    
    private func commonInit() {
        wantsLayer = true
        
        backgroundView.alphaValue = 0.0
        backgroundView.frame = bounds
        addSubview(backgroundView)
        backgroundView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        backgroundView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        backgroundView.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        backgroundView.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        
        addSubview(progressIndicator)
        progressIndicator.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        progressIndicator.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    }
    
    private var isVisible = false
    
    private var loadingTimer: NSTimer!
    
    private func resetLoadingTimer() {
        if loadingTimer != nil {
            loadingTimer.invalidate()
            loadingTimer = nil
        }
        
        loadingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(loadingTimerAction), userInfo: nil, repeats: false)
    }
    
    @objc private func loadingTimerAction() {
        if isVisible {
            showBackground()
        } else {
            resetLoadingTimer()
        }
    }
    
    func show() {
        guard !isVisible else { return }
        isVisible = true
        
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.5
            self.progressIndicator.startAnimation(self)
            self.progressIndicator.animator().alphaValue = 1.0
            }, completionHandler: {
                self.resetLoadingTimer()
        })
        
    }
    
    func hide() {
        guard isVisible else { return }
        isVisible = false
        
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.5
            self.hideBackground()
            self.progressIndicator.animator().alphaValue = 0.0
            }, completionHandler: {
                self.progressIndicator.stopAnimation(self)
        })
    }
    
    private func showBackground() {
        guard backgroundView.alphaValue <= 0.0 else { return }
        
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.5
            self.backgroundView.animator().alphaValue = 1.0
            }, completionHandler: {})
    }
    
    private func hideBackground() {
        guard backgroundView.alphaValue > 0.0 else { return }
        
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.5
            self.backgroundView.animator().alphaValue = 0.0
            }, completionHandler: {})
    }
    
}
