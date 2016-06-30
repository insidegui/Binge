//
//  Configuration.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

public struct Configuration {
    
    public let imageBaseURL: String
    public let backdropSizes: [String]
    public let posterSizes: [String]
    
    public static let defaultPosterSize = "w500"
    
}