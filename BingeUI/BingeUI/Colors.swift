//
//  Colors.swift
//  BingeUI
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#else
    import Cocoa
    public typealias UIColor = NSColor
#endif

public struct Colors {
    
    public static let primaryText = UIColor.whiteColor()
    public static let secondaryText = UIColor(red:0.719, green:0.726, blue:0.73, alpha:1)
    public static let navbarBackground = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
    public static let separator = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    public static let background = UIColor(red:0.135, green:0.135, blue:0.135, alpha:1)
    public static let tint = UIColor(red:0.931, green:0.157, blue:0.438, alpha:1)
    
}