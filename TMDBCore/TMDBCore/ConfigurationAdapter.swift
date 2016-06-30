//
//  ConfigurationAdapter.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Configuration: JSONAdaptable {
    
    public init?(json: JSON) {
        guard let imageBaseURL = json["images"]["secure_base_url"].string else { return nil }
        guard let backdropSizes = json["images"]["backdrop_sizes"].arrayObject as? [String] else { return nil }
        guard let posterSizes = json["images"]["poster_sizes"].arrayObject as? [String] else { return nil }
        
        self.imageBaseURL = imageBaseURL
        self.backdropSizes = backdropSizes
        self.posterSizes = posterSizes
    }
    
}