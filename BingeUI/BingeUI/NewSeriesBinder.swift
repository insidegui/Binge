//
//  NewSeriesBinder.swift
//  BingeUI
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import TMDBCore
import RxSwift

public class NewSeriesBinder: Binder<[SeriesViewModel]> {
    
    let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        
        super.init()
    }
    
    public override func load() {
        TMDBClient.fetchNewSeries { search, error in
            if error != nil {
                self.state.value = .Error(error: error!)
                return
            }
            
            if let search = search {
                let viewModels = search.results.map({ SeriesViewModel(configuration: self.configuration, series: $0) })
                self.state.value = .Loaded(entity: viewModels)
            }
        }
    }
    
}