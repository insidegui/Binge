//
//  FavoritesManager.swift
//  BingeUI
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import TMDBCore
import RxSwift

public class FavoritesManager {
    
    private let kvs = NSUbiquitousKeyValueStore.defaultStore()
    
    var favorites = Variable<[Int]>([])
    
    struct Constants {
        static let changeKey = "changed"
        static let favoritesKey = "favorites"
    }
    
    public init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(kvsDidChange), name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: kvs)
        updateFavoritesArray()
    }
    
    @objc private func kvsDidChange() {
        updateFavoritesArray()
    }
    
    public func addFavorite(series: Series) {
        var favorites = kvs.objectForKey(Constants.favoritesKey) as? [Int] ?? [Int]()
        
        guard !favorites.contains(series.id) else { return }
        
        favorites.append(series.id)
        
        kvs.setObject(favorites, forKey: Constants.favoritesKey)
        kvs.setObject(Int(rand()), forKey: Constants.changeKey)
        
        kvs.synchronize()
        
        updateFavoritesArray()
    }
    
    public func removeFavorite(series: Series) {
        var favorites = kvs.objectForKey(Constants.favoritesKey) as? [Int] ?? [Int]()
        
        guard let idx = favorites.indexOf(series.id) else { return }
        
        favorites.removeAtIndex(idx)
        
        kvs.setObject(favorites, forKey: Constants.favoritesKey)
        kvs.setObject(Int(rand()), forKey: Constants.changeKey)
        kvs.synchronize()
        
        updateFavoritesArray()
    }
    
    private func updateFavoritesArray() {
        guard let favorites = kvs.objectForKey(Constants.favoritesKey) as? [Int] else { return }
        
        self.favorites.value = favorites
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}