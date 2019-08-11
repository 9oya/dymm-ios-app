//
//  BannerCollectionCell.swift
//  Dymm
//
//  Created by eunsang lee on 08/08/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

class BannerCollectionCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .scaleAspectFit
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    let titleLabel: UILabel = {
        let _label = UILabel()
        _label.font = .boldSystemFont(ofSize: 20)
        _label.textAlignment = .center
        _label.numberOfLines = 1
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    let subtitleLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 14)
        _label.textAlignment = .center
        _label.numberOfLines = 4
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

extension BannerCollectionCell {
    private func setupLayoutStyles() {
        backgroundColor = UIColor.white
        addShadowView()
    }
    
    private func setupLayoutSubviews() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }
    
    private func setupLayoutConstraints() {
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        
        subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
    }
}
