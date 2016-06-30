//
//  SeriesAdapter.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Series: JSONAdaptable {
    
    public init?(json: JSON) {
        if let rawSeasons = json["seasons"].array {
            self.seasons = rawSeasons.flatMap({ JSONAdapter<Season>.adapt($0) })
        } else {
            self.seasons = []
        }
        
        guard let id = json["id"].int else { return nil }
        guard let title = json["name"].string else { return nil }
        guard let overview = json["overview"].string else { return nil }
        guard let posterPath = json["poster_path"].string else { return nil }
        
        var creatorName = ""
        if let createdBy = json["created_by"].array where createdBy.count > 0 {
            creatorName = createdBy[0]["name"].string ?? ""
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let firstAirDateString = json["first_air_date"].string
        let lastAirDateString = json["last_air_date"].string
        
        let firstAirDate = formatter.dateFromString(firstAirDateString ?? "")
        let lastAirDate = formatter.dateFromString(lastAirDateString ?? "")
        
        self.id = id
        self.title = title
        self.overview = overview
        self.language = json["original_language"].string ?? ""
        self.status = json["status"].string ?? ""
        self.popularity = json["popularity"].floatValue
        self.rating = json["vote_average"].floatValue
        self.posterPath = posterPath
        self.backdropPath = json["backdrop_path"].string ?? ""
        self.firstAirDate = firstAirDate
        self.lastAirDate = lastAirDate
        self.creatorName = creatorName
    }
    
}