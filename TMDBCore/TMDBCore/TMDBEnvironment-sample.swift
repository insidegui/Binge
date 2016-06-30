//
//  TMDBEnvironment.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import Alamofire

struct TMDBEnvironment {
    
    private static let userAgent = "Binge"
    private static let baseURL = "https://api.themoviedb.org/3/"
    private static let apiKey = "API-KEY"
    
    static func requestWithPath(path: String, parameters: [String: String] = [:]) -> Alamofire.Request {
        var requestParameters = parameters
        requestParameters["api_key"] = apiKey
        
        return Alamofire.request(.GET, baseURL + path, parameters: requestParameters)
    }
    
}