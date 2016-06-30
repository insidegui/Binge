//
//  Appearance.swift
//  BingeUI
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#if os(iOS)
import UIKit

public class Appearance {
    
    public class func install() {
//        UIWindow.appearance().backgroundColor = Colors.background
//        UIScrollView.appearance().backgroundColor = Colors.background

        UINavigationBar.appearance().backgroundColor = Colors.navbarBackground
        UINavigationBar.appearance().tintColor = Colors.primaryText
        UINavigationBar.appearance().barTintColor = Colors.navbarBackground

        let shadowImage: UIImage = {
            UIGraphicsBeginImageContext(CGSize(width: 2.0, height: 2.0))
            
            let ctx = UIGraphicsGetCurrentContext()!
            Colors.separator.setFill()
            CGContextFillRect(ctx, CGRect(x: 0.0, y: 0.0, width: 2.0, height: 2.0))
            
            return UIGraphicsGetImageFromCurrentImageContext()
        }()
        
        UINavigationBar.appearance().shadowImage = shadowImage
        UITabBar.appearance().shadowImage = shadowImage
        
        UITabBar.appearance().backgroundColor = Colors.navbarBackground
        UITabBar.appearance().tintColor = Colors.tint
        UITabBar.appearance().barTintColor = Colors.navbarBackground
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.primaryText]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Colors.primaryText], forState: .Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Colors.tint], forState: .Selected)
        
        UITableView.appearance().backgroundColor = Colors.background
        UITableViewCell.appearance().backgroundColor = Colors.background
        UITableView.appearance().separatorColor = Colors.separator
        
        UITableView.appearance().separatorInset = UIEdgeInsetsZero
        UITableViewCell.appearance().separatorInset = UIEdgeInsetsZero
    }
    
    public class func applyToCell(cell: UITableViewCell) {
        cell.backgroundColor = Colors.background
        cell.tintColor = Colors.tint
        cell.textLabel?.textColor = Colors.primaryText
        cell.detailTextLabel?.textColor = Colors.secondaryText
    }
    
}
#endif