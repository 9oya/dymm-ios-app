//
//  TagCollectionCell.swift
//  Flava
//
//  Created by eunsang lee on 15/05/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

class TagCollectionCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .scaleAspectFit
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    let label: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 14)
        _label.textAlignment = .center
        _label.numberOfLines = 4
        _label.adjustsFontSizeToFitWidth = true
        _label.minimumScaleFactor = 0.5
        _label.allowsDefaultTighteningForTruncation = true
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayoutStyles()
        setupLayoutSubviews()
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagCollectionCell {
    private func setupLayoutStyles() {
        backgroundColor = UIColor.white
        addShadowView()
    }
    
    private func setupLayoutSubviews() {
        addSubview(imageView)
        addSubview(label)
    }
    
    private func setupLayoutConstraints() {
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }
}
