//
//  CondCollectionCell.swift
//  Dymm
//
//  Created by eunsang lee on 15/08/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

class CondCollectionCell: UICollectionViewCell {
    var titleLabel: UILabel!
    var stackView: UIStackView!
    var startDateLabel: UILabel!
    var endDateLabel: UILabel!
    var removeImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CondCollectionCell {
    private func setupLayout() {
        backgroundColor = UIColor.white
        
        titleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14)
            _label.textAlignment = .left
            _label.numberOfLines = 2
            _label.adjustsFontSizeToFitWidth = true
            _label.minimumScaleFactor = 0.5
            _label.allowsDefaultTighteningForTruncation = true
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        stackView = {
            let _stackView = UIStackView()
            _stackView.axis = .vertical
            _stackView.translatesAutoresizingMaskIntoConstraints = false
            return _stackView
        }()
        startDateLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14)
            _label.textAlignment = .right
            _label.numberOfLines = 2
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        endDateLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14)
            _label.textAlignment = .right
            _label.numberOfLines = 2
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        removeImageView = {
            let _imageView = UIImageView()
            _imageView.image = .itemRemove
            _imageView.isHidden = true
            _imageView.contentMode = .scaleAspectFit
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        
        addSubview(stackView)
        addSubview(titleLabel)
        addSubview(removeImageView)
        stackView.addArrangedSubview(startDateLabel)
        stackView.addArrangedSubview(endDateLabel)
        
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -110).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        removeImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        removeImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
}
