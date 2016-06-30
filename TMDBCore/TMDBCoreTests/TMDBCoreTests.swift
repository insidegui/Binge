//
//  TMDBCoreTests.swift
//  TMDBCoreTests
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import TMDBCore

class TMDBCoreTests: XCTestCase {
    
    var configurationJSON: NSData!
    var singleSeasonJSON: NSData!
    var breakingBadJSON: NSData!
    var searchForGameJSON: NSData!
    
    override func setUp() {
        super.setUp()
        
        configurationJSON = NSData(contentsOfURL: NSBundle(forClass: TMDBCoreTests.self).URLForResource("configuration", withExtension: "json")!)!
        singleSeasonJSON = NSData(contentsOfURL: NSBundle(forClass: TMDBCoreTests.self).URLForResource("single_season", withExtension: "json")!)!
        breakingBadJSON = NSData(contentsOfURL: NSBundle(forClass: TMDBCoreTests.self).URLForResource("breaking_bad", withExtension: "json")!)!
        searchForGameJSON = NSData(contentsOfURL: NSBundle(forClass: TMDBCoreTests.self).URLForResource("search_game", withExtension: "json")!)!
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConfigurationParsing() {
        let json = JSON(data: configurationJSON)
        
        guard let configuration = JSONAdapter<Configuration>.adapt(json) else {
            XCTFail("configuration should not be nil")
            return
        }
        
        XCTAssertEqual(configuration.imageBaseURL, "https://image.tmdb.org/t/p/")
        XCTAssertEqual(configuration.backdropSizes, ["w300", "w780", "w1280", "original"])
        XCTAssertEqual(configuration.posterSizes, ["w92", "w154", "w185", "w342", "w500", "w780", "original"])
    }
    
    func testBreakingBadSingleSeasonParsing() {
        let json = JSON(data: singleSeasonJSON)
        
        guard let season = JSONAdapter<Season>.adapt(json) else {
            XCTFail("season should not be nil")
            return
        }
        
        let testFormatter = NSDateFormatter()
        testFormatter.dateFormat = "yyyy-MM-dd"
        let reverseDateString = testFormatter.stringFromDate(season.airDate)
        
        XCTAssertEqual(reverseDateString, "2011-07-17")
        XCTAssertEqual(season.episodeCount, 13)
        XCTAssertEqual(season.id, 3576)
        XCTAssertEqual(season.number, 4)
        XCTAssertEqual(season.posterPath, "/5ewrnKp4TboU4hTLT5cWO350mHj.jpg")
    }
    
    func testBreakingBadSeriesParsing() {
        let json = JSON(data: breakingBadJSON)
        
        guard let series = JSONAdapter<Series>.adapt(json) else {
            XCTFail("season should not be nil")
            return
        }
        
        XCTAssertEqual(series.id, 1396)
        XCTAssertEqual(series.title, "Breaking Bad")
        XCTAssertEqual(series.overview, "Breaking Bad is an American crime drama television series created and produced by Vince Gilligan. Set and produced in Albuquerque, New Mexico, Breaking Bad is the story of Walter White, a struggling high school chemistry teacher who is diagnosed with inoperable lung cancer at the beginning of the series. He turns to a life of crime, producing and selling methamphetamine, in order to secure his family's financial future before he dies, teaming with his former student, Jesse Pinkman. Heavily serialized, the series is known for positioning its characters in seemingly inextricable corners and has been labeled a contemporary western by its creator.")
        XCTAssertEqual(series.creatorName, "Vince Gilligan")
        XCTAssertEqual(series.popularity, 14.355917)
        XCTAssertEqual(series.rating, 8.3)
        XCTAssertEqual(series.language, "en")
        XCTAssertEqual(series.posterPath, "/1yeVJox3rjo2jBKrrihIMj7uoS9.jpg")
        XCTAssertEqual(series.backdropPath, "/eSzpy96DwBujGFj0xMbXBcGcfxX.jpg")
        XCTAssertEqual(series.seasons.count, 6)
        XCTAssertEqual(series.seasons[5].id, 3578)
        XCTAssertEqual(series.seasons[5].number, 5)
    }
    
    func testSearchForGameParsing() {
        let json = JSON(data: searchForGameJSON)
        
        guard let searchResults = JSONAdapter<SearchResults<Series>>.adapt(json) else {
            XCTFail("searchResults should not be nil")
            return
        }
        
        XCTAssertEqual(searchResults.page, 1)
        XCTAssertEqual(searchResults.pageCount, 20)
        XCTAssertEqual(searchResults.totalResultsCount, 388)
        XCTAssertEqual(searchResults.results.count, 18)
        
        XCTAssertEqual(searchResults.results[0].id, 1399)
        XCTAssertEqual(searchResults.results[0].rating, 7.97)
        XCTAssertEqual(searchResults.results[0].popularity, 66.169288)
        XCTAssertEqual(searchResults.results[0].language, "en")
        XCTAssertEqual(searchResults.results[0].title, "Game of Thrones")
        
        XCTAssertEqual(searchResults.results.last!.id, 64264)
        XCTAssertEqual(searchResults.results.last!.rating, 0.0)
        XCTAssertEqual(searchResults.results.last!.popularity, 1.08926)
        XCTAssertEqual(searchResults.results.last!.language, "en")
        XCTAssertEqual(searchResults.results.last!.title, "Game Shakers")
    }
    
    func testFetchedConfiguration() {
        let expectation = expectationWithDescription("Fetch configuration async call")
        
        TMDBClient.fetchConfiguration { config, error in
            XCTAssertNotNil(config)
            XCTAssertNil(error)
            
            XCTAssertEqual(config!.imageBaseURL, "https://image.tmdb.org/t/p/")
            XCTAssertEqual(config!.backdropSizes, ["w300", "w780", "w1280", "original"])
            XCTAssertEqual(config!.posterSizes, ["w92", "w154", "w185", "w342", "w500", "w780", "original"])
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testFetchedBreakingBad() {
        let expectation = expectationWithDescription("Fetch Breaking Bad async call")
        
        TMDBClient.fetchSeriesWithID(1396) { series, error in
            XCTAssertNotNil(series)
            XCTAssertNil(error)
            
            XCTAssertEqual(series!.id, 1396)
            XCTAssertEqual(series!.title, "Breaking Bad")
            XCTAssertEqual(series!.overview, "Breaking Bad is an American crime drama television series created and produced by Vince Gilligan. Set and produced in Albuquerque, New Mexico, Breaking Bad is the story of Walter White, a struggling high school chemistry teacher who is diagnosed with inoperable lung cancer at the beginning of the series. He turns to a life of crime, producing and selling methamphetamine, in order to secure his family's financial future before he dies, teaming with his former student, Jesse Pinkman. Heavily serialized, the series is known for positioning its characters in seemingly inextricable corners and has been labeled a contemporary western by its creator.")
            XCTAssertEqual(series!.creatorName, "Vince Gilligan")
            XCTAssertEqual(series!.language, "en")
            XCTAssertEqual(series!.posterPath, "/1yeVJox3rjo2jBKrrihIMj7uoS9.jpg")
            XCTAssertEqual(series!.backdropPath, "/eSzpy96DwBujGFj0xMbXBcGcfxX.jpg")
            XCTAssertEqual(series!.seasons.count, 6)
            XCTAssertEqual(series!.seasons[5].id, 3578)
            XCTAssertEqual(series!.seasons[5].number, 5)
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testFetchedSearchForGames() {
        let expectation = expectationWithDescription("Fetch Search for Game async call")
        
        TMDBClient.searchForSeriesWithQuery("Game") { results, error in
            XCTAssertNotNil(results)
            XCTAssertNil(error)
            
            XCTAssertEqual(results!.results[0].id, 1399)
            XCTAssertEqual(results!.results[0].language, "en")
            XCTAssertEqual(results!.results[0].title, "Game of Thrones")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testFetchedPopularSeries() {
        let expectation = expectationWithDescription("Fetch Search for Game async call")
        
        TMDBClient.fetchPopularSeries { results, error in
            XCTAssertNotNil(results)
            XCTAssertNil(error)
            
            XCTAssertEqual(results!.results[0].id, 1399)
            XCTAssertEqual(results!.results[0].language, "en")
            XCTAssertEqual(results!.results[0].title, "Game of Thrones")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    
}
