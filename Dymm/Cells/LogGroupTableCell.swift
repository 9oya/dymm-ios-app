//
//  LogGroupTableCell.swift
//  Dymm
//
//  Created by eunsang lee on 28/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

private let logTableCellId = "LogTableCell"
private let logTableCellHeightVal = 45

class LogGroupTableCell: UITableViewCell {
    var containerView: UIView!
    var containerViewHight: NSLayoutConstraint!
    var arrowImageView: UIImageView!
    var groupTypeImageView: UIImageView!
    var condScoreImageView: UIImageView!
    var nameLabel: UILabel!
    var foodLogBulletView: UIView!
    var actLogBulletView: UIView!
    var drugLogBulletView: UIView!
    var groupOfLogsTableView: UITableView!
    var groupOfLogsTableHeight: NSLayoutConstraint!
    var condScoreButton: UIButton!
    var editButton: UIButton!
    
    var lang: LangPack!
    var selectedLogGroup: BaseModel.LogGroup?
    var selectedLogGroupId: Int?
    var groupOfLogSet: CustomModel.GroupOfLogSet?
    var isEditBtnTapped: Bool = false
    var isDoneBtnTapped: Bool = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: logTableCellId, for: indexPath) as? LogTableCell else {
            fatalError()
        }
        if ((groupOfLogSet!.food_logs?.count) != nil && ((groupOfLogSet!.food_logs?.count)!) > 0) {
            let foodLog = groupOfLogSet!.food_logs!.popLast()
            cell.bulletView.backgroundColor = UIColor.tomato
            switch lang.currentLanguageId {
            case LanguageId.eng: cell.nameLabel.text = foodLog!.eng_name
            case LanguageId.kor: cell.nameLabel.text = foodLog!.kor_name
            case LanguageId.jpn: cell.nameLabel.text = foodLog!.jpn_name
            default: fatalError()}
            var x_val = ""
            if foodLog!.x_val! > 0 {
                x_val = "\(foodLog!.x_val!)"
            }
            if foodLog!.y_val == 0 {
                cell.quantityLabel.text = "\(x_val)"
            } else if foodLog!.y_val == 1 {
                cell.quantityLabel.text = "\(x_val)¼"
            } else if foodLog!.y_val == 2 {
                cell.quantityLabel.text = "\(x_val)½"
            } else if foodLog!.y_val == 3 {
                cell.quantityLabel.text = "\(x_val)¾"
            }
        } else if ((groupOfLogSet!.act_logs?.count) != nil && ((groupOfLogSet!.act_logs?.count)!) > 0) {
            let actLog = groupOfLogSet!.act_logs!.popLast()
            cell.bulletView.backgroundColor = UIColor.cornflowerBlue
            switch lang.currentLanguageId {
            case LanguageId.eng: cell.nameLabel.text = actLog!.eng_name
            case LanguageId.kor: cell.nameLabel.text = actLog!.kor_name
            case LanguageId.jpn: cell.nameLabel.text = actLog!.jpn_name
            default: fatalError()}
            var hr = ""
            var min = ""
            if actLog!.x_val! > 0 {
                hr = "\(actLog!.x_val!)hr"
            }
            if actLog!.y_val != 0 {
                min = " \(actLog!.y_val!)min"
            }
            cell.quantityLabel.text = "\(hr)\(min)"
        } else if ((groupOfLogSet!.drug_logs?.count) != nil && ((groupOfLogSet!.drug_logs?.count)!) > 0) {
            let drugLog = groupOfLogSet!.drug_logs!.popLast()
            cell.bulletView.backgroundColor = UIColor.hex_72e5Ea
            switch lang.currentLanguageId {
            case LanguageId.eng: cell.nameLabel.text = drugLog!.eng_name
            case LanguageId.kor: cell.nameLabel.text = drugLog!.kor_name
            case LanguageId.jpn: cell.nameLabel.text = drugLog!.jpn_name
            default: fatalError()}
            var x_val = ""
            if drugLog!.x_val! > 0 {
                x_val = "\(drugLog!.x_val!)"
            }
            if drugLog!.y_val == 0 {
                cell.quantityLabel.text = "\(x_val)"
            } else if drugLog!.y_val == 1 {
                cell.quantityLabel.text = "\(x_val)¼"
            } else if drugLog!.y_val == 2 {
                cell.quantityLabel.text = "\(x_val)½"
            } else if drugLog!.y_val == 3 {
                cell.quantityLabel.text = "\(x_val)¾"
            }
        }
        if self.isEditBtnTapped {
            cell.nameLabel.textColor = UIColor.lightGray
            cell.quantityLabel.isHidden = true
            cell.removeButton.isHidden = false
        } else {
            cell.nameLabel.textColor = UIColor.black
            cell.quantityLabel.isHidden = false
            cell.removeButton.isHidden = true
        }
        return cell
    }
    
    // MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(logTableCellHeightVal)
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
    private func setupLayout() {
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        
        containerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        arrowImageView = {
            let _imageView = UIImageView()
            _imageView.image = UIImage(named: "item-poly-left")
            _imageView.contentMode = .scaleAspectFit
            _imageView.isHidden = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        groupTypeImageView = {
            let _imageView = UIImageView()
            _imageView.contentMode = .scaleAspectFit
            _imageView.addShadowView()
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        condScoreImageView = {
            let _imageView = UIImageView()
            _imageView.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
            _imageView.contentMode = .scaleAspectFit
            _imageView.addShadowView()
            _imageView.isHidden = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        condScoreButton = {
            let _button = UIButton(frame: CGRect(x: 0, y: 0, width: 21, height: 21))
            _button.addShadowView()
            _button.showsTouchWhenHighlighted = true
            _button.isHidden = true
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        editButton = {
            let _button = UIButton()
            _button.setTitle(lang.btnEdit, for: .normal)
            _button.setTitleColor(UIColor.lightGray, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 15)
//            _button.addShadowView()
            _button.showsTouchWhenHighlighted = true
            _button.isHidden = true
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        nameLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15)
            _label.textAlignment = .left
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        foodLogBulletView = {
            let _view = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
            _view.backgroundColor = UIColor.tomato
            _view.layer.cornerRadius = 3.5
            _view.isHidden = true
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        actLogBulletView = {
            let _view = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
            _view.backgroundColor = UIColor.cornflowerBlue
            _view.layer.cornerRadius = 3.5
            _view.isHidden = true
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        drugLogBulletView = {
            let _view = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 7))
            _view.backgroundColor = UIColor.hex_72e5Ea
            _view.layer.cornerRadius = 3.5
            _view.isHidden = true
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        groupOfLogsTableView = {
            let _tableView = UITableView(frame: CGRect.zero, style: .plain)
            _tableView.register(LogTableCell.self, forCellReuseIdentifier: logTableCellId)
            _tableView.backgroundColor = UIColor.clear
            _tableView.separatorStyle = .singleLine
            _tableView.isScrollEnabled = false
            _tableView.isHidden = true
            _tableView.translatesAutoresizingMaskIntoConstraints = false
            return _tableView
        }()
        
        groupOfLogsTableView.delegate = self
        groupOfLogsTableView.dataSource = self
        
        addSubview(containerView)
        containerView.addSubview(arrowImageView)
        containerView.addSubview(groupTypeImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(condScoreImageView)
        containerView.addSubview(foodLogBulletView)
        containerView.addSubview(actLogBulletView)
        containerView.addSubview(drugLogBulletView)
        containerView.addSubview(groupOfLogsTableView)
        containerView.addSubview(condScoreButton)
        containerView.addSubview(editButton)
        
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        containerViewHight = containerView.heightAnchor.constraint(equalToConstant: 45)
        containerViewHight.priority = UILayoutPriority(rawValue: 999)
        containerViewHight.isActive = true
        
        arrowImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        arrowImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        
        groupTypeImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6).isActive = true
        groupTypeImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: frame.width / 4).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        
        condScoreImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12).isActive = true
        condScoreImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -((frame.width / 4) + 10)).isActive = true
        
        editButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        
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
        groupOfLogsTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        groupOfLogsTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -22).isActive = true
        groupOfLogsTableHeight = groupOfLogsTableView.heightAnchor.constraint(equalToConstant: 40)
        groupOfLogsTableHeight.priority = UILayoutPriority(rawValue: 999)
        groupOfLogsTableHeight.isActive = true
        
        condScoreButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        condScoreButton.topAnchor.constraint(equalTo: groupOfLogsTableView.bottomAnchor, constant: 15).isActive = true
    }
    
    func editButtonTapped() {
        editButton.setTitle(lang.btnDone, for: .normal)
        editButton.setTitleColor(UIColor.tomato, for: .normal)
        isEditBtnTapped = true
        isDoneBtnTapped = false
        groupOfLogsTableView.reloadData()
        groupOfLogsTableView.beginUpdates()
        groupOfLogsTableView.endUpdates()
    }
    
    func doneButtonTapped() {
        editButton.setTitle(lang.btnEdit, for: .normal)
        editButton.setTitleColor(UIColor.lightGray, for: .normal)
        isEditBtnTapped = false
        isDoneBtnTapped = true
        groupOfLogsTableView.reloadData()
        groupOfLogsTableView.beginUpdates()
        groupOfLogsTableView.endUpdates()
    }
}
