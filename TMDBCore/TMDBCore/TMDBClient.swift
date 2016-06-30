//
//  TMDBClient.swift
//  TMDBCore
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct TMDBClient {
    
    private static func distillError(inputData: NSData?, inputError: NSError?) -> NSError? {
        guard let data = inputData where data.length > 0 else {
            return NSError(domain: "TMDBCore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server returned an empty response"])
        }
        guard inputError == nil else {
            return inputError
        }
        
        return nil
    }
    
    public static func fetchConfiguration(completionHandler: (configuration: Configuration?, error: NSError?) -> ()) {
        TMDBEnvironment.requestWithPath("configuration").response { _, _, data, error in
            if let finalError = distillError(data, inputError: error) {
                completionHandler(configuration: nil, error: finalError)
                return
            }
            
            completionHandler(configuration: JSONAdapter<Configuration>.adapt(JSON(data: data!)), error: nil)
        }
    }
    
    public static func fetchSeriesWithID(seriesID: Int, completionHandler: (series: Series?, error: NSError?) -> ()) {
        TMDBEnvironment.requestWithPath("tv/\(seriesID)").response { _, _, data, error in
            if let finalError = distillError(data, inputError: error) {
                completionHandler(series: nil, error: finalError)
                return
            }
            
            completionHandler(series: JSONAdapter<Series>.adapt(JSON(data: data!)), error: nil)
        }
    }
    
    static func searchWithParameters(parameters: [String: String], path: String = "search/tv", completionHandler: (results: SearchResults<Series>?, error: NSError?) -> ()) {
        TMDBEnvironment.requestWithPath(path, parameters: parameters).response { _, _, data, error in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                if let finalError = distillError(data, inputError: error) {
                    completionHandler(results: nil, error: finalError)
                    return
                }
                
                if let search = JSONAdapter<SearchResults<Series>>.adapt(JSON(data: data!)) {
                    var computedResultsCount = 0
                    var completedSeries = [Series]()
                    
                    search.results.forEach { incompleteSeries in
                        fetchSeriesWithID(incompleteSeries.id) { series, error in
                            if let series = series {
                                completedSeries.append(series)
                            }
                            
                            computedResultsCount += 1
                        }
                    }
                    
                    while computedResultsCount < search.results.count {
                        usleep(100)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(results: SearchResults<Series>(results: completedSeries, page: search.page, pageCount: search.pageCount, totalResultsCount: search.totalResultsCount), error: nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(results: nil, error: NSError(domain: "TMDBCore", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unable to parse search results"]))
                    }
                }
            }
        }
    }
    
    public static func searchForSeriesWithQuery(query: String, page: Int = 1, completionHandler: (results: SearchResults<Series>?, error: NSError?) -> ()) {
        searchWithParameters(["query": query, "page": "\(page)"], completionHandler: completionHandler)
    }
    
    public static func fetchPopularSeries(page: Int = 1, completionHandler: (results: SearchResults<Series>?, error: NSError?) -> ()) {
        searchWithParameters(["sort_by": "popularity.desc", "page": "\(page)"], path: "discover/tv", completionHandler: completionHandler)
    }
    
    public static func fetchNewSeries(page: Int = 1, completionHandler: (results: SearchResults<Series>?, error: NSError?) -> ()) {
        searchWithParameters(["sort_by": "first_air_date.desc", "page": "\(page)"], path: "discover/tv", completionHandler: completionHandler)
    }
    
}