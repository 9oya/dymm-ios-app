//
//  BannerCollectionCell.swift
//  Dymm
//
//  Created by eunsang lee on 08/08/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

class BannerCollectionCell: UICollectionViewCell {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BannerCollectionCell {
    private func setupLayout() {
        backgroundColor = UIColor.white
        addShadowView()
        
        imageView = {
            let _imageView = UIImageView()
            _imageView.contentMode = .scaleAspectFit
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        titleLabel = {
            let _label = UILabel()
            _label.font = .boldSystemFont(ofSize: 30)
            _label.textAlignment = .center
            _label.numberOfLines = 6
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        subtitleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14)
            _label.textAlignment = .center
            _label.numberOfLines = 4
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
//        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
//        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
//        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
//        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15).isActive = true
        
        subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
    }
}
