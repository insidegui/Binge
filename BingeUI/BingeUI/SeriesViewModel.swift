//
//  SeriesViewModel.swift
//  BingeUI
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import TMDBCore
import RxSwift

public struct SeriesViewModel: Hashable {
    
    private let configuration: Configuration
    public let series: Series
    let disposeBag = DisposeBag()
    
    public init(configuration: Configuration, series: Series) {
        self.configuration = configuration
        self.series = series
    }
    
    public var isFavorite = Variable<Bool>(false)
    
    public var favoritesManager: FavoritesManager? {
        didSet {
            self.favoritesManager?.favorites.asObservable().observeOn(MainScheduler.instance).subscribeNext { _ in
                self.updateFavoriteStatus()
                }.addDisposableTo(disposeBag)
        }
    }
    
    public func updateFavoriteStatus() {
        guard let favorites = favoritesManager?.favorites.value else { return }
        
        isFavorite.value = favorites.contains(series.id)
    }
    
    public var posterURL: NSURL? {
        guard !configuration.imageBaseURL.isEmpty && !series.posterPath.isEmpty else {
            return nil
        }
        
        return NSURL(string: configuration.imageBaseURL + Configuration.defaultPosterSize + series.posterPath)
    }
    
    public var backdropURL: NSURL? {
        guard !configuration.imageBaseURL.isEmpty && !series.backdropPath.isEmpty else {
            return nil
        }
        
        #if os(iOS)
            let backdropSize = configuration.backdropSizes[2]
        #else
            let backdropSize = configuration.backdropSizes.last!
        #endif
        
        return NSURL(string: configuration.imageBaseURL + backdropSize + series.backdropPath)
    }
    
    public var hashValue: Int {
        return series.id
    }
    
    public func toggleFavorite() {
        if isFavorite.value == true {
            favoritesManager?.removeFavorite(series)
        } else {
            favoritesManager?.addFavorite(series)
        }
    }
    
}

public func ==(lhs: SeriesViewModel, rhs: SeriesViewModel) -> Bool {
    return lhs.hashValue == rhs.hashValue
}