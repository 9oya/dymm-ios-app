//
//  CategoryController.swift
//  Flava
//
//  Created by eunsang lee on 17/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit
import Alamofire

private let tagCellId = "TagCell"
private let stepCellId = "StepCell"

private let stepBarHeightVal: CGFloat = 40
private let spaceVal: CGFloat = 7
private let detailBoxAHeightVal: CGFloat = 350
private let detailBoxBHeightVal: CGFloat = 333
private let detailBoxCHeightVal: CGFloat = 265

class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    // UIViews
    var detailContainerView: UIView!
    var searchContainerView: UIView!
    var sortContainerView: UIView!
    var sizePickerContainerView: UIView!
    
    // UIScrollView
    var scrollView: UIScrollView!
    
    // UICollectionViews
    var stepCollectionView: UICollectionView!
    var tagCollectionView: UICollectionView!
    
    // UIPickerViews
    var timePicker: UIDatePicker!
    var sizePickerView: UIPickerView!
    
    // UIImageViews
    var loadingImageView: UIImageView!
    var fingerImageView: UIImageView!
    var downArrowImageView: UIImageView!
    var photoImageView: UIImageView!
    
    // UILabels
    var titleLabel: UILabel!
    
    // UIButtons
    var homeButton: UIButton!
    var starButton: UIButton!
    var logSizeButton: UIButton!
    var logTimeButton: UIButton!
    var startDateButton: UIButton!
    var endDateButton: UIButton!
    
    // NSLayoutConstraints
    var tagCollectionViewTop: NSLayoutConstraint!
    var tagCollectionViewHeight: NSLayoutConstraint!
    var detailContainerViewHeight: NSLayoutConstraint!
    var fingerImageBottom: NSLayoutConstraint!
    
    // Non-view properties
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: getUserCountryCode())  // TODO ko_kr
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    var superTag: BaseModel.Tag!
    var subTags: [BaseModel.Tag]!
    var stepTags: [BaseModel.Tag] = []
    var selectedXVal: Int?
    var selectedYVal: Int?
    var selectedDate: String?
    var cond_log_type: Int?
    var selectedSizePickerRow: Int = 4
    var selectedHourPickerRow: Int = 0
    var selectedMinPickerRow: Int = 1
    let hours: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    let mins: [Int] = [0, 10, 20, 30, 40, 50]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadCategories()
    }
    
    // MARK: - Actions
    
    @objc func homeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func logButtonTapped() {
        let vc = DiaryViewController()
        vc.diaryMode = DiaryMode.logger
        vc.logType = LogType.food
        vc.selectedTag = superTag!
        vc.x_val = selectedXVal!
        vc.y_val = selectedYVal!
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func timePickerChanged(_ sender: UIDatePicker){
        let _formatter = DateFormatter()
        _formatter.locale = Locale(identifier: getUserCountryCode())  // TODO ko_kr
        _formatter.dateFormat = "HH:mm"
        let selectedTimeArr = _formatter.string(from: sender.date).components(separatedBy: ":")
        selectedXVal = Int(selectedTimeArr[0])
        selectedYVal = Int(selectedTimeArr[1])
        var hr = ""
        var min = ""
        if selectedXVal != 0 {
            hr = "\(selectedXVal!)hr"
        }
        if selectedYVal != 0 {
            min = "\(selectedYVal!)min"
        }
        logTimeButton.setTitle("\(hr) \(min)", for: .normal)
        print(hr)
    }
    
    @objc func startDateButtonTapped() {
        alertDatePicker(cond_log_type: CondLogType.startDate)
    }
    
    @objc func endDateButtonTapped() {
        alertDatePicker(cond_log_type: CondLogType.endDate)
    }
    
    @objc func alertError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnYes, style: .default) { _ in
            self.retryFunction!()
        }
        let cancelAction = UIAlertAction(title: lang.btnNo, style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func alertDatePicker(cond_log_type: Int) {
        self.cond_log_type = cond_log_type
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.timeZone = NSTimeZone.local
        datePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
        datePicker.datePickerMode = .date
        var _title = ""
        if cond_log_type == CondLogType.startDate {
            _title = "\(lang.btnStartDate!)\n\n\n\n\n\n\n\n"
        } else {
            _title = "\(lang.btnEndDate!)\n\n\n\n\n\n\n\n"
        }
        let alertController = UIAlertController(title: _title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alertController.view.addSubview(datePicker)
        let selectAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            self.selectedDate = self.dateFormatter.string(from: datePicker.date)
            UIView.transition(with: self.detailContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.detailContainerView.isHidden = true
                self.loadingImageView.isHidden = false
            })
            self.postAConditionLog()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion:{})
    }
    
    @objc func alertCompl(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnYes, style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: lang.btnNo, style: .cancel) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor.tomato
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagCollectionView {
            guard let number = subTags?.count else {
                return 0
            }
            return number
        } else if collectionView == stepCollectionView {
            return stepTags.count
        } else {
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tagCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as? TagCollectionCell else {
                fatalError()
            }
            let tag = subTags[indexPath.row]
            switch lang.currentLanguageId {
            case LanguageId.eng: cell.label.text = tag.eng_name
            case LanguageId.kor: cell.label.text = tag.kor_name
            default: fatalError()}
            cell.imageView.image = UIImage(named: "tag-id-\(tag.id)")
            return cell
        } else if collectionView == stepCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: stepCellId, for: indexPath) as? StepCollectionCell else {
                fatalError()
            }
            let tag = stepTags[indexPath.row]
            switch lang.currentLanguageId {
            case LanguageId.eng: cell.label.text = tag.eng_name
            case LanguageId.kor: cell.label.text = tag.kor_name
            default: fatalError()}
            return cell
        } else {
            fatalError()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tagCollectionView {
            let selected_tag = subTags[indexPath.item]
            stepTags.append(superTag)
            superTag = selected_tag
            loadCategories()
        } else if collectionView == stepCollectionView {
            superTag = stepTags[indexPath.item]
            while stepTags.count > indexPath.item {
                stepTags.remove(at: indexPath.item)
            }
            loadCategories()
        } else {
            fatalError()
        }
    }
    
    // MARK: - UICollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if collectionView == tagCollectionView {
            return CGSize(width: (screenWidth / 2) - 10.5, height: CGFloat(40))
        } else if collectionView == stepCollectionView {
            let tag = stepTags[indexPath.row]
            var txtCnt = 0
            switch lang.currentLanguageId {
            case LanguageId.eng: txtCnt = tag.eng_name.count
            case LanguageId.kor: txtCnt = tag.kor_name!.count
            case LanguageId.jpn: txtCnt = tag.jpn_name!.count
            default: fatalError()}
            if txtCnt <= 6 {
                // Set minimum size
                return CGSize(width: 60, height: CGFloat(40))
            }
            return CGSize(width: 100, height: CGFloat(40))
        } else {
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == tagCollectionView {
            return 7
        } else if collectionView == stepCollectionView {
            return 2
        } else {
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == tagCollectionView {
            return 7
        } else if collectionView == stepCollectionView {
            return 0
        } else {
            fatalError()
        }
    }
}

extension CategoryViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == sizePickerView {
            return 1
        } else if pickerView == timePicker {
            return 2
        } else {
            fatalError()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 397  // 0~99
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 58))
        let portion = row / 4
        let remainder = row % 4
        if remainder == 0 {
            let numberLabel = UILabel(frame: CGRect(x: 0, y: 15, width: 33, height: 23))
            let bottomImage = UIImageView(frame: CGRect(x: 0, y: 41, width: 33, height: 18))
            numberLabel.text = "\(portion)"
            numberLabel.font = .systemFont(ofSize: 20, weight: .regular)
            numberLabel.textAlignment = .center
            bottomImage.image = UIImage(named: "item-div-big")
            containerView.addSubview(numberLabel)
            containerView.addSubview(bottomImage)
            if row == selectedSizePickerRow {
                numberLabel.textColor = UIColor.white
            } else {
                numberLabel.textColor = UIColor.white
            }
        } else {
            let midImage = UIImageView(frame: CGRect(x: 0, y: 22, width: 33, height: 10))
            let bottomImage = UIImageView(frame: CGRect(x: 0, y: 47, width: 33, height: 10))
            bottomImage.image = UIImage(named: "item-div-small")
            containerView.addSubview(midImage)
            containerView.addSubview(bottomImage)
            switch remainder {
            case 1:
                if row == selectedSizePickerRow {
                    midImage.image = UIImage(named: "item-quarter-filled")
                } else {
                    midImage.image = UIImage(named: "item-quarter-empty")
                }
            case 2:
                if row == selectedSizePickerRow {
                    midImage.image = UIImage(named: "item-half-filled")
                } else {
                    midImage.image = UIImage(named: "item-half-empty")
                }
            case 3:
                if row == selectedSizePickerRow {
                    midImage.image = UIImage(named: "item-almost-filled")
                } else {
                    midImage.image = UIImage(named: "item-almost-empty")
                }
            default:
                break
            }
        }
        containerView.transform = CGAffineTransform(rotationAngle: (.pi / 2))
        return containerView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectSizePickerRow(row: row)
        pickerView.reloadAllComponents()
    }
}

extension CategoryViewController {
    
    // MARK: Private methods

    private func setupLayout() {
        // Initialize view
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = UIColor(hex: "WhiteSmoke")
        
        // Initialize subveiw properties
        detailContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.addShadowView()
            _view.layer.cornerRadius = 10
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        searchContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        sortContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        sizePickerContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.darkGray
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        scrollView = getScrollView()
        stepCollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            _collectionView.backgroundColor = UIColor.white
            _collectionView.register(StepCollectionCell.self, forCellWithReuseIdentifier: stepCellId)
            _collectionView.semanticContentAttribute = .forceLeftToRight
            _collectionView.showsHorizontalScrollIndicator = false
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        tagCollectionView = getCategoryCollectionView()
        timePicker = {
            let _datePicker = UIDatePicker()
            _datePicker.datePickerMode = .countDownTimer
            _datePicker.minuteInterval = 5
            _datePicker.addTarget(self, action: #selector(timePickerChanged(_:)), for: .valueChanged)
            _datePicker.translatesAutoresizingMaskIntoConstraints = false
            return _datePicker
        }()
        sizePickerView = {
            let _pickerView = UIPickerView()
            _pickerView.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        loadingImageView = getLoadingImageView(isHidden: false)
        fingerImageView = {
            let _imageView = UIImageView()
            _imageView.image = UIImage(named: "item-finger-click")
            _imageView.contentMode = .scaleAspectFit
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        downArrowImageView = {
            let _imageView = UIImageView()
            _imageView.image = UIImage(named: "item-arrow-down")
            _imageView.contentMode = .scaleAspectFit
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        photoImageView = {
            let _imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 290, height: 150))
            _imageView.contentMode = .scaleAspectFit
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        titleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 20, weight: .regular)
            _label.textColor = UIColor.black
            _label.textAlignment = .left
            _label.numberOfLines = 2
            _label.adjustsFontSizeToFitWidth = true
            _label.minimumScaleFactor = 0.5
            _label.allowsDefaultTighteningForTruncation = true
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        homeButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "button-home")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(homeButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        starButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "button-star-empty")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 27, height: 25)
            _button.showsTouchWhenHighlighted = true
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        logSizeButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(UIColor.tomato, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 25)
            _button.frame = CGRect(x: 0, y: 0, width: 59, height: 59)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(logButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        logTimeButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(UIColor.tomato, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 23)
            _button.frame = CGRect(x: 0, y: 0, width: 59, height: 59)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(logButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        startDateButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "button-circle-arrow")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 16, height: 17)
            _button.setTitleColor(UIColor.dimGray, for: .normal)
            _button.setTitle(lang.btnStartDate, for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(startDateButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        endDateButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "button-thin-check")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 16, height: 17)
            _button.setTitleColor(UIColor.dimGray, for: .normal)
            _button.setTitle(lang.btnEndDate, for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(endDateButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeButton)
        stepCollectionView.dataSource = self
        stepCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        sizePickerView.dataSource = self
        sizePickerView.delegate = self
        
        // Setup subviews
        view.addSubview(scrollView)
        view.addSubview(loadingImageView)
        view.addSubview(stepCollectionView)
        
        scrollView.addSubview(searchContainerView)
        scrollView.addSubview(sortContainerView)
        scrollView.addSubview(detailContainerView)
        scrollView.addSubview(tagCollectionView)
        
        detailContainerView.addSubview(titleLabel)
        detailContainerView.addSubview(starButton)
        detailContainerView.addSubview(photoImageView)
        detailContainerView.addSubview(logSizeButton)
        detailContainerView.addSubview(logTimeButton)
        detailContainerView.addSubview(startDateButton)
        detailContainerView.addSubview(endDateButton)
        detailContainerView.addSubview(fingerImageView)
        detailContainerView.addSubview(sizePickerContainerView)
        detailContainerView.addSubview(downArrowImageView)
        detailContainerView.addSubview(timePicker)
        
        sizePickerContainerView.addSubview(sizePickerView)
        
        // Setup constraints
        // loadingImageView, alertBlindView
        loadingImageView.widthAnchor.constraint(equalToConstant: 62).isActive = true
        loadingImageView.heightAnchor.constraint(equalToConstant: 62).isActive = true
        loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        // additionalTopBarView
        stepCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        stepCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        stepCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        stepCollectionView.heightAnchor.constraint(equalToConstant: stepBarHeightVal).isActive = true
        
        // scrollView
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        searchContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: stepBarHeightVal + spaceVal).isActive = true
        searchContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: spaceVal).isActive = true
        searchContainerView.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) + spaceVal).isActive = true
        searchContainerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        sortContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: stepBarHeightVal + spaceVal).isActive = true
        sortContainerView.leadingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: spaceVal).isActive = true
        sortContainerView.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 28).isActive = true
        sortContainerView.heightAnchor.constraint(equalTo: searchContainerView.heightAnchor, constant: 0).isActive = true
        
        detailContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: stepBarHeightVal + spaceVal).isActive = true
        detailContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: spaceVal).isActive = true
        detailContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: spaceVal).isActive = true
        detailContainerViewHeight = detailContainerView.heightAnchor.constraint(equalToConstant: detailBoxAHeightVal)
        detailContainerViewHeight.priority = UILayoutPriority(rawValue: 999)
        detailContainerViewHeight.isActive = true
        
        photoImageView.topAnchor.constraint(equalTo: detailContainerView.topAnchor, constant: 65).isActive = true
        photoImageView.centerXAnchor.constraint(equalTo: detailContainerView.centerXAnchor, constant: 0).isActive = true
        
        startDateButton.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor, constant: -10).isActive = true
        startDateButton.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -(view.frame.width / 10)).isActive = true
        
        endDateButton.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor, constant: -10).isActive = true
        endDateButton.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: view.frame.width / 10).isActive = true
        
        timePicker.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 7).isActive = true
        timePicker.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor, constant: 0).isActive = true
        timePicker.widthAnchor.constraint(equalToConstant: (view.frame.width / 2)).isActive = true
        timePicker.heightAnchor.constraint(equalToConstant: 125).isActive = true
        
        logTimeButton.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor, constant: -45).isActive = true
        logTimeButton.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -(view.frame.width / 10)).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: detailContainerView.topAnchor, constant: 10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -(27 + 7)).isActive = true
        
        starButton.topAnchor.constraint(equalTo: detailContainerView.topAnchor, constant: 7).isActive = true
        starButton.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -7).isActive = true
        
        // pickerContainerView
        sizePickerContainerView.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor, constant: 0).isActive = true
        sizePickerContainerView.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 0).isActive = true
        sizePickerContainerView.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: 0).isActive = true
        sizePickerContainerView.heightAnchor.constraint(equalToConstant: 58).isActive = true
        
        sizePickerView.centerXAnchor.constraint(equalTo: sizePickerContainerView.centerXAnchor, constant: 0).isActive = true
        sizePickerView.centerYAnchor.constraint(equalTo: sizePickerContainerView.centerYAnchor, constant: 0).isActive = true
        sizePickerView.widthAnchor.constraint(equalToConstant: 58).isActive = true
        sizePickerView.heightAnchor.constraint(equalToConstant: view.frame.width + 200).isActive = true
        
        downArrowImageView.centerXAnchor.constraint(equalTo: detailContainerView.centerXAnchor, constant: 0).isActive = true
        downArrowImageView.topAnchor.constraint(equalTo: sizePickerContainerView.topAnchor, constant: -1).isActive = true
        
        logSizeButton.bottomAnchor.constraint(equalTo: sizePickerContainerView.topAnchor, constant: -5).isActive = true
        logSizeButton.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -(view.frame.width / 5)).isActive = true
        
        fingerImageBottom = fingerImageView.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor, constant: -75)
        fingerImageBottom.priority = UILayoutPriority(rawValue: 999)
        fingerImageBottom.isActive = true
        fingerImageView.leadingAnchor.constraint(equalTo: logSizeButton.trailingAnchor, constant: 8).isActive = true
        
        // addBar: 35, space: 7, searchBar: 45, space: 7
        tagCollectionViewTop = tagCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: stepBarHeightVal + 7 + 45 + 7)
        tagCollectionViewTop.priority = UILayoutPriority(rawValue: 999)
        tagCollectionViewTop.isActive = true
        tagCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 7).isActive = true
        tagCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 7).isActive = true
        tagCollectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        tagCollectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0).isActive = true
        tagCollectionViewHeight = tagCollectionView.heightAnchor.constraint(equalToConstant: 45 + 7)
        tagCollectionViewHeight.priority = UILayoutPriority(rawValue: 999)
        tagCollectionViewHeight.isActive = true
    }
    
    private func didSelectSizePickerRow(row: Int) {
        let portion = row / 4
        let remainder = row % 4
        selectedSizePickerRow = row
        if portion <= 0 {
            switch remainder {
            case 0:
                // Case select nothing
                sizePickerView.selectRow(1, inComponent: 0, animated: true)
                logSizeButton.setTitle("¼", for: .normal)
                // "0 + 1/4"
                selectedXVal = 0
                selectedYVal = 1
                selectedSizePickerRow = 1
            case 1:
                logSizeButton.setTitle("¼", for: .normal)
                // "0 + 1/4"
                selectedXVal = 0
                selectedYVal = 1
            case 2:
                logSizeButton.setTitle("½", for: .normal)
                // "0 + 1/2"
                selectedXVal = 0
                selectedYVal = 2
            case 3:
                logSizeButton.setTitle("¾", for: .normal)
                // "0 + 3/4"
                selectedXVal = 0
                selectedYVal = 3
            default:
                return
            }
        } else {
            switch remainder {
            case 0:
                logSizeButton.setTitle("\(portion)", for: .normal)
                // "n + 0"
                selectedXVal = portion
                selectedYVal = 0
            case 1:
                logSizeButton.setTitle("\(portion)¼", for: .normal)
                // "n + 1/4"
                selectedXVal = portion
                selectedYVal = 1
            case 2:
                logSizeButton.setTitle("\(portion)½", for: .normal)
                // "n + 1/2"
                selectedXVal = portion
                selectedYVal = 2
            case 3:
                logSizeButton.setTitle("\(portion)¾", for: .normal)
                // "n + 3/4"
                selectedXVal = portion
                selectedYVal = 3
            default:
                return
            }
        }
    }
    
    private func afterFetchCategoriesTransition(_ superTag: BaseModel.Tag, _ subTags: [BaseModel.Tag]) {
        if superTag.tag_type == TagType.category {
            // Execute category tag_type exclusive
            switch lang.currentLanguageId {
            case LanguageId.eng: navigationItem.title = superTag.eng_name
            case LanguageId.kor: navigationItem.title = superTag.kor_name!
            default: fatalError()}
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = true
                self.searchContainerView.isHidden = false
                self.sortContainerView.isHidden = false
                self.tagCollectionViewTop.constant = stepBarHeightVal + spaceVal + 45 + spaceVal
            }
        } else {
            // Lines for non-cateogry tag_types
            switch lang.currentLanguageId {
            case LanguageId.eng: titleLabel.text = superTag.eng_name
            case LanguageId.kor: titleLabel.text = superTag.kor_name
            case LanguageId.jpn: titleLabel.text = superTag.jpn_name
            default: fatalError()}
        }
        if superTag.tag_type == TagType.food || superTag.tag_type == TagType.drug {
            // Execute food and drug tag_type exclusive
            sizePickerView.selectRow(4, inComponent: 0, animated: true)
            didSelectSizePickerRow(row: 4)
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = false
                self.searchContainerView.isHidden = true
                self.sortContainerView.isHidden = true
                self.detailContainerViewHeight.constant = detailBoxAHeightVal
                self.tagCollectionViewTop.constant = stepBarHeightVal + spaceVal + detailBoxAHeightVal + spaceVal
                
                self.fingerImageBottom.constant = -75
                self.downArrowImageView.isHidden = false
                self.logSizeButton.isHidden = false
                self.sizePickerContainerView.isHidden = false
                self.logTimeButton.isHidden = true
                self.timePicker.isHidden = true
                self.startDateButton.isHidden = true
                self.endDateButton.isHidden = true
                
                self.photoImageView.image = UIImage(named: "photo-pills")
            }
        } else if superTag.tag_type == TagType.activity {
            // Execute activity tag_type exclusive
            selectedXVal = 0
            selectedYVal = 5
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = 0
            components.minute = 5
            self.timePicker.setDate(calendar.date(from: components)!, animated: true)
            logTimeButton.setTitle("5min", for: .normal)
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = false
                self.searchContainerView.isHidden = true
                self.sortContainerView.isHidden = true
                self.detailContainerViewHeight.constant = detailBoxBHeightVal
                self.tagCollectionViewTop.constant = stepBarHeightVal + spaceVal + detailBoxBHeightVal + spaceVal
                
                self.fingerImageBottom.constant = -20
                self.downArrowImageView.isHidden = true
                self.logSizeButton.isHidden = true
                self.sizePickerContainerView.isHidden = true
                self.logTimeButton.isHidden = false
                self.timePicker.isHidden = false
                self.startDateButton.isHidden = true
                self.endDateButton.isHidden = true
                
                self.photoImageView.image = UIImage(named: "photo-walking")
            }
        } else if superTag.tag_type == TagType.condition {
            // Execute condition tag_type exclusive
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = false
                self.searchContainerView.isHidden = true
                self.sortContainerView.isHidden = true
                self.detailContainerViewHeight.constant = detailBoxCHeightVal
                self.tagCollectionViewTop.constant = stepBarHeightVal + spaceVal + detailBoxCHeightVal + spaceVal
                
                self.fingerImageView.isHidden = true
                self.downArrowImageView.isHidden = true
                self.logSizeButton.isHidden = true
                self.sizePickerContainerView.isHidden = true
                self.logTimeButton.isHidden = true
                self.timePicker.isHidden = true
                self.startDateButton.isHidden = false
                self.endDateButton.isHidden = false
                
                self.photoImageView.image = UIImage(named: "photo-walking")
            }
        }
        
        // For all types
        self.subTags = subTags
        let tagsCnt = subTags.count
        self.stepCollectionView.reloadData()
        UIView.transition(with: self.tagCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.tagCollectionView.reloadData()
            self.tagCollectionViewHeight.constant = self.getCategoryCollectionViewHeight(tagsCnt)
            self.loadingImageView.isHidden = true
            self.tagCollectionView.isHidden = false
        })
    }
    
    private func loadCategories() {
        UIView.transition(with: self.loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.tagCollectionView.isHidden = true
            self.loadingImageView.isHidden = false
        })
        let service = Service(lang: lang)
        service.fetchTagSets(tagId: superTag.id, sortType: SortType.score, popoverAlert: { (message) in
            self.retryFunction = self.loadCategories
            self.alertError(message)
        }) { (tagSet) in
            self.afterFetchCategoriesTransition(tagSet.tag, tagSet.sub_tags)
        }
    }
    
    private func postAConditionLog() {
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        var params = Parameters()
        params = [
            "avatar_id": avatarId,
            "tag_id": superTag!.id,
            "cond_log_type": cond_log_type!,
            "log_date": selectedDate!
        ]
        let service = Service(lang: lang)
        service.dispatchACondLog(params: params, popoverAlert: { (message) in
            self.retryFunction = self.postAConditionLog
            self.detailContainerView.isHidden = true
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.postAConditionLog()
        }) {
            UIView.transition(with: self.loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.detailContainerView.isHidden = false
                self.loadingImageView.isHidden = true
            }, completion: { (_) in
                switch self.lang.currentLanguageId {
                case LanguageId.eng: self.alertCompl(self.lang.msgIntakeLogComplete(self.superTag!.eng_name))
                case LanguageId.kor: self.alertCompl(self.lang.msgIntakeLogComplete(self.superTag!.kor_name!))
                case LanguageId.jpn: self.alertCompl(self.lang.msgIntakeLogComplete(self.superTag!.jpn_name!))
                default: fatalError()}
            })
        }
    }
}