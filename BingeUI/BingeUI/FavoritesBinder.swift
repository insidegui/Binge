//
//  FavoritesBinder.swift
//  BingeUI
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import TMDBCore
import RxSwift

public class FavoritesBinder: Binder<[SeriesViewModel]> {
    
    let kvs: NSUbiquitousKeyValueStore
    let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.kvs = NSUbiquitousKeyValueStore.defaultStore()
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyValueStoreDidChange(_:)), name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: kvs)
        kvs.synchronize()
    }
    
    @objc private func keyValueStoreDidChange(note: NSNotification) {
        load()
    }
    
    public override func load() {
        guard let favoriteIDs = kvs.arrayForKey(FavoritesManager.Constants.favoritesKey) as? [Int] else { return }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            var favorites = [SeriesViewModel]()
            var loadedFavoritesCount = 0
            
            favoriteIDs.forEach { id in
                TMDBClient.fetchSeriesWithID(id) { series, error in
                    loadedFavoritesCount += 1
                    
                    if error != nil {
                        print("Favorites binder: error fetching favorite with id \(id): \(error!)")
                        return
                    }
                    
                    let viewModel = SeriesViewModel(configuration: self.configuration, series: series!)
                    favorites.append(viewModel)
                }
            }
            
            while loadedFavoritesCount < favoriteIDs.count {
                usleep(100)
            }
            
            self.state.value = .Loaded(entity: favorites)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}