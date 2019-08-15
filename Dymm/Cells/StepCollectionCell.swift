//
//  StepCollectionCell.swift
//  Dymm
//
//  Created by eunsang lee on 11/08/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

class StepCollectionCell: UICollectionViewCell {
    let label: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 14)
        _label.textAlignment = .center
        _label.numberOfLines = 2
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StepCollectionCell {
    private func setupLayout() {
        backgroundColor = UIColor.white
        
        addSubview(label)
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
}

