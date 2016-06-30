//
//  FavoritesEditingProvider.swift
//  Binge
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import BingeUI

class FavoritesEditingProvider: SeriesTableViewEditingProvider {
    
    private lazy var favoritesManager = FavoritesManager()
    
    var viewModels: [SeriesViewModel]?
    
    func canEditRow(row: Int) -> Bool {
        return true
    }
    
    func editingStyleForRow(row: Int) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func commitEditingForRow(row: Int, style: UITableViewCellEditingStyle) {
        guard let viewModels = viewModels else { return }
        guard row < viewModels.count else { return }
        
        favoritesManager.removeFavorite(viewModels[row].series)
    }
    
}