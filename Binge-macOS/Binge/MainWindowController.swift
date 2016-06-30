//
//  MainWindowController.swift
//  Binge
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import TMDBCore
import BingeUI

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // configure window
        window?.titleVisibility = .Hidden
        window?.backgroundColor = Colors.background
        window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        
        // fetch configuration from the server
        // the configuration includes the URL for the images CDN and their sizes
        TMDBClient.fetchConfiguration { configuration, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    // completely give up if we can't download the configuration
                    // TODO: fallback more gracefully?
                    NSAlert(error: error!).runModal()
                } else {
                    // create all primary view controllers
                    self.configureViewControllers(configuration!)
                }
            }
        }
    }
    
    private var tabController: NSTabViewController! {
        return contentViewController as! NSTabViewController
    }
    
    private var popularViewController: SeriesViewController!
    private var newSeriesViewController: SeriesViewController!
    
    private func configureViewControllers(configuration: Configuration) {
        let popularBinder = PopularSeriesBinder(configuration: configuration)
        let newBinder = NewSeriesBinder(configuration: configuration)
        
        (tabController.childViewControllers[0] as? SeriesViewController)?.binder = popularBinder
        (tabController.childViewControllers[1] as? SeriesViewController)?.binder = newBinder
    }

    @IBOutlet weak var navigationSegmentedControl: NSSegmentedControl!
    
    @IBAction func navigationSegmentedControlAction(sender: AnyObject) {
        tabController.selectedTabViewItemIndex = navigationSegmentedControl.selectedSegment
    }
}
