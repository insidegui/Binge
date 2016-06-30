//
//  SeriesViewController.swift
//  Binge
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import RxSwift
import BingeUI

class SeriesViewController: NSViewController {

    private let disposeBag = DisposeBag()
    
    private let favoritesManager = FavoritesManager()
    
    var binder: Binder<[SeriesViewModel]>! {
        didSet {
            refresh()
        }
    }
    
    private var seriesViewModels = [SeriesViewModel]() {
        didSet {
            guard view.window != nil else { return }
            
            // compute the difference between the old items and new items to animate the new items in
            let oldSet = Set<SeriesViewModel>(oldValue)
            let newSet = Set<SeriesViewModel>(seriesViewModels)
            let addedItems = newSet.subtract(oldSet)
            let removedItems = oldSet.subtract(newSet)
            
            loadSeriesIntoCollectionView(addedItems, removedSeries: removedItems, oldEntities: oldValue)
        }
    }
    
    private struct Constants {
        static let itemNibName = "SeriesCollectionViewItem"
        static let seriesItemIdentifier = "SeriesItemIdentifier"
    }
    
    private lazy var scrollView: BingeScrollView = {
        let s = BingeScrollView(frame: NSZeroRect)
        
        s.translatesAutoresizingMaskIntoConstraints = false
        s.borderType = .NoBorder
        s.backgroundColor = Colors.background
        
        return s
    }()
    
    private lazy var collectionView: NSCollectionView = {
        let c = NSCollectionView(frame: NSZeroRect)
        
        c.selectable = true
        c.allowsMultipleSelection = true
        c.backgroundColors = [Colors.background]
            
        return c
    }()
    
    private lazy var loadingView: LoadingView = {
        let l = LoadingView(frame: NSZeroRect)
        
        l.translatesAutoresizingMaskIntoConstraints = false
        
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
        
        collectionView.setDraggingSourceOperationMask(.Copy, forLocal: false)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = GridLayout()
        
        collectionView.registerClass(SeriesCollectionViewItem.self, forItemWithIdentifier: Constants.seriesItemIdentifier)
    }
    
    private func buildUI() {
        view.addSubview(scrollView)
        
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        scrollView.layer = CALayer()
        scrollView.wantsLayer = true
        
        scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        
        collectionView.frame = scrollView.bounds
        scrollView.documentView = collectionView
        
        scrollView.delegate = self
        
        view.addSubview(loadingView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(0)-[loadingView]-(0)-|", options: [], metrics: nil, views: ["loadingView": loadingView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[loadingView]-(0)-|", options: [], metrics: nil, views: ["loadingView": loadingView]))
    }
    
    private func refresh() {
        guard binder != nil && viewLoaded else { return }
        
        binder.state.asObservable().observeOn(MainScheduler.instance).subscribeNext { [unowned self] state in
            switch state {
            case .Loading:
                self.showLoadingStateIfNeeded()
            case .Loaded(let viewModels):
                self.hideLoadingState()
                self.seriesViewModels = viewModels
            case .LoadedMore(let viewModels):
                self.hideLoadingState()
                self.seriesViewModels.appendContentsOf(viewModels)
            case .Error(let error):
                // TODO: implement a nice way of showing errors (alerts are ugly and a bad user experience and logging doesn't help the user)
                print("Error: \(error)")
            }
            }.addDisposableTo(disposeBag)
        
        binder.load()
    }
    
    private func showLoadingStateIfNeeded() {
        loadingView.show()
    }
    
    private func hideLoadingState() {
        loadingView.hide()
    }
    
    private func loadSeriesIntoCollectionView(newSeries: Set<SeriesViewModel>, removedSeries: Set<SeriesViewModel>, oldEntities: [SeriesViewModel]) {
        var indexPathsToInsert = [NSIndexPath]()
        var indexPathsToRemove = [NSIndexPath]()
        
        if newSeries.count > 0 {
            let itemCount = collectionView.numberOfItemsInSection(0)
            for i in itemCount ..< itemCount + newSeries.count {
                indexPathsToInsert.append(NSIndexPath(forItem: i, inSection: 0))
            }
        }
        
        if removedSeries.count > 0 {
            removedSeries.flatMap { oldEntities.indexOf($0) }.forEach { indexPathsToRemove.append(NSIndexPath(forItem: $0, inSection: 0)) }
        }
        
        collectionView.animator().performBatchUpdates({
            self.collectionView.insertItemsAtIndexPaths(Set<NSIndexPath>(indexPathsToInsert))
            self.collectionView.deleteItemsAtIndexPaths(Set<NSIndexPath>(indexPathsToRemove))
            }, completionHandler: nil)
    }

}

// MARK: - Collection view

extension SeriesViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItemWithIdentifier(Constants.seriesItemIdentifier, forIndexPath: indexPath) as! SeriesCollectionViewItem
        
        var viewModel = seriesViewModels[indexPath.item]
        viewModel.favoritesManager = favoritesManager
        item.viewModel = viewModel
        
        return item
    }
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return seriesViewModels.count
    }
}

// MARK: - Scroll View

extension SeriesViewController: BingeScrollViewDelegate {
    
    func scrollViewDidRequestMoreContent() {
        guard binder != nil else { return }
        guard binder.supportsPagination else { return }
        
        binder.loadMore()
    }
    
}