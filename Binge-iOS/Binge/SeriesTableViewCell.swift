//
//  SeriesTableViewCell.swift
//  Binge
//
//  Created by Guilherme Rambo on 20/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift
import BingeUI

class SeriesTableViewCell: UITableViewCell {

    var disposeBag = DisposeBag()
    
    var viewModel: SeriesViewModel? {
        didSet {
            updateUI()
        }
    }
    
    var imageFetcher: ImagesFetcher?
    
    let favoriteIndicator: UIImageView = {
        let i = UIImageView(image: UIImage(named: "heart"))
        
        i.translatesAutoresizingMaskIntoConstraints = false
        i.widthAnchor.constraintEqualToConstant(22.0).active = true
        i.heightAnchor.constraintEqualToConstant(22.0).active = true
        
        return i
    }()
    
    let titleLabel: UILabel = {
        let l = UILabel(frame: CGRectZero)
        
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightSemibold)
        l.textColor = Colors.primaryText
        
        return l
    }()
    
    let overviewLabel: UILabel = {
        let l = UILabel(frame: CGRectZero)
        
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFontOfSize(13.0)
        l.textColor = Colors.secondaryText
        l.numberOfLines = 4
        
        return l
    }()
    
    let posterView: UIImageView = {
        let iv = UIImageView(frame: CGRectZero)
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .ScaleAspectFill
        
        return iv
    }()
    
    private var didInstallConstraints = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        buildUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        Appearance.applyToCell(self)
        
        self.titleLabel.textColor = Colors.primaryText
        self.overviewLabel.textColor = Colors.secondaryText
        
        contentView.addSubview(posterView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(favoriteIndicator)
        
        posterView.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
        posterView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor).active = true
        posterView.widthAnchor.constraintEqualToConstant(65.0).active = true
        posterView.heightAnchor.constraintEqualToConstant(98.0).active = true
        
        titleLabel.leadingAnchor.constraintEqualToAnchor(posterView.trailingAnchor, constant: 8.0).active = true
        titleLabel.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 4.0).active = true
        titleLabel.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -8.0).active = true
        
        overviewLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 4.0).active = true
        overviewLabel.leadingAnchor.constraintEqualToAnchor(titleLabel.leadingAnchor).active = true
        overviewLabel.trailingAnchor.constraintEqualToAnchor(titleLabel.trailingAnchor).active = true
        
        favoriteIndicator.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 8.0).active = true
        favoriteIndicator.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 8.0).active = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        favoriteIndicator.hidden = true
        posterView.image = nil
        imageFetcher?.cancel()
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        imageFetcher = ImagesFetcher(imageURL: viewModel.posterURL) { [weak self] image in
            self?.posterView.image = image
        }
        
        titleLabel.text = viewModel.series.title
        overviewLabel.text = viewModel.series.overview
        
        viewModel.isFavorite.asObservable().observeOn(MainScheduler.instance).subscribeNext { favorite in
            self.favoriteIndicator.hidden = !favorite
        }.addDisposableTo(disposeBag)
        
        viewModel.updateFavoriteStatus()
    }

}
