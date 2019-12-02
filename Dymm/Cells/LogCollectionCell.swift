//
//  LogCollectionCell.swift
//  Dymm
//
//  Created by eunsang lee on 28/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

class LogCollectionCell: UICollectionViewCell {
    var bulletView: UIView!
    var nameLabel: UILabel!
    var quantityLabel: UILabel!
    var lineView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogCollectionCell {
    private func setupLayout() {
        backgroundColor = .clear
        
        bulletView = {
            let _view = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
            _view.layer.cornerRadius = 3.5
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        nameLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15)
            _label.textAlignment = .left
            _label.lineBreakMode = .byTruncatingTail
            _label.adjustsFontSizeToFitWidth = true
            _label.minimumScaleFactor = 0.7
            _label.allowsDefaultTighteningForTruncation = true
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        quantityLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15)
            _label.textColor = .gray
            _label.textAlignment = .right
            _label.lineBreakMode = .byClipping
            _label.addShadowView(opacity: 0.7, color: UIColor.white.cgColor)
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        lineView = {
            let _view = UIView()
            _view.backgroundColor = UIColor(hex: "#F2F3F6")
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        
        addSubview(bulletView)
        addSubview(nameLabel)
        addSubview(quantityLabel)
        addSubview(lineView)
        
        bulletView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        bulletView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7).isActive = true
        bulletView.widthAnchor.constraint(equalToConstant: 7).isActive = true
        bulletView.heightAnchor.constraint(equalToConstant: 7).isActive = true
        
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: bulletView.trailingAnchor, constant: 15).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -35).isActive = true
        
        quantityLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        quantityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7).isActive = true
        
        lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 0.7).isActive = true
    }
}
