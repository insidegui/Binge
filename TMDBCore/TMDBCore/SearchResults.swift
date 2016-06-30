//
//  SearchResults.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct SearchResults<M where M:JSONAdaptable> {
    
    public let results: [M]
    public let page: Int
    public let pageCount: Int
    public let totalResultsCount: Int
    
}