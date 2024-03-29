//
//  RankingController.swift
//  Dymm
//
//  Created by Eido Goya on 2019/10/31.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit
import Alamofire

class RankingViewController: UIViewController {
    
    // MARK: - Properties
    
    // UIView
    var myRankingContainer: UIView!
    var myYearsBarBg: UIView!
    var myYearsBar: UIView!
    var myDaysBarBg: UIView!
    var myDaysBar: UIView!
    
    // UITableView
    var rankingTableView: UITableView!
    
    // UIPickerView
    var ageGroupPickerView: UIPickerView!
    var startingPickerView: UIPickerView!
    
    // UIButton
    var ageGroupPickButton: UIButton!
    var startingPickButton: UIButton!
    
    // UILabel
    var headerRankLabel: UILabel!
    var headerHPLabel: UILabel!
    var myProfileImgLabel: UILabel!
    var myRankNumLabel: UILabel!
    var myNameLabel: UILabel!
    var myYearsLabel: UILabel!
    var myDaysLabel: UILabel!
    
    // UIImageView
    var myProfileImgView: UIImageView!
    
    // Constraint
    var myYearsBarWidth: NSLayoutConstraint!
    var myDaysBarWidth: NSLayoutConstraint!
    
    // Non-view properties
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    
    var rankings: [CustomModel.Ranking]?
    var lastContentOffset: CGFloat = 0.0
    var isScrollToLoading: Bool = false
    var currPageNum: Int = 1
    var minimumCnt: Int = 20
    
    var startingPickKeys = [1, 2, 3, 4]
    var ageGroupPickKeys = [1, 2, 3, 4, 5]
    var selectedStartingKey = 1
    var selectedAgeGroupKey = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadMyRanking()
        loadRankings()
    }
    
    // MARK: - Actions
    
    @objc func alertError(_ message: String) {
        view.hideSpinner()
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lang.titleYes, style: .default) { _ in
            self.retryFunction!()
        })
        alert.addAction(UIAlertAction(title: lang.titleNo, style: .cancel) { _ in })
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertStartingPointPicker() {
        let alert = UIAlertController(title: lang.titleStartingPoint, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        startingPickerView.selectRow(selectedStartingKey - 1, inComponent: 0, animated: false)
        alert.view.addSubview(startingPickerView)
        startingPickerView.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
            self.startingPickButton.setTitle(LangHelper.getStartingPickName(key: self.selectedStartingKey), for: .normal)
            self.currPageNum = 1
            self.minimumCnt = 20
            self.isScrollToLoading = false
            self.lastContentOffset = 0.0
            self.loadRankings()
        })
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil )
    }
    
    @objc func alertAgeGroupPicker() {
        let alert = UIAlertController(title: lang.titleAgeGroup, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        ageGroupPickerView.selectRow(selectedAgeGroupKey - 1, inComponent: 0, animated: false)
        alert.view.addSubview(ageGroupPickerView)
        ageGroupPickerView.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
            switch self.lang.currentLanguageId {
            case LanguageId.eng:
                self.ageGroupPickButton.setTitle(LangHelper.getAgeGroupEngPickName(key: self.selectedAgeGroupKey), for: .normal)
            case LanguageId.kor:
                self.ageGroupPickButton.setTitle(LangHelper.getAgeGroupKorPickName(key: self.selectedAgeGroupKey), for: .normal)
            default: fatalError()}
            self.loadMyRanking()
            self.currPageNum = 1
            self.minimumCnt = 20
            self.isScrollToLoading = false
            self.lastContentOffset = 0.0
            self.loadRankings()
        })
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil )
    }
}

extension RankingViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRows = rankings?.count else {
            return 0
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: rankingTableCellId, for: indexPath) as? RankingTableCell else {
            fatalError()
        }
        let ranking = rankings![indexPath.row]
        if ranking.photo_name != nil && ranking.color_code == 0 {
            cell.profileImgView.backgroundColor = .clear
            cell.profileImgView.image = nil
            cell.profileImgLabel.textColor = .clear
            let url = "\(URI.host)\(URI.avatar)/\(ranking.avatar_id)/profile/photo/\(ranking.photo_name!)"
            Alamofire.request(url).responseImage { response in
                if let data = response.data {
                    cell.profileImgView.image = UIImage(data: data)
                }
            }
        } else {
            let firstName = ranking.first_name
            let index = firstName.index(firstName.startIndex, offsetBy: 0)
            cell.profileImgLabel.text = String(firstName[index].uppercased())
            cell.profileImgLabel.textColor = .white
            cell.profileImgView.backgroundColor = getProfileUIColor(key: ranking.color_code)
            cell.profileImgView.image = nil
        }
        cell.rankNumLabel.text = "#\(ranking.rank_num)"
        cell.nameLabel.text = "\(ranking.first_name) \(ranking.last_name)"
        if let fullLifespan = ranking.full_lifespan {
            let year = fullLifespan / 365
            let days = fullLifespan % 365
            switch self.lang.currentLanguageId {
            case LanguageId.eng:
                cell.yearsLabel.text = "\(year)Y"
                cell.daysLabel.text = "\(days)D"
            case LanguageId.kor:
                cell.yearsLabel.text = "\(year)년"
                cell.daysLabel.text = "\(days)일"
            default: fatalError()}
            cell.yearsBarWidth.constant = CGFloat(year)
            cell.daysBarWidth.constant = CGFloat((days * 50) / 365)
        } else {
            cell.yearsLabel.text = " "
            cell.daysLabel.text = " "
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let _rankings = rankings else {
            return
        }
        
        if lastContentOffset > scrollView.contentOffset.y {
            // If scolled up
            return
        }
        if scrollView.contentSize.height < 0 {
            // If view did initialized
            return
        } else {
            lastContentOffset = scrollView.contentOffset.y
        }
        if (scrollView.frame.size.height + scrollView.contentOffset.y) > (scrollView.contentSize.height - 70) {
            if _rankings.count == minimumCnt {
                isScrollToLoading = true
                currPageNum += 1
                minimumCnt += 20
                loadRankings()
            }
        }
    }
}

extension RankingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case startingPickerView:
            return startingPickKeys.count
        case ageGroupPickerView:
            return ageGroupPickKeys.count
        default:
            fatalError()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        switch pickerView {
        case startingPickerView:
            let label = UILabel(frame: CGRect(x: pickerView.bounds.midX - 15, y: 0, width: 150, height: 40))
            label.textAlignment = .center
            label.text = LangHelper.getStartingPickName(key: row + 1)
            return label
        case ageGroupPickerView:
            let label = UILabel(frame: CGRect(x: pickerView.bounds.midX - 15, y: 0, width: 150, height: 40))
            label.textAlignment = .center
            switch self.lang.currentLanguageId {
            case LanguageId.eng:
                label.text = LangHelper.getAgeGroupEngPickName(key: row + 1)
            case LanguageId.kor:
                label.text = LangHelper.getAgeGroupKorPickName(key: row + 1)
            default: fatalError()}
            return label
        default:
            fatalError()
        }
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case startingPickerView:
            selectedStartingKey = startingPickKeys[row]
        case ageGroupPickerView:
            selectedAgeGroupKey = ageGroupPickKeys[row]
        default:
            fatalError()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}

extension RankingViewController {
    private func setupLayout() {
        // Initialize view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = .whiteSmoke
        navigationItem.title = lang.titleRanking.uppercased()
        
        myRankingContainer = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10.0
            _view.addShadowView()
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        headerRankLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .left
            _label.textColor = .green_3ED6A7
            _label.text = "#\(lang.titleRanking!)"
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        headerHPLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .right
            _label.textColor = .green_3ED6A7
            _label.text = lang.titleReLifespanAndAge
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        rankingTableView = {
            let _tableView = UITableView(frame: CGRect.zero, style: .grouped)
            _tableView.backgroundColor = .clear
            _tableView.separatorStyle = .none
            _tableView.register(RankingTableCell.self, forCellReuseIdentifier: rankingTableCellId)
            _tableView.translatesAutoresizingMaskIntoConstraints = false
            return _tableView
        }()
        ageGroupPickButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.green_3ED6A7, for: .normal)
            switch self.lang.currentLanguageId {
            case LanguageId.eng:
                _button.setTitle(LangHelper.getAgeGroupEngPickName(key: self.selectedAgeGroupKey), for: .normal)
            case LanguageId.kor:
                _button.setTitle(LangHelper.getAgeGroupKorPickName(key: self.selectedAgeGroupKey), for: .normal)
            default: fatalError()}
            _button.titleLabel?.font = .systemFont(ofSize: 15)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(alertAgeGroupPicker), for: .touchUpInside)
            _button.backgroundColor = .white
            _button.layer.cornerRadius = 10.0
            _button.addShadowView()
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        startingPickButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.green_3ED6A7, for: .normal)
            _button.setTitle(LangHelper.getStartingPickName(key: selectedStartingKey), for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 15)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(alertStartingPointPicker), for: .touchUpInside)
            _button.backgroundColor = .white
            _button.layer.cornerRadius = 10.0
            _button.addShadowView()
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        myProfileImgView = {
            let _imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 31, height: 31))
            _imageView.layer.cornerRadius = 31 / 2
            _imageView.contentMode = .scaleAspectFill
            _imageView.clipsToBounds = true
            _imageView.isUserInteractionEnabled = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        myProfileImgLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 17, weight: .medium)
            _label.textColor = .white
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        myRankNumLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .left
            _label.textColor = .dimGray
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        myNameLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .left
            _label.textColor = .dimGray
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        myYearsLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .right
            _label.textColor = .dimGray
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        myDaysLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 9, weight: .regular)
            _label.textAlignment = .right
            _label.textColor = .dimGray
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        startingPickerView = {
            let _pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        ageGroupPickerView = {
            let _pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        myYearsBarBg = {
            let _view = UIView()
            _view.backgroundColor = UIColor(hex: "#CBF5E8")
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        myYearsBar = {
            let _view = UIView()
            _view.backgroundColor = .green_3ED6A7
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        myDaysBarBg = {
            let _view = UIView()
            _view.backgroundColor = UIColor(hex: "#CBF5E8")
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        myDaysBar = {
            let _view = UIView()
            _view.backgroundColor = .green_3ED6A7
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        
        rankingTableView.dataSource = self
        rankingTableView.delegate = self
        startingPickerView.dataSource = self
        startingPickerView.delegate = self
        ageGroupPickerView.dataSource = self
        ageGroupPickerView.delegate = self
        
        // Setup subviews
        view.addSubview(myRankingContainer)
        view.addSubview(ageGroupPickButton)
        view.addSubview(startingPickButton)
        view.addSubview(headerRankLabel)
        view.addSubview(headerHPLabel)
        view.addSubview(rankingTableView)
        
        myRankingContainer.addSubview(myProfileImgView)
        myRankingContainer.addSubview(myProfileImgLabel)
        myRankingContainer.addSubview(myRankNumLabel)
        myRankingContainer.addSubview(myNameLabel)
        myRankingContainer.addSubview(myYearsLabel)
        myRankingContainer.addSubview(myDaysLabel)
        myRankingContainer.addSubview(myYearsBarBg)
        myRankingContainer.addSubview(myYearsBar)
        myRankingContainer.addSubview(myDaysBarBg)
        myRankingContainer.addSubview(myDaysBar)
        
        // Setup constraints
        myRankingContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        myRankingContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        myRankingContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        myRankingContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        myProfileImgView.centerYAnchor.constraint(equalTo: myRankingContainer.centerYAnchor, constant: 0).isActive = true
        myProfileImgView.leadingAnchor.constraint(equalTo: myRankingContainer.leadingAnchor, constant: 20).isActive = true
        myProfileImgView.widthAnchor.constraint(equalToConstant: 31).isActive = true
        myProfileImgView.heightAnchor.constraint(equalToConstant: 31).isActive = true
        
        myProfileImgLabel.centerXAnchor.constraint(equalTo: myProfileImgView.centerXAnchor, constant: 0).isActive = true
        myProfileImgLabel.centerYAnchor.constraint(equalTo: myProfileImgView.centerYAnchor, constant: 0).isActive = true
        
        myRankNumLabel.centerYAnchor.constraint(equalTo: myRankingContainer.centerYAnchor, constant: -10).isActive = true
        myRankNumLabel.leadingAnchor.constraint(equalTo: myProfileImgView.trailingAnchor, constant: 10).isActive = true
        
        myNameLabel.topAnchor.constraint(equalTo: myRankNumLabel.bottomAnchor, constant: 2).isActive = true
        myNameLabel.leadingAnchor.constraint(equalTo: myProfileImgView.trailingAnchor, constant: 10).isActive = true
        
        myYearsBarBg.topAnchor.constraint(equalTo: myRankingContainer.topAnchor, constant: 10).isActive = true
        myYearsBarBg.trailingAnchor.constraint(equalTo: myRankingContainer.trailingAnchor, constant: -10).isActive = true
        myYearsBarBg.heightAnchor.constraint(equalToConstant: 11).isActive = true
        myYearsBarBg.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        myYearsBar.topAnchor.constraint(equalTo: myRankingContainer.topAnchor, constant: 10).isActive = true
        myYearsBar.trailingAnchor.constraint(equalTo: myRankingContainer.trailingAnchor, constant: -10).isActive = true
        myYearsBar.heightAnchor.constraint(equalToConstant: 11).isActive = true
        myYearsBarWidth = myYearsBar.widthAnchor.constraint(equalToConstant: 1)
        myYearsBarWidth.priority = UILayoutPriority(rawValue: 999)
        myYearsBarWidth.isActive = true
        
        myDaysBarBg.topAnchor.constraint(equalTo: myYearsBar.bottomAnchor, constant: 1).isActive = true
        myDaysBarBg.trailingAnchor.constraint(equalTo: myRankingContainer.trailingAnchor, constant: -10).isActive = true
        myDaysBarBg.heightAnchor.constraint(equalToConstant: 7).isActive = true
        myDaysBarBg.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        myDaysBar.topAnchor.constraint(equalTo: myYearsBar.bottomAnchor, constant: 1).isActive = true
        myDaysBar.trailingAnchor.constraint(equalTo: myRankingContainer.trailingAnchor, constant: -10).isActive = true
        myDaysBar.heightAnchor.constraint(equalToConstant: 7).isActive = true
        myDaysBarWidth = myDaysBar.widthAnchor.constraint(equalToConstant: 1)
        myDaysBarWidth.priority = UILayoutPriority(rawValue: 999)
        myDaysBarWidth.isActive = true
        
        myYearsLabel.topAnchor.constraint(equalTo: myDaysBar.bottomAnchor, constant: 1).isActive = true
        myYearsLabel.trailingAnchor.constraint(equalTo: myRankingContainer.trailingAnchor, constant: -10).isActive = true
        
        myDaysLabel.topAnchor.constraint(equalTo: myYearsLabel.bottomAnchor, constant: 0).isActive = true
        myDaysLabel.trailingAnchor.constraint(equalTo: myRankingContainer.trailingAnchor, constant: -10).isActive = true
        
        ageGroupPickButton.topAnchor.constraint(equalTo: myRankingContainer.bottomAnchor, constant: 7).isActive = true
        ageGroupPickButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        ageGroupPickButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 10.5).isActive = true
        ageGroupPickButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        startingPickButton.topAnchor.constraint(equalTo: myRankingContainer.bottomAnchor, constant: 7).isActive = true
        startingPickButton.leadingAnchor.constraint(equalTo: ageGroupPickButton.trailingAnchor, constant: 7).isActive = true
        startingPickButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 10.5).isActive = true
        startingPickButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        headerRankLabel.topAnchor.constraint(equalTo: ageGroupPickButton.bottomAnchor, constant: 15).isActive = true
        headerRankLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50).isActive = true
        
        headerHPLabel.topAnchor.constraint(equalTo: ageGroupPickButton.bottomAnchor, constant: 15).isActive = true
        headerHPLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25).isActive = true
        
        rankingTableView.topAnchor.constraint(equalTo: headerRankLabel.bottomAnchor, constant: 8).isActive = true
        rankingTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        rankingTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        rankingTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    private func loadRankings() {
        view.showSpinner()
        let service = Service(lang: lang)
        service.getRankings(ageRange: selectedAgeGroupKey, startPoint: selectedStartingKey, pageNum: currPageNum, popoverAlert: { (message) in
            self.retryFunction = self.loadRankings
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadRankings()
        }) { (rankingSet) in
            if self.isScrollToLoading {
                let newRankings = rankingSet.rankings
                self.isScrollToLoading = false
                if newRankings.count > 0 {
                    self.rankings!.append(contentsOf: newRankings)
                    self.rankingTableView.reloadData()
                }
                self.view.hideSpinner()
                return
            }
            self.rankings = rankingSet.rankings
            self.rankingTableView.reloadData()
            self.view.hideSpinner()
        }
    }
    
    private func loadMyRanking() {
        let service = Service(lang: lang)
        service.getARanking(ageRange: selectedAgeGroupKey, popoverAlert: { (message) in
            self.retryFunction = self.loadMyRanking
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadMyRanking()
        }) { (ranking) in
            if ranking.photo_name != nil && ranking.color_code == 0 {
                let url = "\(URI.host)\(URI.avatar)/\(ranking.avatar_id)/profile/photo/\(ranking.photo_name!)"
                Alamofire.request(url).responseImage { response in
                    if let data = response.data {
                        self.myProfileImgView.image = UIImage(data: data)
                        UIView.transition(with: self.myProfileImgLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            self.myProfileImgLabel.textColor = .clear
                        })
                    }
                }
            } else {
                let firstName = ranking.first_name
                let index = firstName.index(firstName.startIndex, offsetBy: 0)
                self.myProfileImgLabel.text = String(firstName[index].uppercased())
                self.myProfileImgLabel.textColor = .white
                self.myProfileImgView.backgroundColor = getProfileUIColor(key: ranking.color_code)
            }
            self.myRankNumLabel.text = "#\(ranking.rank_num)"
            self.myNameLabel.text = "\(ranking.first_name) \(ranking.last_name)"
            
            if let fullLifespan = ranking.full_lifespan {
                let year = fullLifespan / 365
                let days = fullLifespan % 365
                switch self.lang.currentLanguageId {
                case LanguageId.eng:
                    self.myYearsLabel.text = "\(year)Y"
                    self.myDaysLabel.text = "\(days)D"
                case LanguageId.kor:
                    self.myYearsLabel.text = "\(year)년"
                    self.myDaysLabel.text = "\(days)일"
                default: fatalError()}
                self.myYearsBarWidth.constant = CGFloat(year)
                self.myDaysBarWidth.constant = CGFloat((days * 50) / 365)
            } else {
                self.myYearsLabel.text = " "
                self.myDaysLabel.text = " "
            }
            var myColor = UIColor.dimGray
            if ranking.rank_num > 0 {
                myColor = .green_3ED6A7
            }
            UIView.animate(withDuration: 0.5) {
                self.myRankNumLabel.textColor = myColor
                self.myNameLabel.textColor = myColor
                self.myYearsLabel.textColor = myColor
                self.myDaysLabel.textColor = myColor
                self.myYearsBarBg.backgroundColor = myColor.withAlphaComponent(0.37)
                self.myDaysBarBg.backgroundColor = myColor.withAlphaComponent(0.37)
                self.myYearsBar.backgroundColor = myColor.withAlphaComponent(0.8)
                self.myDaysBar.backgroundColor = myColor.withAlphaComponent(0.8)
                self.myRankingContainer.isHidden = false
            }
        }
    }
}
