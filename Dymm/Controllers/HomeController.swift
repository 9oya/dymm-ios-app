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
    var aiBoardView: UIView!
    
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
    var aiMsgLabel: UILabel!
    var lifespanLabel: UILabel!
    
    // UIImageView
    var titleImgView: UIImageView!
    var profileImgView: UIImageView!
    var scoreEmoImgView: UIImageView!
    var cubeImgView: UIImageView!
    var aiBoardBgImgView: UIImageView!
    
    // UIButton
    var profileButton: UIButton!
    
    // Non-view properties
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
    var receiptString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadCategories()
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        UIView.transition(with: tagCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.monthPicker.reloadAllComponents()
            self.tagCollectionView.reloadData()
        })
        if UserDefaults.standard.isSignIn() {
            selectedYear = currentYear
            selectedMonth = nil
            yearPicker.selectRow(0, inComponent: 0, animated: true)
            monthPicker.selectRow(0, inComponent: 0, animated: true)
            loadScoreboard()
            loadAvatar()
            loadRemainingLifeSpan()
            loadReceipt()
        } else {
            showGuestScene()
            UserDefaults.standard.setIsFreeTrial(value: false)
            UserDefaults.standard.setIsPurchased(value: false)
            cubeImgView.isHidden = true
        }
        cubeImgView.startRotating(duration: 5)
    }
    
    // MARK: - Actions
    
    @objc func appMovedToForeground() {
        cubeImgView.startRotating(duration: 5)
    }
    
    @objc func alertError(_ message: String) {
        view.hideSpinner()
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleYes, style: .default) { _ in
            self.retryFunction!()
        }
        let cancelAction = UIAlertAction(title: lang.titleClose, style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = .purple_B847FF
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func alertUnauthError(_ message: String) {
        let alertController = UIAlertController(title: lang.titleAccountInvalid, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: lang.titleDone, style: .cancel) { _ in
            UserDefaults.standard.setIsSignIn(value: false)
            UserDefaults.standard.setAvatarId(value: 0)
            self.showGuestScene()
        })
        alertController.view.tintColor = .purple_B847FF
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func presentDiaryNavigation() {
        let vc = DiaryViewController()
        vc.superTag = self.selectedTag!
        navigationItem.backBarButtonItem = UIBarButtonItem(title: lang.titleHome, style: .plain, target: self, action: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentCategoryNavigation() {
        let vc = CategoryViewController()
        vc.superTag = self.selectedTag!
        vc.topLeftButtonType = ButtonType.back
        navigationItem.backBarButtonItem = UIBarButtonItem(title: lang.titleHome, style: .plain, target: self, action: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentAuthNavigation() {
        let vc = AuthViewController()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: lang.titleHome, style: .plain, target: self, action: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentProfileNavigation() {
        let vc = ProfileViewController()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: lang.titleHome, style: .plain, target: self, action: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentRankingNavigation() {
        let vc = RankingViewController()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: lang.titleHome, style: .plain, target: self, action: nil)
        navigationController?.pushViewController(vc, animated: true)
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
            switch tag.id {
            case TagId.diary:
                cell.label.textColor = UIColor(hex: "#FF7187")
            case TagId.ranking:
                cell.label.textColor = UIColor(hex: "#948BFF")
            case TagId.bookmarks:
                cell.label.textColor = UIColor(hex: "#FFBF67")
            default:
                cell.label.textColor = .green_3ED6A7
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
        switch tag.id {
        case TagId.diary:
            if UserDefaults.standard.isSignIn() {
                presentDiaryNavigation()
            } else {
                presentAuthNavigation()
            }
        case TagId.bookmarks:
            if UserDefaults.standard.isSignIn() {
                presentCategoryNavigation()
            } else {
                presentAuthNavigation()
            }
        case TagId.ranking:
            if UserDefaults.standard.isSignIn() {
                presentRankingNavigation()
            } else {
                presentAuthNavigation()
            }
        default:
            presentCategoryNavigation()
        }
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
        label.textColor = .green_3ED6A7
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
        view.backgroundColor = .whiteSmoke
        let date = Date()
        currentYear = Calendar.current.component(.year, from: date)
        currentMonth = Calendar.current.component(.month, from: date)
        
        // Initialize subveiw properties
        tagCollectionView = getCategoryCollectionView()
        scoreboardView = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10.0
            _view.addShadowView()
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        aiBoardView = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10.0
            _view.addShadowView()
            _view.isHidden = true
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
        scoreEmoImgView = {
            let _imageView = UIImageView()
            _imageView.contentMode = .scaleAspectFit
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        scoreTitleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 30, weight: .medium)
            _label.textColor = .dimGray
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        scoreNumberLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 40, weight: .medium)
            _label.textColor = .green_3ED6A7
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        scoreMessageLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 20, weight: .medium)
            _label.textColor = .green_3ED6A7
            _label.textAlignment = .center
            _label.numberOfLines = 2
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        ageLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 18, weight: .medium)
            _label.textColor = .green_3ED6A7
            _label.textAlignment = .right
            _label.numberOfLines = 1
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        genderLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 18, weight: .medium)
            _label.textColor = .green_3ED6A7
            _label.textAlignment = .right
            _label.numberOfLines = 1
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        aiMsgLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 16, weight: .regular)
            _label.textColor = .yellow_F8F6E9
            _label.textAlignment = .center
            _label.numberOfLines = 3
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        lifespanLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 16, weight: .regular)
            _label.textColor = .yellow_F8F6E9
            _label.textAlignment = .center
            _label.numberOfLines = 3
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        cubeImgView = {
            let _imageView = UIImageView()
            _imageView.contentMode = .scaleAspectFit
            _imageView.image = .item3dCube
            _imageView.isHidden = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        aiBoardBgImgView = {
            let _imageView = UIImageView()
            _imageView.contentMode = .scaleAspectFill
            _imageView.image = .itemBgWave
            _imageView.layer.cornerRadius = 10.0
            _imageView.clipsToBounds = true
            _imageView.isHidden = false
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        titleImgView = {
            let _imageView = UIImageView(image: .itemLogoS)
            _imageView.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
            _imageView.contentMode = .scaleAspectFit
            return _imageView
        }()
        profileImgView = {
            let _imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 31, height: 31))
            _imageView.layer.cornerRadius = 31 / 2
            _imageView.contentMode = .scaleAspectFill
            _imageView.clipsToBounds = true
            _imageView.image = .itemProfileDef
            _imageView.isUserInteractionEnabled = true
            _imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileButtonTapped)))
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        profileButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemProfileDef.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 31, height: 31)
            _button.layer.cornerRadius = _button.frame.width / 2
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
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
        
        navigationItem.titleView = titleImgView
        profileImgView.widthAnchor.constraint(equalToConstant: 31).isActive = true
        profileImgView.heightAnchor.constraint(equalToConstant: 31).isActive = true
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileImgView)]
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        yearPicker.dataSource = self
        yearPicker.delegate = self
        monthPicker.dataSource = self
        monthPicker.delegate = self
        
        // Setup subviews
        view.addSubview(scoreboardView)
        view.addSubview(aiBoardView)
        view.addSubview(tagCollectionView)
        
        scoreboardView.addSubview(scoreTitleLabel)
        scoreboardView.addSubview(scoreEmoImgView)
        scoreboardView.addSubview(scoreNumberLabel)
        scoreboardView.addSubview(scoreMessageLabel)
        scoreboardView.addSubview(yearPicker)
        scoreboardView.addSubview(monthPicker)
        scoreboardView.addSubview(ageLabel)
        scoreboardView.addSubview(genderLabel)
        
        aiBoardView.addSubview(aiBoardBgImgView)
        aiBoardView.addSubview(aiMsgLabel)
        aiBoardView.addSubview(lifespanLabel)
        aiBoardView.addSubview(cubeImgView)
        
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
        
        scoreEmoImgView.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreEmoImgView.centerYAnchor.constraint(equalTo: scoreboardView.centerYAnchor, constant: -(view.frame.height / 44)).isActive = true
        
        scoreNumberLabel.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreNumberLabel.topAnchor.constraint(equalTo: scoreEmoImgView.bottomAnchor, constant: 7).isActive = true
        
        scoreMessageLabel.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreMessageLabel.bottomAnchor.constraint(equalTo: scoreboardView.bottomAnchor, constant: -(view.frame.height / 33)).isActive = true
        
        ageLabel.topAnchor.constraint(equalTo: scoreboardView.topAnchor, constant: 10).isActive = true
        ageLabel.trailingAnchor.constraint(equalTo: scoreboardView.trailingAnchor, constant: -10).isActive = true
        
        genderLabel.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 1).isActive = true
        genderLabel.trailingAnchor.constraint(equalTo: scoreboardView.trailingAnchor, constant: -10).isActive = true
        
        aiBoardView.topAnchor.constraint(equalTo: scoreboardView.bottomAnchor, constant: 7).isActive = true
        aiBoardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        aiBoardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        aiBoardView.heightAnchor.constraint(equalToConstant: view.frame.height / 8.2).isActive = true
        
        aiBoardBgImgView.topAnchor.constraint(equalTo: aiBoardView.topAnchor, constant: 0).isActive = true
        aiBoardBgImgView.leadingAnchor.constraint(equalTo: aiBoardView.leadingAnchor, constant: 0).isActive = true
        aiBoardBgImgView.trailingAnchor.constraint(equalTo: aiBoardView.trailingAnchor, constant: 0).isActive = true
        aiBoardBgImgView.bottomAnchor.constraint(equalTo: aiBoardView.bottomAnchor, constant: 0).isActive = true
        
        aiMsgLabel.centerYAnchor.constraint(equalTo: aiBoardView.centerYAnchor, constant: -10).isActive = true
        aiMsgLabel.centerXAnchor.constraint(equalTo: aiBoardView.centerXAnchor, constant: 0).isActive = true
        aiMsgLabel.leadingAnchor.constraint(equalTo: aiBoardView.leadingAnchor, constant: 3).isActive = true
        aiMsgLabel.trailingAnchor.constraint(equalTo: aiBoardView.trailingAnchor, constant: -3).isActive = true
        
        lifespanLabel.bottomAnchor.constraint(equalTo: aiBoardView.bottomAnchor, constant: -((view.frame.height / 8) / 10)).isActive = true
        lifespanLabel.centerXAnchor.constraint(equalTo: aiBoardView.centerXAnchor, constant: 0).isActive = true
        
        cubeImgView.centerYAnchor.constraint(equalTo: lifespanLabel.centerYAnchor, constant: 0).isActive = true
        cubeImgView.leadingAnchor.constraint(equalTo: lifespanLabel.trailingAnchor, constant: 20).isActive = true
        
        tagCollectionView.topAnchor.constraint(equalTo: aiBoardView.bottomAnchor, constant: 7).isActive = true
        tagCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        tagCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        tagCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    private func retryFunctionSet() {
        if UserDefaults.standard.isSignIn() {
            loadAvatar()
            loadRemainingLifeSpan()
            loadScoreboard()
        }
        loadCategories()
    }
    
    private func showGuestScene() {
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
            self.scoreboardView.isHidden = false
            self.aiBoardView.isHidden = false
            
            self.scoreEmoImgView.image = getCondScoreImageLarge(0)
            
            self.scoreTitleLabel.text = self.lang.getMoodScoreName(0)
            self.scoreNumberLabel.text = String(format: "%.1f", 0.0)
            self.scoreMessageLabel.text = self.lang.titleMyCondScore
            
            self.ageLabel.text = self.lang.titleAge
            self.genderLabel.text = self.lang.titleGender
            
            self.aiMsgLabel.text = self.lang.msgSignUpYet
            self.lifespanLabel.text = ""
            
            self.profileButton.setTitleColor(.clear, for: .normal)
            self.profileButton.backgroundColor = .clear
            self.profileButton.setBackgroundImage(.itemProfileDef, for: .normal)
        })
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileButton)]
    }
    
    private func loadScoreboard() {
        let service = Service(lang: lang)
        service.getScoreBoard(yearNumber: selectedYear!, monthNumber: selectedMonth, unauthorized: { (errorCode) in
            self.alertUnauthError(self.lang.msgAccountInvalid)
        }, popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadScoreboard()
        }) { (scoreBoardSet) in
            let formatter = NumberFormatter()
            self.thisAvgScore = formatter.number(from: scoreBoardSet.avg_score)!.floatValue
            UIView.animate(withDuration: 0.5) {
                self.scoreEmoImgView.image = getCondScoreImageLarge(self.thisAvgScore)
                self.scoreTitleLabel.text = self.lang.getMoodScoreName(self.thisAvgScore)
                self.scoreNumberLabel.text = String(format: "%.1f", self.thisAvgScore)
                self.scoreMessageLabel.text = self.lang.titleMyCondScore
                if let genderTag = scoreBoardSet.gender_tag {
                    switch self.lang.currentLanguageId {
                    case LanguageId.eng:
                        self.genderLabel.text = genderTag.eng_name.uppercased()
                    case LanguageId.kor:
                        self.genderLabel.text = genderTag.kor_name
                    default: fatalError()}
                } else {
                    self.genderLabel.text = self.lang.titleGender
                }
                self.scoreTitleLabel.textColor = .green_3ED6A7
                self.scoreNumberLabel.textColor = .green_3ED6A7
                self.scoreMessageLabel.textColor = .green_3ED6A7
                self.ageLabel.textColor = .green_3ED6A7
                self.genderLabel.textColor = .green_3ED6A7
                self.scoreboardView.isHidden = false
            }
        }
    }
    
    private func loadRemainingLifeSpan() {
        let service = Service(lang: lang)
        service.getRemainingLifeSpan(popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadRemainingLifeSpan()
        }, unauthorized: { (pattern) in
            UIView.animate(withDuration: 0.5) {
                switch pattern {
                case UnauthType.userInvalid:
                    self.alertUnauthError(self.lang.msgAccountInvalid)
                case UnauthType.scoreNone:
                    self.aiMsgLabel.text = self.lang.msgCondScoreNone
                case UnauthType.birthNone:
                    self.aiMsgLabel.text = self.lang.msgDateOfBirthNone
                default: fatalError()}
                self.aiBoardView.isHidden = false
                self.cubeImgView.isHidden = true
                self.lifespanLabel.isHidden = true
            }
        }) { (lifeSpanSet) in
            let year = lifeSpanSet.r_lifespan_day / 365
            let days = lifeSpanSet.r_lifespan_day % 365
            UIView.animate(withDuration: 0.5) {
                switch self.lang.currentLanguageId {
                case LanguageId.eng:
                    self.lifespanLabel.text = "You have \(year)Y \(days)D"
                case LanguageId.kor:
                    self.lifespanLabel.text = "\(year)년 \(days)일 남았습니다."
                default: fatalError()}
                self.lifespanLabel.isHidden = false
                self.aiBoardView.isHidden = false
                self.cubeImgView.isHidden = false
                
                if let avgScore = Float(lifeSpanSet.avg_score) {
                    if avgScore > 0.0 {
                        self.aiMsgLabel.text = self.lang.getMoodScoreMessage(avgScore)
                    } else {
                        self.aiMsgLabel.text = self.lang.msgLifeSpan
                    }
                }
            }
        }
    }
    
    private func loadCategories() {
        view.showSpinner()
        let service = Service(lang: lang)
        service.getTagSetList(tagId: TagId.home, sortType: SortType.priority, popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }) { (tagSet) in
            self.tags = tagSet.sub_tags
            UIView.transition(with: self.tagCollectionView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.tagCollectionView.reloadData()
                self.view.hideSpinner()
            })
        }
    }
    
    private func loadAvatar() {
        let service = Service(lang: lang)
        service.getAvatar(unauthorized: { (errorCode) in
            self.alertUnauthError(self.lang.msgAccountInvalid)
        }, popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadAvatar()
        }) { (auth) in
            if let dateOfBirth = auth.avatar.date_of_birth {
                let dateFormatter : DateFormatter = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    return formatter
                }()
                let birthday = dateFormatter.date(from: dateOfBirth)
                let timeInterval = birthday?.timeIntervalSinceNow
                self.ageLabel.text = self.lang.titleAge + " \(abs(Int(timeInterval! / 31556926.0)))"
            } else {
                self.ageLabel.text = self.lang.titleAge
            }
            
            self.avatar = auth.avatar
            UserDefaults.standard.setCurrentLanguageId(value: auth.language_id)
            UIView.animate(withDuration: 0.5, animations: {
                if auth.avatar.photo_name != nil && auth.avatar.color_code == 0 {
                    let url = "\(URI.host)\(URI.avatar)/\(auth.avatar.id)/profile/photo/\(auth.avatar.photo_name!)"
                    Alamofire.request(url).responseImage { response in
                        if let data = response.data {
                            self.profileImgView.image = UIImage(data: data)
                            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: self.profileImgView)]
                        }
                    }
                } else {
                    let firstName = auth.avatar.first_name
                    let index = firstName.index(firstName.startIndex, offsetBy: 0)
                    self.profileButton.setImage(nil, for: .normal)
                    self.profileButton.setTitle(String(firstName[index]), for: .normal)
                    self.profileButton.setTitleColor(.white, for: .normal)
                    self.profileButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
                    self.profileButton.backgroundColor = getProfileUIColor(key: auth.avatar.color_code)
                    self.profileButton.setBackgroundImage(nil, for: .normal)
                    self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: self.profileButton)]
                }
            })
            
            if auth.avatar.is_free_trial {
                UserDefaults.standard.setIsFreeTrial(value: true)
            } else {
                UserDefaults.standard.setIsFreeTrial(value: false)
            }
        }
    }
    
    private func loadReceipt() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                receiptString = receiptData.base64EncodedString(options: [])
                verifyReceipt()
            }
            catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
    }
    
    private func verifyReceipt() {
        let params: Parameters = [
            "receipt_data": receiptString!
        ]
        let service = Service(lang: lang)
        service.verifyReceipt(params: params, popoverAlert: { (message) in
            self.retryFunction = self.verifyReceipt
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.verifyReceipt()
        }) { (isReceiptVerified) in
            if isReceiptVerified {
                UserDefaults.standard.setIsPurchased(value: true)
            } else {
                UserDefaults.standard.setIsPurchased(value: false)
            }
        }
    }
}
