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
    var myRankingView: UIView!
    
    // UITableView
    var rankingTableView: UITableView!
    
    // UIPickerView
    var ageRangePickerView: UIPickerView!
    var startPtPickerView: UIPickerView!
    
    // UIButton
    var homeButton: UIButton!
    var ageRangePickButton: UIButton!
    var startPtPickButton: UIButton!
    
    // UILabel
    var headerRankLabel: UILabel!
    
    // Non-view properties
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    
//    var myRanking:
    var rankings: [CustomModel.Ranking]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
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
    
    @objc func alertAgeRanePicker() {
        let alert = UIAlertController(title: lang.titleCondScore, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
//        if let condScore = selectedLogGroup?.cond_score {
//            condScorePickerView.selectRow(10 - condScore, inComponent: 0, animated: false)
//        } else {
//            condScorePickerView.selectRow(3, inComponent: 0, animated: false)
//            selectedCondScore = 7
//        }
//        alert.view.addSubview(condScorePickerView)
//        condScorePickerView.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: 0).isActive = true
//        alert.addAction(UIAlertAction(title: lang.titleClose, style: .cancel) { _ in })
//        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
//            self.updateLogGroupCondScore()
//        })
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
        let year = ranking.full_lifespan / 365
        let days = ranking.full_lifespan % 365
        cell.lifespanLabel.text = "\(year)Y \(days)D"
        
        if ranking.rank_num <= 100 {
            cell.rankNumLabel.textColor = .dodgerBlue
            cell.nameLabel.textColor = .dodgerBlue
            cell.lifespanLabel.textColor = .dodgerBlue
        } else if ranking.rank_num <= 200 {
            cell.rankNumLabel.textColor = .mediumSeaGreen
            cell.nameLabel.textColor = .mediumSeaGreen
            cell.lifespanLabel.textColor = .mediumSeaGreen
        } else if ranking.rank_num <= 300 {
           cell.rankNumLabel.textColor = .webOrange
           cell.nameLabel.textColor = .webOrange
           cell.lifespanLabel.textColor = .webOrange
        } else if ranking.rank_num <= 300 {
            cell.rankNumLabel.textColor = .webOrange
            cell.nameLabel.textColor = .webOrange
            cell.lifespanLabel.textColor = .webOrange
        } else if ranking.rank_num <= 400 {
           cell.rankNumLabel.textColor = .tomato
           cell.nameLabel.textColor = .tomato
           cell.lifespanLabel.textColor = .tomato
        } else if ranking.rank_num <=  500 {
            cell.rankNumLabel.textColor = .hex_a45fac
            cell.nameLabel.textColor = .hex_a45fac
            cell.lifespanLabel.textColor = .hex_a45fac
        } else {
            cell.rankNumLabel.textColor = .dimGray
            cell.nameLabel.textColor = .dimGray
            cell.lifespanLabel.textColor = .dimGray
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
}

//extension RankingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        <#code#>
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if pickerView == startPtPickerView {
//
//        } else if pickerView == ageRangePickerView {
//           let label = UILabel(frame: CGRect(x: pickerView.bounds.midX - 15, y: 0, width: 20, height: 40))
//           label.textAlignment = .center
//           label.text = "\(condScores[9 - row])"
//           return label
//       } else {
//           fatalError()
//       }
//    }
//}

extension RankingViewController {
    private func setupLayout() {
        // Initialize view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = .whiteSmoke
        
        homeButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemHome.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(homeButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        myRankingView = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10.0
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        headerRankLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 14, weight: .regular)
            _label.textAlignment = .left
            _label.textColor = .lightGray
            _label.text = "#Ranking"
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
        ageRangePickButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.black, for: .normal)
            _button.setTitle("All Age", for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 15)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(alertAgeRanePicker), for: .touchUpInside)
            _button.backgroundColor = .white
            _button.layer.cornerRadius = 10.0
            _button.addShadowView()
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        startPtPickButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(.black, for: .normal)
            _button.setTitle("#1 ~ ", for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 15)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(alertAgeRanePicker), for: .touchUpInside)
            _button.backgroundColor = .white
            _button.layer.cornerRadius = 10.0
            _button.addShadowView()
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeButton)
        rankingTableView.dataSource = self
        rankingTableView.delegate = self
        
        // Setup subviews
        view.addSubview(myRankingView)
        view.addSubview(ageRangePickButton)
        view.addSubview(startPtPickButton)
        view.addSubview(headerRankLabel)
        view.addSubview(rankingTableView)
        
        // Setup constraints
        myRankingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        myRankingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        myRankingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        myRankingView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        ageRangePickButton.topAnchor.constraint(equalTo: myRankingView.bottomAnchor, constant: 7).isActive = true
        ageRangePickButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        ageRangePickButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 10.5).isActive = true
        ageRangePickButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        startPtPickButton.topAnchor.constraint(equalTo: myRankingView.bottomAnchor, constant: 7).isActive = true
        startPtPickButton.leadingAnchor.constraint(equalTo: ageRangePickButton.trailingAnchor, constant: 7).isActive = true
        startPtPickButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 10.5).isActive = true
        startPtPickButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        headerRankLabel.topAnchor.constraint(equalTo: ageRangePickButton.bottomAnchor, constant: 10).isActive = true
        headerRankLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        
        rankingTableView.topAnchor.constraint(equalTo: headerRankLabel.bottomAnchor, constant: 0).isActive = true
        rankingTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        rankingTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        rankingTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    private func loadRankings() {
        let service = Service(lang: lang)
        service.getRankings(ageRange: 1, startPoint: 1, popoverAlert: { (message) in
            self.retryFunction = self.loadRankings
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadRankings()
        }) { (rankingSet) in
            self.rankings = rankingSet.rankings
            self.rankingTableView.reloadData()
        }
    }
}
