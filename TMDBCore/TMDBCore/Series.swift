//
//  Series.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct Series {
    public let id: Int
    public let title: String
    public let overview: String
    public let language: String
    public let status: String
    public let creatorName: String
    public let firstAirDate: NSDate?
    public let lastAirDate: NSDate?
    public let popularity: Float
    public let rating: Float
    public let posterPath: String
    public let backdropPath: String
    public let seasons: [Season]
}