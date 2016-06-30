//
//  BingeMaskButton.swift
//  Binge
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import BingeUI

private extension NSImage {
    
    var cgImage: CGImage! {
        let source = CGImageSourceCreateWithData(TIFFRepresentation!, nil)
        
        return CGImageSourceCreateImageAtIndex(source!, 0, nil)
    }
    
}

class BingeMaskButton: NSButton {

    override var flipped: Bool {
        return false
    }
    
    override func drawRect(dirtyRect: NSRect) {
        guard var image = image else { return }
        
        if state == NSOnState {
            image = alternateImage ?? image
        }
        
        guard let ctx = NSGraphicsContext.currentContext()?.CGContext else { return }
        CGContextSaveGState(ctx)
        
        let constrainedWidth: CGFloat
        let constrainedHeight: CGFloat
        
        let rw = image.size.width / bounds.width
        let rh = image.size.height / bounds.height
        
        if (rw > rh) {
            constrainedHeight = round(image.size.height / rw)
            constrainedWidth = bounds.width
        } else {
            constrainedWidth = round(image.size.width / rh)
            constrainedHeight = bounds.height
        }
        
        let maskRect = NSRect(
            x: round(bounds.width / 2.0 - constrainedWidth / 2.0),
            y: round(bounds.height / 2.0 - constrainedHeight / 2.0),
            width: constrainedWidth,
            height: constrainedHeight
        )
        
        let tintColor = Colors.tint.CGColor
        
        CGContextClipToMask(ctx, maskRect, image.cgImage)
        CGContextSetFillColorWithColor(ctx, tintColor)
        CGContextFillRect(ctx, bounds)
        
        CGContextRestoreGState(ctx)
    }
    
}
