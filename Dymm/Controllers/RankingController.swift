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
    
    // UITableView
    var rankingTableView: UITableView!
    
    // UIPickerView
    var ageGroupPickerView: UIPickerView!
    var startingPickerView: UIPickerView!
    
    // UIButton
    var homeButton: UIButton!
    var ageGroupPickButton: UIButton!
    var startingPickButton: UIButton!
    
    // UILabel
    var headerRankLabel: UILabel!
    var headerLifespanLabel: UILabel!
    var myProfileImgLabel: UILabel!
    var myRankNumLabel: UILabel!
    var myNameLabel: UILabel!
    var myLifespanLabel: UILabel!
    
    // UIImageView
    var loadingImageView: UIImageView!
    var myProfileImgView: UIImageView!
    
    // Non-view properties
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    
//    var myRanking:
    var rankings: [CustomModel.Ranking]?
    var lastContentOffset: CGFloat = 0.0
    var isScrollToLoading: Bool = false
    var currPageNum: Int = 1
    var minimumCnt: Int = 15
    
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
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lang.titleYes, style: .default) { _ in
            self.retryFunction!()
        })
        alert.addAction(UIAlertAction(title: lang.titleNo, style: .cancel) { _ in })
        alert.view.tintColor = .mediumSeaGreen
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertStartingPicker() {
        let alert = UIAlertController(title: lang.titleStartingPoint, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        startingPickerView.selectRow(selectedStartingKey - 1, inComponent: 0, animated: false)
        alert.view.addSubview(startingPickerView)
        startingPickerView.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleClose, style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
            self.startingPickButton.setTitle(LangHelper.getStartingPickName(key: self.selectedStartingKey), for: .normal)
            self.loadRankings()
        })
        alert.view.tintColor = .mediumSeaGreen
        self.present(alert, animated: true, completion: nil )
    }
    
    @objc func alertAgeGroupPicker() {
        let alert = UIAlertController(title: lang.titleAgeGroup, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        ageGroupPickerView.selectRow(selectedAgeGroupKey - 1, inComponent: 0, animated: false)
        alert.view.addSubview(ageGroupPickerView)
        ageGroupPickerView.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleClose, style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
            switch self.lang.currentLanguageId {
            case LanguageId.eng:
                self.ageGroupPickButton.setTitle(LangHelper.getAgeGroupEngPickName(key: self.selectedAgeGroupKey), for: .normal)
            case LanguageId.kor:
                self.ageGroupPickButton.setTitle(LangHelper.getAgeGroupKorPickName(key: self.selectedAgeGroupKey), for: .normal)
            default: fatalError()}
            self.loadMyRanking()
            self.loadRankings()
        })
        alert.view.tintColor = .mediumSeaGreen
        self.present(alert, animated: true, completion: nil )
    }
    
    @objc func homeButtonTapped() {
        dismiss(animated: true, completion: nil)
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
            let url = "\(URI.host)\(URI.avatar)/\(ranking.avatar_id)/profile/photo/\(ranking.photo_name!)"
            Alamofire.request(url).responseImage { response in
                if let data = response.data {
                    cell.profileImgView.image = UIImage(data: data)
                    UIView.transition(with: cell.profileImgLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        cell.profileImgLabel.textColor = .clear
                    })
                }
            }
        } else {
            let firstName = ranking.first_name
            let index = firstName.index(firstName.startIndex, offsetBy: 0)
            cell.profileImgLabel.text = String(firstName[index])
            cell.profileImgLabel.textColor = .white
            cell.profileImgView.backgroundColor = getProfileUIColor(key: ranking.color_code)
        }
        cell.rankNumLabel.text = "#\(ranking.rank_num)"
        cell.nameLabel.text = "\(ranking.first_name) \(ranking.last_name)"
        
        if let fullLifespan = ranking.full_lifespan {
            let year = fullLifespan / 365
            let days = fullLifespan % 365
            switch self.lang.currentLanguageId {
            case LanguageId.eng:
                cell.lifespanLabel.text = "\(year)Y \(days)D"
            case LanguageId.kor:
                cell.lifespanLabel.text = "\(year)년 \(days)일"
            default: fatalError()}
        } else {
            cell.lifespanLabel.text = " "
        }
        
        var color = UIColor.dimGray
        if ranking.rank_num <= 100 {
            color = .dodgerBlue
        } else if ranking.rank_num <= 200 {
            color = .mediumSeaGreen
        } else if ranking.rank_num <= 300 {
           color = .webOrange
        } else if ranking.rank_num <= 300 {
            color = .webOrange
        } else if ranking.rank_num <= 400 {
           color = .tomato
        } else if ranking.rank_num <=  500 {
            color = .hex_a45fac
        } else {
            color = .dimGray
        }
        cell.rankNumLabel.textColor = color
        cell.nameLabel.textColor = color
        cell.lifespanLabel.textColor = color
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
                minimumCnt += 15
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
        
        loadingImageView = getLoadingImageView(isHidden: false)
        homeButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemHome.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(homeButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        myRankingContainer = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10.0
            _view.layer.borderWidth = 1.0
            _view.layer.borderColor = UIColor.white.cgColor
            _view.addShadowView()
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        headerRankLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .left
            _label.textColor = .lightGray
            _label.text = "#\(lang.titleRanking!)"
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        headerLifespanLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .right
            _label.textColor = .lightGray
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
            _button.setTitleColor(.black, for: .normal)
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
            _button.setTitleColor(.black, for: .normal)
            _button.setTitle(LangHelper.getStartingPickName(key: selectedStartingKey), for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 15)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(alertStartingPicker), for: .touchUpInside)
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
        myLifespanLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeButton)
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
        view.addSubview(headerLifespanLabel)
        view.addSubview(rankingTableView)
        view.addSubview(loadingImageView)
        
        myRankingContainer.addSubview(myProfileImgView)
        myRankingContainer.addSubview(myProfileImgLabel)
        myRankingContainer.addSubview(myRankNumLabel)
        myRankingContainer.addSubview(myNameLabel)
        myRankingContainer.addSubview(myLifespanLabel)
        
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
        
        myLifespanLabel.centerYAnchor.constraint(equalTo: myRankingContainer.centerYAnchor, constant: 0).isActive = true
        myLifespanLabel.trailingAnchor.constraint(equalTo: myRankingContainer.trailingAnchor, constant: -10).isActive = true
        
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
        
        headerLifespanLabel.topAnchor.constraint(equalTo: ageGroupPickButton.bottomAnchor, constant: 15).isActive = true
        headerLifespanLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
        rankingTableView.topAnchor.constraint(equalTo: headerRankLabel.bottomAnchor, constant: 8).isActive = true
        rankingTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        rankingTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        rankingTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        loadingImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
    }
    
    private func loadRankings() {
        if loadingImageView.isHidden {
            UIView.transition(with: loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.loadingImageView.isHidden = false
            })
        }
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
                return
            }
            self.rankings = rankingSet.rankings
            self.rankingTableView.reloadData()
            
            UIView.transition(with: self.loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.loadingImageView.isHidden = true
            })
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
//                let url = "\(URI.host)\(URI.avatar)/\(ranking.avatar_id)/profile/photo/\(ranking.photo_name!)"
//                Alamofire.request(url).responseImage { response in
//                    if let data = response.data {
//                        self.myProfileImgView.image = UIImage(data: data)
//                        UIView.transition(with: self.myProfileImgLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
//                            self.myProfileImgLabel.textColor = .clear
//                        })
//                    }
//                }
            } else {
                let firstName = ranking.first_name
                let index = firstName.index(firstName.startIndex, offsetBy: 0)
                self.myProfileImgLabel.text = String(firstName[index])
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
                    self.myLifespanLabel.text = "\(year)Y \(days)D"
                case LanguageId.kor:
                    self.myLifespanLabel.text = "\(year)년 \(days)일"
                default: fatalError()}
            } else {
                self.myLifespanLabel.text = " "
            }
            var myColor = UIColor.dimGray
            if ranking.rank_num == 0 {
                myColor = .dimGray
            } else if ranking.rank_num <= 100 {
                myColor = .dodgerBlue
            } else if ranking.rank_num <= 200 {
                myColor = .mediumSeaGreen
            } else if ranking.rank_num <= 300 {
               myColor = .webOrange
            } else if ranking.rank_num <= 300 {
                myColor = .webOrange
            } else if ranking.rank_num <= 400 {
               myColor = .tomato
            } else if ranking.rank_num <=  500 {
                myColor = .hex_a45fac
            } else {
                myColor = .dimGray
            }
            UIView.animate(withDuration: 0.5) {
                self.myRankNumLabel.textColor = myColor
                self.myNameLabel.textColor = myColor
                self.myLifespanLabel.textColor = myColor
                self.myRankingContainer.layer.borderColor = myColor.cgColor
                self.myRankingContainer.isHidden = false
            }
        }
    }
}
