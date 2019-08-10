//
//  LogGroupTableCell.swift
//  Dymm
//
//  Created by eunsang lee on 28/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

private let logsTableCellId = "LogsTableCell"

class LogGroupTableCell: UITableViewCell {
    let containerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        _view.addShadowView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    var containerViewHight: NSLayoutConstraint!
    let arrowImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.image = UIImage(named: "item-poly-left")
        _imageView.contentMode = .scaleAspectFit
        _imageView.isHidden = true
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    let groupTypeImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .scaleAspectFit
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    let nameLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 15)
        _label.textAlignment = .left
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    let condScoreLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 15)
        _label.textAlignment = .left
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    let foodLogBulletView: UIView = {
        let _view = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
        _view.backgroundColor = UIColor.tomato
        _view.layer.cornerRadius = 3.5
        _view.isHidden = true
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let actLogBulletView: UIView = {
        let _view = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
        _view.backgroundColor = UIColor.yellowGreen
        _view.layer.cornerRadius = 3.5
        _view.isHidden = true
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let drugLogBulletView: UIView = {
        let _view = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
        _view.backgroundColor = UIColor.dodgerBlue
        _view.layer.cornerRadius = 3.5
        _view.isHidden = true
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let groupOfLogsTableView: UITableView = {
        let _tableView = UITableView(frame: CGRect.zero, style: .plain)
        _tableView.register(LogTableCell.self, forCellReuseIdentifier: logsTableCellId)
        _tableView.backgroundColor = UIColor.clear
        _tableView.separatorStyle = .singleLine
        _tableView.isScrollEnabled = false
        _tableView.isHidden = true
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        return _tableView
    }()
    var groupOfLogsTableHeight: NSLayoutConstraint!
    
    var selectedLogGroup: BaseModel.LogGroup?
    var selectedLogGroupId: Int?
    var groupOfLogSet: CustomModel.GroupOfLogSet?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayoutStyles()
        groupOfLogsTableView.delegate = self
        groupOfLogsTableView.dataSource = self
        setupLayoutSubviews()
        setupLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogGroupTableCell: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var total = 0
        if let foodLogs = groupOfLogSet?.food_logs {
            total += (foodLogs.count)
        }
        if let actLogs = groupOfLogSet?.act_logs {
            total += (actLogs.count)
        }
        if let drugLogs = groupOfLogSet?.drug_logs {
            total += (drugLogs.count)
        }
        return total
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: logsTableCellId, for: indexPath) as? LogTableCell else {
            fatalError()
        }
        var idx = 0
        if (groupOfLogSet!.food_logs?.count) ?? 0 > indexPath.row {
            let foodLog = groupOfLogSet!.food_logs![indexPath.row]
            cell.bulletView.backgroundColor = UIColor.tomato
            cell.nameLabel.text = foodLog.eng_name
            cell.quantityLabel.text = "\(foodLog.x_val!)\(foodLog.y_val!)"
        } else if (groupOfLogSet!.act_logs?.count) ?? 0 > indexPath.row {
            if (selectedLogGroup!.has_food) {
                idx = indexPath.row - (groupOfLogSet!.food_logs!.count - 1)
            } else {
                idx = indexPath.row
            }
            let actLog = groupOfLogSet!.act_logs![idx]
            cell.bulletView.backgroundColor = UIColor.yellowGreen
            cell.nameLabel.text = actLog.eng_name
            cell.quantityLabel.text = "\(actLog.x_val!)\(actLog.y_val!)"
        } else if (groupOfLogSet!.drug_logs?.count) ?? 0 > indexPath.row {
            if (selectedLogGroup!.has_food) {
                idx = indexPath.row - (groupOfLogSet!.food_logs!.count - 1)
                if (selectedLogGroup?.has_act)! {
                    idx -= (groupOfLogSet!.act_logs!.count - 1)
                }
            }
            if (selectedLogGroup?.has_act)! {
                idx = indexPath.row - (groupOfLogSet!.act_logs!.count - 1)
            } else {
                idx = indexPath.row
            }
            let drugLog = groupOfLogSet!.drug_logs![idx]
            cell.bulletView.backgroundColor = UIColor.dodgerBlue
            cell.nameLabel.text = drugLog.eng_name
            cell.quantityLabel.text = "\(drugLog.x_val!)\(drugLog.y_val!)"
        }
        return cell
    }
    
    // MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

extension LogGroupTableCell {
    private func setupLayoutStyles() {
        backgroundColor = UIColor.clear
    }
    
    private func setupLayoutSubviews() {
        addSubview(containerView)
        
        containerView.addSubview(arrowImageView)
        containerView.addSubview(groupTypeImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(condScoreLabel)
        containerView.addSubview(foodLogBulletView)
        containerView.addSubview(actLogBulletView)
        containerView.addSubview(drugLogBulletView)
        containerView.addSubview(groupOfLogsTableView)
    }
    
    private func setupLayoutConstraints() {
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        containerViewHight = containerView.heightAnchor.constraint(equalToConstant: 45)
        containerViewHight.priority = UILayoutPriority(rawValue: 999)
        containerViewHight.isActive = true
        
        arrowImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        arrowImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        
        groupTypeImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6).isActive = true
        groupTypeImageView.leadingAnchor.constraint(equalTo: arrowImageView.trailingAnchor, constant: frame.width / 5).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        
        foodLogBulletView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        foodLogBulletView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        foodLogBulletView.widthAnchor.constraint(equalToConstant: 7).isActive = true
        foodLogBulletView.heightAnchor.constraint(equalToConstant: 7).isActive = true
        
        actLogBulletView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        actLogBulletView.trailingAnchor.constraint(equalTo: foodLogBulletView.leadingAnchor, constant: -5).isActive = true
        actLogBulletView.widthAnchor.constraint(equalToConstant: 7).isActive = true
        actLogBulletView.heightAnchor.constraint(equalToConstant: 7).isActive = true
        
        drugLogBulletView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        drugLogBulletView.trailingAnchor.constraint(equalTo: actLogBulletView.leadingAnchor, constant: -5).isActive = true
        drugLogBulletView.widthAnchor.constraint(equalToConstant: 7).isActive = true
        drugLogBulletView.heightAnchor.constraint(equalToConstant: 7).isActive = true
        
        groupOfLogsTableView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 45).isActive = true
        groupOfLogsTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        groupOfLogsTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12).isActive = true
        groupOfLogsTableHeight = groupOfLogsTableView.heightAnchor.constraint(equalToConstant: 40)
        groupOfLogsTableHeight.priority = UILayoutPriority(rawValue: 999)
        groupOfLogsTableHeight.isActive = true
    }
}
