//
//  NoteTableCell.swift
//  Dymm
//
//  Created by Eido Goya on 03/09/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

class NoteTableCell: UITableViewCell {
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteTableCell {
    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none
        
        titleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15, weight: .medium)
            _label.textAlignment = .left
            _label.numberOfLines = 1
            _label.textColor = .green_27D054
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        subTitleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .medium)
            _label.textAlignment = .left
            _label.textColor = .green_27D054
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
        subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
    }
}
