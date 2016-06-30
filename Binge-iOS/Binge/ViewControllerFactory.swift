//
//  ViewControllerFactory.swift
//  Binge
//
//  Created by Guilherme Rambo on 21/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import BingeUI

struct ViewControllerFactory {
    
    func seriesTableViewControllerWithBinder(binder: Binder<[SeriesViewModel]>, title: String, tabTitle: String? = nil, tabImage: UIImage? = nil, editingProvider: SeriesTableViewEditingProvider? = nil) -> SeriesTableViewController {
        let viewController = SeriesTableViewController(binder: binder, editingProvider: editingProvider)
        
        viewController.title = title
        
        if let tabImage = tabImage {
            viewController.tabBarItem = UITabBarItem(title: tabTitle, image: tabImage, tag: 0)
        }
        
        return viewController
    }
    
}
