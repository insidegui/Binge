//
//  SeriesTableViewEditingProvider.swift
//  Binge
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import BingeUI

protocol SeriesTableViewEditingProvider {

    var viewModels: [SeriesViewModel]? { set get }
    
    func canEditRow(row: Int) -> Bool
    func editingStyleForRow(row: Int) -> UITableViewCellEditingStyle
    func commitEditingForRow(row: Int, style: UITableViewCellEditingStyle)
    
}
