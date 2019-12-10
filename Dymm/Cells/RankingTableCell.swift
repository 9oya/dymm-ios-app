//
//  RankingTableCell.swift
//  Dymm
//
//  Created by Eido Goya on 2019/10/31.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

let rankingTableCellId = "RankingTableCell"

class RankingTableCell: UITableViewCell {
    var containerView: UIView!
    var yearsBar: UIView!
    var daysBarBg: UIView!
    var daysBar: UIView!
    
    var profileImgView: UIImageView!
    
    var profileImgLabel: UILabel!
    var rankNumLabel: UILabel!
    var nameLabel: UILabel!
    var yearsLabel: UILabel!
    var daysLabel: UILabel!
    
    var yearsBarWidth: NSLayoutConstraint!
    var daysBarWidth: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RankingTableCell {
    func setupLayout() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        
        containerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.addShadowView()
            _view.layer.cornerRadius = 10.0
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        profileImgView = {
            let _imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 31, height: 31))
            _imageView.layer.cornerRadius = 31 / 2
            _imageView.contentMode = .scaleAspectFill
            _imageView.clipsToBounds = true
            _imageView.isUserInteractionEnabled = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        profileImgLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 17, weight: .medium)
            _label.textColor = .white
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        rankNumLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .left
            _label.textColor = .mediumSeaGreen
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        nameLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .left
            _label.textColor = .mediumSeaGreen
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        yearsLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .right
            _label.textColor = .mediumSeaGreen
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        daysLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 9, weight: .regular)
            _label.textAlignment = .right
            _label.textColor = .mediumSeaGreen
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        yearsBar = {
            let _view = UIView()
            _view.backgroundColor = .mediumSeaGreen
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        daysBarBg = {
            let _view = UIView()
            _view.backgroundColor = UIColor(hex: "#CBF5E8")
//            _view.backgroundColor = UIColor.green_00E9CC.withAlphaComponent(0.37)
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        daysBar = {
            let _view = UIView()
            _view.backgroundColor = .mediumSeaGreen
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        
        // Setup subviews
        addSubview(containerView)
        containerView.addSubview(rankNumLabel)
        containerView.addSubview(profileImgView)
        containerView.addSubview(profileImgLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(yearsBar)
        containerView.addSubview(daysBar)
        containerView.addSubview(daysBarBg)
        containerView.addSubview(yearsLabel)
        containerView.addSubview(daysLabel)
        
        // Setup constraints
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        profileImgView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        profileImgView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        profileImgView.widthAnchor.constraint(equalToConstant: 31).isActive = true
        profileImgView.heightAnchor.constraint(equalToConstant: 31).isActive = true
        
        profileImgLabel.centerXAnchor.constraint(equalTo: profileImgView.centerXAnchor, constant: 0).isActive = true
        profileImgLabel.centerYAnchor.constraint(equalTo: profileImgView.centerYAnchor, constant: 0).isActive = true
        
        rankNumLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10).isActive = true
        rankNumLabel.leadingAnchor.constraint(equalTo: profileImgView.trailingAnchor, constant: 10).isActive = true
        nameLabel.topAnchor.constraint(equalTo: rankNumLabel.bottomAnchor, constant: 2).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: profileImgView.trailingAnchor, constant: 10).isActive = true
        
        yearsBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        yearsBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        yearsBar.heightAnchor.constraint(equalToConstant: 11).isActive = true
        yearsBarWidth = yearsBar.widthAnchor.constraint(equalToConstant: 1)
        yearsBarWidth.priority = UILayoutPriority(rawValue: 999)
        yearsBarWidth.isActive = true
        
        daysBarBg.topAnchor.constraint(equalTo: yearsBar.bottomAnchor, constant: 1).isActive = true
        daysBarBg.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        daysBarBg.heightAnchor.constraint(equalToConstant: 7).isActive = true
        daysBarBg.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        daysBar.topAnchor.constraint(equalTo: yearsBar.bottomAnchor, constant: 1).isActive = true
        daysBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        daysBar.heightAnchor.constraint(equalToConstant: 7).isActive = true
        daysBarWidth = daysBar.widthAnchor.constraint(equalToConstant: 1)
        daysBarWidth.priority = UILayoutPriority(rawValue: 999)
        daysBarWidth.isActive = true
        
        yearsLabel.topAnchor.constraint(equalTo: daysBar.bottomAnchor, constant: 1).isActive = true
        yearsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        
        daysLabel.topAnchor.constraint(equalTo: yearsLabel.bottomAnchor, constant: 0).isActive = true
        daysLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
    }
}
