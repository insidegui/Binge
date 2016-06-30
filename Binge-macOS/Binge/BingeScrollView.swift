//
//  BingeScrollView.swift
//  Binge
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import BingeUI

protocol BingeScrollViewDelegate {
    /// Invoked when the user scrolls past the bottom of the scrollable area and releases the mouse
    func scrollViewDidRequestMoreContent()
}

class BingeScrollView: NSScrollView {

    var delegate: BingeScrollViewDelegate?
    
    private struct Metrics {
        static let loadMoreLabelWidth = CGFloat(180.0)
        static let loadMoreLabelHeight = CGFloat(38.0)
        static let loadMoreThreshold = CGFloat(38.0)
    }
    
    private let loadMoreLabel: NSTextField = {
        let l = NSTextField(frame: NSRect(x: 0, y: 0, width: Metrics.loadMoreLabelWidth, height: Metrics.loadMoreLabelHeight))
        
        l.bezeled = false
        l.bordered = false
        l.drawsBackground = false
        l.selectable = false
        l.editable = false
        l.textColor = Colors.secondaryText
        l.alignment = .Center
        l.font = NSFont.systemFontOfSize(14.0, weight: NSFontWeightMedium)
        l.stringValue = "Load More"
        l.translatesAutoresizingMaskIntoConstraints = false
        l.widthAnchor.constraintEqualToConstant(l.bounds.width).active = true
        l.heightAnchor.constraintEqualToConstant(l.bounds.height).active = true
        
        return l
    }()
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        contentView.postsBoundsChangedNotifications = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(contentViewBoundsDidChange), name: NSViewBoundsDidChangeNotification, object: contentView)
        
        if let documentView = documentView as? NSView {
            contentView.addSubview(loadMoreLabel)
            loadMoreLabel.bottomAnchor.constraintEqualToAnchor(documentView.bottomAnchor, constant: Metrics.loadMoreThreshold).active = true
            loadMoreLabel.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
        }
    }
    
    private var shouldLoadMoreWhenReleased = false {
        didSet {
            loadMoreLabel.textColor = shouldLoadMoreWhenReleased ? Colors.tint : Colors.secondaryText
        }
    }
    
    @objc private func contentViewBoundsDidChange() {
        guard let documentView = documentView as? NSView else { return }
        
        let maxScrollY = documentView.bounds.height - contentView.bounds.height
        let offsetY = contentView.bounds.origin.y
        
        if offsetY > maxScrollY + Metrics.loadMoreThreshold {
            shouldLoadMoreWhenReleased = true
        } else {
            shouldLoadMoreWhenReleased = false
        }
    }
    
    override func scrollWheel(theEvent: NSEvent) {
        super.scrollWheel(theEvent)
        
        if theEvent.phase == .Ended && shouldLoadMoreWhenReleased {
            delegate?.scrollViewDidRequestMoreContent()
        }
    }
    
    deinit {
        contentView.postsBoundsChangedNotifications = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
