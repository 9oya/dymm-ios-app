//
//  LogTableCell.swift
//  Dymm
//
//  Created by eunsang lee on 02/07/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

class LogTableCell: UITableViewCell {
    let bulletView: UIView = {
        let _view = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
        _view.layer.cornerRadius = 3.5
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let nameLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 15)
        _label.textAlignment = .left
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    let quantityLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 15)
        _label.textAlignment = .right
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayoutStyles()
        setupLayoutSubviews()
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogTableCell {
    private func setupLayoutStyles() {
        backgroundColor = UIColor.clear
    }
    
    private func setupLayoutSubviews() {
        addSubview(bulletView)
        addSubview(nameLabel)
        addSubview(quantityLabel)
    }
    
    private func setupLayoutConstraints() {
        bulletView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        bulletView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        bulletView.widthAnchor.constraint(equalToConstant: 7).isActive = true
        bulletView.heightAnchor.constraint(equalToConstant: 7).isActive = true
        
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: bulletView.trailingAnchor, constant: 15).isActive = true
        
        quantityLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        quantityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
    }
}

