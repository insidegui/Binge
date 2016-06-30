//
//  SeriesTableViewController.swift
//  Binge
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift
import TMDBCore
import BingeUI
import MBProgressHUD

class SeriesTableViewController: UITableViewController {
    
    var showsFavoriteIndicator = true
    
    private let disposeBag = DisposeBag()
    
    private let favoritesManager = FavoritesManager()
    
    private var seriesViewModels = [SeriesViewModel]() {
        didSet {
            editingProvider?.viewModels = seriesViewModels
            
            // compute the difference between the old items and new items to animate the new items in
            let oldSet = Set<SeriesViewModel>(oldValue)
            let newSet = Set<SeriesViewModel>(seriesViewModels)
            let addedItems = newSet.subtract(oldSet)
            let removedItems = oldSet.subtract(newSet)
            
            loadSeriesIntoTableView(addedItems, removedSeries: removedItems, oldEntities: oldValue)
        }
    }
    
    private let binder: Binder<[SeriesViewModel]>
    private var editingProvider: SeriesTableViewEditingProvider?
    
    init(binder: Binder<[SeriesViewModel]>, editingProvider: SeriesTableViewEditingProvider? = nil) {
        self.binder = binder
        self.editingProvider = editingProvider
        
        super.init(style: .Plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private struct Constants {
        static let cellIdentifier = "Series Cell"
    }
    
    private struct Metrics {
        static let rowHeight = CGFloat(98.0)
        static let loadMoreControlHeight = CGFloat(36.0)
    }
    
    private var loadMoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = Metrics.rowHeight
        tableView.registerClass(SeriesTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadMoreLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: Metrics.loadMoreControlHeight))
        loadMoreLabel.font = UIFont.systemFontOfSize(14.0, weight: UIFontWeightMedium)
        loadMoreLabel.textColor = Colors.secondaryText
        loadMoreLabel.textAlignment = .Center
        loadMoreLabel.text = "Load More"
        
        refresh()
    }
    
    private func refresh() {
        binder.state.asObservable().observeOn(MainScheduler.instance).subscribeNext { [unowned self] state in
            switch state {
            case .Loading:
                self.showLoadingStateIfNeeded()
            case .Loaded(let viewModels):
                self.seriesViewModels = viewModels
            case .LoadedMore(let viewModels):
                self.seriesViewModels.appendContentsOf(viewModels)
            case .Error(let error):
                // TODO: implement a nice way of showing errors (alerts are ugly and a bad user experience and logging doesn't help the user)
                print("Error: \(error)")
            }
            }.addDisposableTo(disposeBag)
        
        binder.load()
    }
    
    private func showLoadingStateIfNeeded() {
        guard MBProgressHUD.allHUDsForView(navigationController!.view).count == 0 else { return }
        
        MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
    }
    
    private func hideLoadingState() {
        MBProgressHUD.hideAllHUDsForView(self.navigationController!.view, animated: true)
    }
    
    // this will install the table view's "load more" control and adjust the content inset so it's hidden after the table view
    private func installLoadMoreViewAndUpdateInsetsIfNeeded() {
        guard binder.supportsPagination else { return }
        guard tableView.tableFooterView == nil else { return }
        
        tableView.tableFooterView = loadMoreLabel
        var insets = tableView.contentInset
        insets.bottom -= loadMoreLabel.bounds.height
        tableView.contentInset = insets
    }
    
    private func loadSeriesIntoTableView(newSeries: Set<SeriesViewModel>, removedSeries: Set<SeriesViewModel>, oldEntities: [SeriesViewModel]) {
        var indexPathsToInsert = [NSIndexPath]()
        var indexPathsToRemove = [NSIndexPath]()
        
        if newSeries.count > 0 {
            let rowCount = tableView.numberOfRowsInSection(0)
            for i in rowCount ..< rowCount + newSeries.count {
                indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: 0))
            }
        }
        
        if removedSeries.count > 0 {
            removedSeries.flatMap { oldEntities.indexOf($0) }.forEach { indexPathsToRemove.append(NSIndexPath(forRow: $0, inSection: 0)) }
        }
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: .Automatic)
        tableView.deleteRowsAtIndexPaths(indexPathsToRemove, withRowAnimation: .Automatic)
        tableView.endUpdates()
        
        hideLoadingState()
        
        installLoadMoreViewAndUpdateInsetsIfNeeded()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seriesViewModels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellIdentifier) as! SeriesTableViewCell
        
        var viewModel = seriesViewModels[indexPath.item]
        
        if showsFavoriteIndicator {
            viewModel.favoritesManager = favoritesManager
        }
        
        cell.viewModel = viewModel
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return editingProvider?.canEditRow(indexPath.row) ?? false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return editingProvider?.editingStyleForRow(indexPath.row) ?? .None
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        editingProvider?.commitEditingForRow(indexPath.row, style: editingStyle)
        binder.load()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let maxContentOffset = scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.top + scrollView.contentInset.bottom
        
        if scrollView.contentOffset.y > maxContentOffset && decelerate {
            binder.loadMore()
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let maxContentOffset = scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.top + scrollView.contentInset.bottom
        
        if scrollView.contentOffset.y > maxContentOffset {
            loadMoreLabel.textColor = Colors.tint
        } else {
            loadMoreLabel.textColor = Colors.secondaryText
        }
    }
    
    

}

