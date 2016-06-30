//
//  AppDelegate.swift
//  Binge
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import TMDBCore
import BingeUI
import MBProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var tabBarController: UITabBarController!
    
    private let factory = ViewControllerFactory()
    
    private var popularSeriesViewController: SeriesTableViewController!
    private var newViewController: SeriesTableViewController!
    private var searchViewController: SeriesTableViewController!
    private var favoritesViewController: SeriesTableViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Appearance.install()
        
        // make app's main window and tab bar controller (this is a "tab bar" app)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        tabBarController = UITabBarController()
        
        // temporary view controller to present a loading indicator while the configuration is downloaded from the server
        // the configuration is needed to instantiate other view controllers (they get this configuration with dependency injection)
        let loadingViewController = UIViewController()
        let loadingNavigationController = UINavigationController(rootViewController: loadingViewController)
        loadingViewController.view.backgroundColor = Colors.background
        tabBarController.setViewControllers([loadingNavigationController], animated: false)
        
        // put everything on screen
        window!.rootViewController = tabBarController
        window!.makeKeyAndVisible()
        
        // show loading indicator for the configuration load
        MBProgressHUD.showHUDAddedTo(loadingViewController.view, animated: true)
        
        // fetch configuration from the server
        // the configuration includes the URL for the images CDN and their sizes
        TMDBClient.fetchConfiguration { configuration, error in
            dispatch_async(dispatch_get_main_queue()) {
                // hide loading indicator
                MBProgressHUD.hideHUDForView(loadingViewController.view, animated: true)
                
                if error != nil {
                    // completely give up if we can't download the configuration
                    // TODO: fallback more gracefully?
                    let alert = UIAlertController(title: "Unable to load configuration", message: "Please try again later", preferredStyle: .Alert)
                    loadingViewController.presentViewController(alert, animated: true, completion: nil)
                } else {
                    // create all primary view controllers
                    self.createViewControllersWithConfiguration(configuration!)
                }
            }
        }
        
        return true
    }
    
    private func createViewControllersWithConfiguration(configuration: Configuration) {
        // MOST POPULAR
        // This shows a list of the most popular series
        let popularSeriesBinder = PopularSeriesBinder(configuration: configuration)
        popularSeriesViewController = factory.seriesTableViewControllerWithBinder(popularSeriesBinder, title: "Most Popular", tabTitle: "Popular", tabImage: UIImage(named: "popular-icon"))
        
        let popularNavController = UINavigationController(rootViewController: popularSeriesViewController)
        
        // NEW RELEASES
        // This one shows a list of new series in production
        let newSeriesBinder = NewSeriesBinder(configuration: configuration)
        popularSeriesViewController = factory.seriesTableViewControllerWithBinder(newSeriesBinder, title: "New Releases", tabTitle: "New", tabImage: UIImage(named: "new-icon"))
        
        let newSeriesNavController = UINavigationController(rootViewController: popularSeriesViewController)
        
        // FAVORITES
        // Shows the series the user has marked as favorites
        let favoritesBinder = FavoritesBinder(configuration: configuration)
        favoritesViewController = factory.seriesTableViewControllerWithBinder(favoritesBinder, title: "Favorites", tabTitle: "Favorites", tabImage: UIImage(named: "favorites-icon"), editingProvider: FavoritesEditingProvider())
        favoritesViewController.showsFavoriteIndicator = false
        
        let favoriteSeriesNavController = UINavigationController(rootViewController: favoritesViewController)
        
        // ADD EVERYTHING TO OUR TAB BAR
        tabBarController.setViewControllers([popularNavController, newSeriesNavController, favoriteSeriesNavController], animated: false)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

