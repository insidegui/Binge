//
//  SeasonAdapter.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Season: JSONAdaptable {
    
    public init?(json: JSON) {
        guard let airDateString = json["air_date"].string else { return nil }
        guard let episodeCount = json["episode_count"].int else { return nil }
        guard let id = json["id"].int else { return nil }
        guard let posterPath = json["poster_path"].string else { return nil }
        guard let number = json["season_number"].int else { return nil }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.dateFromString(airDateString) else { return nil }
        
        self.id = id
        self.number = number
        self.airDate = date
        self.posterPath = posterPath
        self.episodeCount = episodeCount
    }
    
}