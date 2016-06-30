//
//  SearchResultsAdapter.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

extension SearchResults: JSONAdaptable {
    
    public init?(json: JSON) {
        guard let results = json["results"].array else {
            return nil
        }
        
        self.results = results.flatMap({ JSONAdapter<M>.adapt($0) })
        self.totalResultsCount = json["total_results"].intValue
        self.pageCount = json["total_pages"].intValue
        self.page = json["page"].intValue
    }
    
}