//
//  HomeController.swift
//  Flava
//
//  Created by eunsang lee on 17/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

private let bannerHeightInt = 250
let marginInt = 7

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    // UIView
    var scoreboardView: UIView!
    var lifespanBoardView: UIView!
    
    // UICollectionView
    var tagCollectionView: UICollectionView!
    
    // UIPicker
    var yearPicker: UIPickerView!
    var monthPicker: UIPickerView!
    
    // UILabel
    var scoreTitleLabel: UILabel!
    var scoreNumberLabel: UILabel!
    var scoreMessageLabel: UILabel!
    var ageLabel: UILabel!
    var genderLabel: UILabel!
    var lifespanLabel: UILabel!
    
    // UIImageView
    var titleImageView: UIImageView!
    var profileImageView: UIImageView!
    var loadingImageView: UIImageView!
    var scoreEmoImageView: UIImageView!
    var agingHumansImageView: UIImageView!
    var robotImageView: UIImageView!
    var batteryImageView: UIImageView!
    
    // UIButton
    var profileButton: UIButton!
    
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var banners: [BaseModel.Banner]?
    var tags: [BaseModel.Tag]?
    var avatar: BaseModel.Avatar?
    var selectedTag: BaseModel.Tag?
    var yearArr: [Int]!
    var monthArr: [Int]!
    var selectedYear: Int?
    var selectedMonth: Int?
    var currentYear: Int!
    var currentMonth: Int!
    var thisAvgScore: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
//        loadScoreboard()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        UIView.transition(with: tagCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.monthPicker.reloadAllComponents()
            self.tagCollectionView.reloadData()
        })
        if UserDefaults.standard.isSignIn() {
            selectedYear = currentYear
            selectedMonth = nil
            monthArr = {
                var month = currentMonth
                var months = [Int]()
                while month! > 0 {
                    months.append(month!)
                    month! -= 1
                }
                return months
            }()
            yearPicker.selectRow(0, inComponent: 0, animated: true)
            monthPicker.selectRow(0, inComponent: 0, animated: true)
            
            loadScoreboard()
            loadAvatar()
        } else {
            monthArr = {
                var month = currentMonth
                var months = [Int]()
                while month! > 0 {
                    months.append(month!)
                    month! -= 1
                }
                return months
            }()
            yearPicker.selectRow(0, inComponent: 0, animated: true)
            monthPicker.selectRow(0, inComponent: 0, animated: true)
            
            UIView.transition(with: profileButton, duration: 0.7, options: .transitionCrossDissolve, animations: {
//                self.scoreboardView.backgroundColor = getCondScoreColor(0)
                self.scoreEmoImageView.image = getCondScoreImageLarge(0)
                self.agingHumansImageView.image = getAgingHumanImage(0)
                self.robotImageView.image = .itemAiGray
                
                self.scoreTitleLabel.text = self.lang.getCondScoreName(0)
                self.scoreNumberLabel.text = String(format: "%.1f", 0.0)
                self.scoreMessageLabel.text = self.lang.titleMyCondScore
                
                self.ageLabel.text = "AGE"
                self.genderLabel.text = "GENDER"
                
//                self.lifespanLabel.text = "Your remaining lifespan \nestimated approx. \n126Y 112D"
                self.lifespanLabel.text = "당신의 남은 수명을 \n예측합니다. \n약 71년 112일"
                
                self.scoreTitleLabel.textColor = getCondScoreColor(0)
                self.scoreNumberLabel.textColor = getCondScoreColor(0)
                self.scoreMessageLabel.textColor = getCondScoreColor(0)
                self.lifespanLabel.textColor = .dimGray
                self.ageLabel.textColor = getCondScoreColor(0)
                self.genderLabel.textColor = getCondScoreColor(0)
                
                self.profileButton.setTitleColor(UIColor.clear, for: .normal)
                self.profileButton.backgroundColor = UIColor.clear
                self.profileButton.setBackgroundImage(.itemProfileDef, for: .normal)
            })
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileButton)]
        }
    }
    
    // MARK: - Actions
    
    @objc func alertError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleYes, style: .default) { _ in
            self.retryFunction!()
        }
        let cancelAction = UIAlertAction(title: lang.titleClose, style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor.cornflowerBlue
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func presentDiaryNavigation() {
        let vc = DiaryViewController()
        vc.superTag = self.selectedTag!
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
    
    @objc func presentCategoryNavigation() {
        let vc = CategoryViewController()
        vc.superTag = self.selectedTag!
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
    
    @objc func presentAuthNavigation() {
        let vc = AuthViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
    
    @objc func presentProfileNavigation() {
        let vc = ProfileViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
    
    @objc func profileButtonTapped() {
        if UserDefaults.standard.isSignIn() {
            presentProfileNavigation()
        } else {
            presentAuthNavigation()
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let number = tags?.count else {
            return 0
        }
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as? TagCollectionCell else {
            fatalError()
        }
        if let tag = tags?[indexPath.item] {
            switch lang.currentLanguageId {
            case LanguageId.eng: cell.label.text = tag.eng_name
            case LanguageId.kor: cell.label.text = tag.kor_name
            default: fatalError()}
            if let image = UIImage(named: "tag-\(tag.id)") {
                cell.imageView.image = image.withRenderingMode(.alwaysOriginal)
            }
//            cell.imageView.image = UIImage(named: "tag-\(tag.id)")!.withRenderingMode(.alwaysOriginal)
            
            switch tag.id {
            case TagId.diary:
                cell.label.textColor = .tomato
            default:
                cell.label.textColor = .mediumSeaGreen
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = tags?[indexPath.item] else {
            return
        }
        self.selectedTag = tag
        if tag.id == TagId.diary {
            if UserDefaults.standard.isSignIn() {
                presentDiaryNavigation()
            } else {
                presentAuthNavigation()
            }
        } else if tag.id == TagId.bookmarks {
            if UserDefaults.standard.isSignIn() == false {
                presentAuthNavigation()
            }
        }
        presentCategoryNavigation()
    }
    
    // MARK: - UICollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = tags?[indexPath.item]
        if tag!.id == TagId.diary {
            return CGSize(width: UIScreen.main.bounds.width - 14, height: UIScreen.main.bounds.height / 14.5)
        }
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 10.5, height: UIScreen.main.bounds.height / 14.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case yearPicker:
            return yearArr.count
        case monthPicker:
            return monthArr.count + 1
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 30))
//        label.textColor = getCondScoreColor(thisAvgScore)
        label.textColor = .mediumSeaGreen
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        switch pickerView {
        case yearPicker:
            label.text = "\(yearArr[row])"
        case monthPicker:
            if row == 0 {
                label.text = "-"
            } else {
                switch lang.currentLanguageId {
                case LanguageId.eng:
                    label.text = LangHelper.getEngNameOfMM(monthNumber: monthArr[row - 1])
                case LanguageId.kor:
                    label.text = LangHelper.getKorNameOfMonth(monthNumber: monthArr[row - 1], engMMM: nil)
                default:
                    fatalError()
                }
            }
        default:
            fatalError()
        }
        return label
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case yearPicker:
            selectedYear = yearArr[row]
            selectedMonth = nil
            if selectedYear == currentYear {
                var month = currentMonth
                var months = [Int]()
                while month! > 0 {
                    months.append(month!)
                    month! -= 1
                }
                monthArr = months
            } else {
                monthArr = [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
            }
            monthPicker.reloadAllComponents()
            monthPicker.selectRow(0, inComponent: 0, animated: true)
        case monthPicker:
            if row == 0 {
                selectedMonth = nil
            } else {
                selectedMonth = monthArr[row - 1]
            }
        default:
            fatalError()
        }
        
        if UserDefaults.standard.isSignIn() {
            loadScoreboard()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}

extension HomeViewController {
    
    // MARK: - Private methods
    
    private func setupLayout() {
        // Initialize view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = UIColor.whiteSmoke
        
        let date = Date()
        let calendar = Calendar.current
        currentYear = calendar.component(.year, from: date)
        currentMonth = calendar.component(.month, from: date)
        
        // Initialize subveiw properties
        tagCollectionView = getCategoryCollectionView()
        scoreboardView = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10.0
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        lifespanBoardView = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10.0
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        yearPicker = {
            let _pickerView = UIPickerView()
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        monthPicker = {
            let _pickerView = UIPickerView()
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        scoreEmoImageView = {
            let _imageView = UIImageView()
            _imageView.contentMode = .scaleAspectFit
            _imageView.addShadowView()
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        scoreTitleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 30, weight: .medium)
            _label.textColor = .dimGray
            _label.textAlignment = .center
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        scoreNumberLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 40, weight: .medium)
            _label.textColor = .dimGray
            _label.textAlignment = .center
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        scoreMessageLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 20, weight: .medium)
            _label.textColor = .dimGray
            _label.textAlignment = .center
            _label.numberOfLines = 2
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        ageLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 17, weight: .medium)
            _label.textColor = .dimGray
            _label.textAlignment = .right
            _label.numberOfLines = 1
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        genderLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 17, weight: .medium)
            _label.textColor = .dimGray
            _label.textAlignment = .right
            _label.numberOfLines = 1
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        lifespanLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 16, weight: .regular)
            _label.textColor = .dimGray
            _label.textAlignment = .center
            _label.numberOfLines = 3
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        titleImageView = {
            let _imageView = UIImageView(image: .itemLogoS)
            _imageView.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
            _imageView.contentMode = .scaleAspectFit
            return _imageView
        }()
        profileImageView = {
            let _imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 31, height: 31))
            _imageView.layer.cornerRadius = 31 / 2
            _imageView.contentMode = .scaleAspectFill
            _imageView.clipsToBounds = true
            _imageView.image = UIImage.itemProfileDef
            _imageView.isUserInteractionEnabled = true
            _imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileButtonTapped)))
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        agingHumansImageView = {
            let _imageView = UIImageView(image: .itemLogoS)
            _imageView.contentMode = .scaleAspectFit
            _imageView.image = .itemAgingGray
            _imageView.addShadowView()
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        robotImageView = {
            let _imageView = UIImageView(image: .itemLogoS)
            _imageView.contentMode = .scaleAspectFit
            _imageView.image = .itemAiGray
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        batteryImageView = {
            let _imageView = UIImageView(image: .itemLogoS)
            _imageView.contentMode = .scaleAspectFit
            _imageView.image = .itemBatteryGray
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        profileButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemProfileDef.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 31, height: 31)
            _button.layer.cornerRadius = _button.frame.width/2
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        loadingImageView = getLoadingImageView(isHidden: false)
        yearArr = {
            var year = currentYear
            selectedYear = year
            let lastYear = year! - 4
            var years = [Int]()
            while year! > lastYear {
                years.append(year!)
                year! -= 1
            }
            return years
        }()
        monthArr = {
            var month = currentMonth
            var months = [Int]()
            while month! > 0 {
                months.append(month!)
                month! -= 1
            }
            return months
        }()
        
        navigationItem.titleView = titleImageView
        profileImageView.widthAnchor.constraint(equalToConstant: 31).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 31).isActive = true
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileImageView)]
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        yearPicker.dataSource = self
        yearPicker.delegate = self
        monthPicker.dataSource = self
        monthPicker.delegate = self
        
        // Setup subviews
        view.addSubview(scoreboardView)
        view.addSubview(lifespanBoardView)
        view.addSubview(tagCollectionView)
        view.addSubview(loadingImageView)
        
        scoreboardView.addSubview(scoreTitleLabel)
        scoreboardView.addSubview(scoreEmoImageView)
        scoreboardView.addSubview(scoreNumberLabel)
        scoreboardView.addSubview(scoreMessageLabel)
        scoreboardView.addSubview(yearPicker)
        scoreboardView.addSubview(monthPicker)
        scoreboardView.addSubview(agingHumansImageView)
        scoreboardView.addSubview(ageLabel)
        scoreboardView.addSubview(genderLabel)
        
        lifespanBoardView.addSubview(robotImageView)
        lifespanBoardView.addSubview(lifespanLabel)
        lifespanBoardView.addSubview(batteryImageView)
        
        // Setup constraints
        scoreboardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        scoreboardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        scoreboardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        scoreboardView.heightAnchor.constraint(equalToConstant: view.frame.height / 2.6).isActive = true
        
        yearPicker.topAnchor.constraint(equalTo: scoreboardView.topAnchor, constant: -10).isActive = true
        yearPicker.leadingAnchor.constraint(equalTo: scoreboardView.leadingAnchor, constant: 7).isActive = true
        yearPicker.widthAnchor.constraint(equalToConstant: 90).isActive = true
        yearPicker.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        monthPicker.centerYAnchor.constraint(equalTo: scoreboardView.centerYAnchor, constant: 0).isActive = true
        monthPicker.trailingAnchor.constraint(equalTo: scoreboardView.trailingAnchor, constant: -7).isActive = true
        monthPicker.widthAnchor.constraint(equalToConstant: 90).isActive = true
        monthPicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        scoreTitleLabel.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreTitleLabel.centerYAnchor.constraint(equalTo: scoreboardView.centerYAnchor, constant: -(view.frame.height / 7)).isActive = true
        
        scoreEmoImageView.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreEmoImageView.centerYAnchor.constraint(equalTo: scoreboardView.centerYAnchor, constant: -(view.frame.height / 44)).isActive = true
        
        scoreNumberLabel.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreNumberLabel.topAnchor.constraint(equalTo: scoreEmoImageView.bottomAnchor, constant: 7).isActive = true
        
        scoreMessageLabel.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreMessageLabel.bottomAnchor.constraint(equalTo: scoreboardView.bottomAnchor, constant: -(view.frame.height / 33)).isActive = true
        
        agingHumansImageView.leadingAnchor.constraint(equalTo: scoreboardView.leadingAnchor, constant: 14).isActive = true
        agingHumansImageView.bottomAnchor.constraint(equalTo: scoreMessageLabel.topAnchor, constant: -(view.frame.height / 34)).isActive = true
        
        ageLabel.topAnchor.constraint(equalTo: scoreboardView.topAnchor, constant: 10).isActive = true
        ageLabel.trailingAnchor.constraint(equalTo: scoreboardView.trailingAnchor, constant: -10).isActive = true
        
        genderLabel.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 1).isActive = true
        genderLabel.trailingAnchor.constraint(equalTo: scoreboardView.trailingAnchor, constant: -10).isActive = true
        
        lifespanBoardView.topAnchor.constraint(equalTo: scoreboardView.bottomAnchor, constant: 7).isActive = true
        lifespanBoardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        lifespanBoardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        lifespanBoardView.heightAnchor.constraint(equalToConstant: view.frame.height / 8.2).isActive = true
        
        robotImageView.centerYAnchor.constraint(equalTo: lifespanBoardView.centerYAnchor, constant: 0).isActive = true
        robotImageView.leadingAnchor.constraint(equalTo: lifespanBoardView.leadingAnchor, constant: 20).isActive = true
        
        lifespanLabel.centerYAnchor.constraint(equalTo: lifespanBoardView.centerYAnchor, constant: 0).isActive = true
        lifespanLabel.centerXAnchor.constraint(equalTo: lifespanBoardView.centerXAnchor, constant: 0).isActive = true
        
        batteryImageView.centerYAnchor.constraint(equalTo: lifespanBoardView.centerYAnchor, constant: 0).isActive = true
        batteryImageView.trailingAnchor.constraint(equalTo: lifespanBoardView.trailingAnchor, constant: -20).isActive = true
        
        tagCollectionView.topAnchor.constraint(equalTo: lifespanBoardView.bottomAnchor, constant: 7).isActive = true
        tagCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        tagCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        tagCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        loadingImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
    }
    
    private func retryFunctionSet() {
        if UserDefaults.standard.isSignIn() {
            loadAvatar()
        }
        loadScoreboard()
        loadCategories()
    }
    
    private func loadScoreboard() {
        let service = Service(lang: lang)
        service.getAvgCondScore(yearNumber: "\(selectedYear!)", monthNumber: selectedMonth, weekOfYear: nil, popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadScoreboard()
        }) { (avgCondScoreSet) in
            let formatter = NumberFormatter()
            self.thisAvgScore = formatter.number(from: avgCondScoreSet.this_avg_score)!.floatValue
            UIView.animate(withDuration: 0.5) {
//                self.scoreboardView.backgroundColor = getCondScoreColor(thisAvgScore)
                self.scoreEmoImageView.image = getCondScoreImageLarge(self.thisAvgScore)
                self.agingHumansImageView.image = getAgingHumanImage(self.thisAvgScore)
                self.robotImageView.image = .itemAiGreen
                self.batteryImageView.image = .itemBatteryGreen
                
                self.scoreTitleLabel.text = self.lang.getCondScoreName(self.thisAvgScore)
                self.scoreNumberLabel.text = String(format: "%.1f", self.thisAvgScore)
                self.scoreMessageLabel.text = self.lang.titleMyCondScore
                
                self.ageLabel.text = "나이 29"
                self.genderLabel.text = "남성"
                
//                self.lifespanLabel.text = "당신의 남은 수명을 \n예측합니다. \n약 71년 112일"
                self.lifespanLabel.textColor = .mediumSeaGreen
                let lifespanNumber = "126Y 112D"
                let lifespanMessage = "Your remaining lifespan \nestimated approx. \n\(lifespanNumber)"
                
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: lifespanMessage)
                attributedString.setColorForText(textForAttribute: lifespanNumber, withColor: .tomato)
                self.lifespanLabel.attributedText = attributedString
                
//                let range = (lifespanMessage as NSString).range(of: "lifespan")
//                let attribute = NSMutableAttributedString.init(string: lifespanMessage)
//                attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
//                self.lifespanLabel.attributedText = attribute
                
                self.scoreTitleLabel.textColor = getCondScoreColor(self.thisAvgScore)
                self.scoreNumberLabel.textColor = getCondScoreColor(self.thisAvgScore)
                self.scoreMessageLabel.textColor = getCondScoreColor(self.thisAvgScore)
                self.ageLabel.textColor = getCondScoreColor(self.thisAvgScore)
                self.genderLabel.textColor = getCondScoreColor(self.thisAvgScore)
//                self.lifespanLabel.textColor = .mediumSeaGreen
            }
        }
    }
    
    private func loadCategories() {
        let service = Service(lang: lang)
        service.getTagSetList(tagId: TagId.home, sortType: SortType.priority, popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }) { (tagSet) in
            self.tags = tagSet.sub_tags
            UIView.transition(with: self.tagCollectionView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.tagCollectionView.reloadData()
                self.loadingImageView.isHidden = true
            })
        }
    }
    
    private func loadAvatar() {
        let service = Service(lang: lang)
        service.getAvatar(popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadAvatar()
        }) { (auth) in
            self.avatar = auth.avatar
            UserDefaults.standard.setCurrentLanguageId(value: auth.language_id)
            let firstName = auth.avatar.first_name
            UIView.animate(withDuration: 0.5, animations: {
                if auth.avatar.photo_name != nil && auth.avatar.color_code == 0 {
                    print(auth.avatar.photo_name!)
                    let url = "\(URI.host)\(URI.avatar)/\(auth.avatar.id)/profile/photo/\(auth.avatar.photo_name!)"
                    Alamofire.request(url).responseImage { response in
                        if let data = response.data {
                            self.profileImageView.image = UIImage(data: data)
                            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: self.profileImageView)]
                        }
                    }
                } else {
                    let index = firstName.index(firstName.startIndex, offsetBy: 0)
                    self.profileButton.setImage(nil, for: .normal)
                    self.profileButton.setTitle(String(firstName[index]), for: .normal)
                    self.profileButton.setTitleColor(.white, for: .normal)
                    self.profileButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
                    self.profileButton.backgroundColor = getProfileUIColor(key: auth.avatar.color_code)
                    self.profileButton.setBackgroundImage(nil, for: .normal)
                    self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: self.profileButton)]
                }
            })
        }
    }
}
