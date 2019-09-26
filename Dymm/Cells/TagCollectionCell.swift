//
//  TagCollectionCell.swift
//  Flava
//
//  Created by eunsang lee on 15/05/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

let tagCellId = "TagCollectionCell"
let tagCellHeightInt = 45

class TagCollectionCell: UICollectionViewCell {
    var imageView: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagCollectionCell {
    private func setupLayout() {
        backgroundColor = UIColor.white
        addShadowView()
        
        imageView = {
            let _imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            _imageView.contentMode = .scaleAspectFit
            _imageView.clipsToBounds = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        label = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14)
            _label.textAlignment = .center
            _label.numberOfLines = 3
            _label.adjustsFontSizeToFitWidth = true
            _label.minimumScaleFactor = 0.5
            _label.allowsDefaultTighteningForTruncation = true
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        
        addSubview(imageView)
        addSubview(label)
        
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }
}
