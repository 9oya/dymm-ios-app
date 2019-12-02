//
//  LogTableCell.swift
//  Dymm
//
//  Created by eunsang lee on 02/07/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

class LogTableCell: UITableViewCell {
    var bulletView: UIView!
    var nameLabel: UILabel!
    var quantityLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogTableCell {
    private func setupLayout() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        
        bulletView = {
            let _view = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
            _view.layer.cornerRadius = 3.5
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        nameLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14)
            _label.textAlignment = .left
            _label.addShadowView()
            _label.numberOfLines = 2
            _label.adjustsFontSizeToFitWidth = true
            _label.minimumScaleFactor = 0.5
            _label.allowsDefaultTighteningForTruncation = true
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        quantityLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14)
            _label.textColor = UIColor(hex: "#9A9A9A")
            _label.textAlignment = .right
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        
        addSubview(bulletView)
        addSubview(nameLabel)
        addSubview(quantityLabel)
        
        
        bulletView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        bulletView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        bulletView.widthAnchor.constraint(equalToConstant: 7).isActive = true
        bulletView.heightAnchor.constraint(equalToConstant: 7).isActive = true
        
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: bulletView.trailingAnchor, constant: 15).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
//        nameLabel.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: 0).isActive = true
        
        quantityLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        quantityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
    }
}

