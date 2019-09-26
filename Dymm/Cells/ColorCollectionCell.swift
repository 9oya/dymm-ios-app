//
//  ColorCollectionCell.swift
//  Dymm
//
//  Created by Eido Goya on 26/09/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

let colorCellId = "ColorCollectionCell"

class ColorCollectionCell: UICollectionViewCell {
    var colorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorCollectionCell {
    private func setupLayout() {
        backgroundColor = .white
        
        colorView = {
            let _view = UIView()
            _view.layer.cornerRadius = 10.0
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        
        addSubview(colorView)
        
        colorView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        colorView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: frame.width - 15).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: frame.height - 15).isActive = true
    }
}

