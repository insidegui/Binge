//
//  PopularSeriesBinder.swift
//  BingeUI
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import TMDBCore
import RxSwift

public class PopularSeriesBinder: Binder<[SeriesViewModel]> {
    
    public override var supportsPagination: Bool {
        return true
    }
    
    let configuration: Configuration
    
    public var currentPage = 1
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        
        super.init()
    }
    
    public override func load() {
        state.value = .Loading
        
        TMDBClient.fetchPopularSeries(currentPage) { search, error in
            if error != nil {
                self.state.value = .Error(error: error!)
                return
            }
            
            if let search = search {
                let viewModels = search.results.map({ SeriesViewModel(configuration: self.configuration, series: $0) })
                if self.currentPage <= 1 {
                    self.state.value = .Loaded(entity: viewModels)
                } else {
                    self.state.value = .LoadedMore(entity: viewModels)
                }
            }
        }
    }
    
    public override func loadMore() {
        currentPage += 1
        
        load()
    }
    
}