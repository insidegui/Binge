//
//  DarkWindow.swift
//  Binge
//
//  Created by Guilherme Rambo on 02/04/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class DarkWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        applyCustomizations()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        applyCustomizations()
    }
    
    override var effectiveAppearance: NSAppearance {
        return NSAppearance(named: NSAppearanceNameVibrantDark)!
    }
    
    private var _storedTitlebarView: NSVisualEffectView?
    private var titlebarView: NSVisualEffectView? {
        guard _storedTitlebarView == nil else { return _storedTitlebarView }
        guard let containerClass = NSClassFromString("NSTitlebarContainerView") else { return nil }
        
        guard let containerView = contentView?.superview?.subviews.filter({ $0.isKindOfClass(containerClass) }).last else { return nil }
        
        guard let titlebar = containerView.subviews.filter({ $0.isKindOfClass(NSVisualEffectView.self) }).last as? NSVisualEffectView else { return nil }
        
        _storedTitlebarView = titlebar
        
        return _storedTitlebarView
    }
    private var titlebarWidgets: [NSButton]? {
        return titlebarView?.subviews.map({ $0 as? NSButton }).filter({ $0 != nil }).map({ $0! })
    }
    
    private var titleTextField: NSTextField?
    private var titlebarSeparatorLayer: CALayer?
    private var titlebarGradientLayer: CAGradientLayer?
    
    private var fullscreenObserver: NSObjectProtocol?
    
    private func applyCustomizations(note: NSNotification? = nil) {
        titleVisibility = .Hidden
        movableByWindowBackground = true
        
        titlebarView?.material = .UltraDark
        titlebarView?.state = .Active
        
        installTitlebarGradientIfNeeded()
        installTitlebarSeparatorIfNeeded()
        
        installFullscreenObserverIfNeeded()
    }
    
    private func installTitlebarGradientIfNeeded() {
        guard titlebarGradientLayer == nil && titlebarView != nil else { return }
        
        titlebarGradientLayer = CAGradientLayer()
        titlebarGradientLayer!.colors = [NSColor(calibratedWhite: 0.0, alpha: 0.4).CGColor, NSColor.clearColor().CGColor]
        titlebarGradientLayer!.frame = titlebarView!.bounds
        titlebarGradientLayer!.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
        titlebarGradientLayer!.compositingFilter = "overlayBlendMode"
        titlebarView?.layer?.insertSublayer(titlebarGradientLayer!, atIndex: 0)
    }
    
    private func installTitlebarSeparatorIfNeeded() {
        guard titlebarSeparatorLayer == nil && titlebarView != nil else { return }
        
        titlebarSeparatorLayer = CALayer()
        titlebarSeparatorLayer!.backgroundColor = NSColor.labelColor().colorWithAlphaComponent(0.7).CGColor
        titlebarSeparatorLayer!.frame = CGRect(x: 0.0, y: 0.0, width: titlebarView!.bounds.width, height: 1.0)
        titlebarSeparatorLayer!.autoresizingMask = [.LayerWidthSizable, .LayerMaxYMargin]
        titlebarView?.layer?.addSublayer(titlebarSeparatorLayer!)
    }
    
    private func installFullscreenObserverIfNeeded() {
        guard fullscreenObserver == nil else { return }
        
        let nc = NSNotificationCenter.defaultCenter()
        
        // the customizations (especially the title text field ones) have to be reapplied when entering and exiting fullscreen
        nc.addObserverForName(NSWindowDidEnterFullScreenNotification, object: self, queue: nil, usingBlock: applyCustomizations)
        nc.addObserverForName(NSWindowDidExitFullScreenNotification, object: self, queue: nil, usingBlock: applyCustomizations)
    }
    
    override func makeKeyAndOrderFront(sender: AnyObject?) {
        super.makeKeyAndOrderFront(sender)
        
        applyCustomizations()
    }
}