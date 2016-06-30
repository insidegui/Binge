//
//  SeriesCollectionViewItem.swift
//  Binge
//
//  Created by Guilherme Rambo on 22/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import BingeUI
import RxSwift

class SeriesCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var posterView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var favoriteButton: BingeMaskButton!
    
    var disposeBag = DisposeBag()
    
    override var selected: Bool {
        didSet {
            posterView.layer?.borderColor = selected ? Colors.tint.colorWithAlphaComponent(0.9).CGColor : nil
            posterView.layer?.borderWidth = selected ? 5.0 : 0.0
        }
    }
    
    var viewModel: SeriesViewModel? {
        didSet {
            updateUI()
        }
    }
    
    var imageFetcher: ImagesFetcher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // this makes the existing bag dispose everything
        disposeBag = DisposeBag()
        
        favoriteButton.state = NSOffState
        posterView.image = nil
        imageFetcher?.cancel()
    }
    
    private func updateUI() {
        guard let viewModel = viewModel where posterView != nil else { return }
        
        imageFetcher = ImagesFetcher(imageURL: viewModel.posterURL) { [weak self] image in
            self?.posterView.image = image
        }
        
        titleLabel.stringValue = viewModel.series.title
        
        viewModel.isFavorite.asObservable().observeOn(MainScheduler.instance).subscribeNext { [unowned self] favorite in
            self.favoriteButton.state = favorite ? NSOnState : NSOffState
        }.addDisposableTo(disposeBag)
        
        viewModel.updateFavoriteStatus()
    }
    
    @IBAction func toggleFavorite(sender: BingeMaskButton) {
        viewModel?.toggleFavorite()
    }
    
}
