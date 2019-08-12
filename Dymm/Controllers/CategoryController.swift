//
//  CategoryController.swift
//  Flava
//
//  Created by eunsang lee on 17/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

private let tagCellId = "TagCell"
private let stepCellId = "StepCell"

private let stepBarHeightVal: CGFloat = 40
private let spaceVal: CGFloat = 7
private let detailBoxAHeightVal: CGFloat = 350
private let detailBoxBHeightVal: CGFloat = 333
private let detailBoxCHeightVal: CGFloat = 265

class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    let stepCollectionView: UICollectionView = {
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
    var scrollView: UIScrollView!
    var tagCollectionView: UICollectionView!
    var tagCollectionViewTop: NSLayoutConstraint!
    var tagCollectionViewHeight: NSLayoutConstraint!
    let detailContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        _view.addShadowView()
        _view.layer.cornerRadius = 10
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    var detailContainerViewHeight: NSLayoutConstraint!
    let titleLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 20, weight: .regular)
        _label.textColor = UIColor.black
        _label.textAlignment = .left
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    let starButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setImage(UIImage(named: "button-star-empty")!.withRenderingMode(.alwaysOriginal), for: .normal)
        _button.frame = CGRect(x: 0, y: 0, width: 27, height: 25)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    let logSizeButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setTitleColor(UIColor.tomato, for: .normal)
        _button.titleLabel?.font = .systemFont(ofSize: 25)
        _button.frame = CGRect(x: 0, y: 0, width: 59, height: 59)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    let logTimeButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setTitleColor(UIColor.tomato, for: .normal)
        _button.titleLabel?.font = .systemFont(ofSize: 20)
        _button.frame = CGRect(x: 0, y: 0, width: 59, height: 59)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    let fingerImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.image = UIImage(named: "item-finger-click")
        _imageView.contentMode = .scaleAspectFit
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    var fingerImageBottom: NSLayoutConstraint!
    let downArrowImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.image = UIImage(named: "item-arrow-down")
        _imageView.contentMode = .scaleAspectFit
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    let timePickerView: UIPickerView = {
        let _pickerView = UIPickerView()
        _pickerView.translatesAutoresizingMaskIntoConstraints = false
        return _pickerView
    }()
    let sizePickerContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.darkGray
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let sizePickerView: UIPickerView = {
        let _pickerView = UIPickerView()
        _pickerView.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
        _pickerView.translatesAutoresizingMaskIntoConstraints = false
        return _pickerView
    }()
    let searchContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        _view.addShadowView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let sortContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        _view.addShadowView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let homeButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setImage(UIImage(named: "button-home")!.withRenderingMode(.alwaysOriginal), for: .normal)
        _button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var loadingImageView: UIImageView!
    
    var superTag: BaseModel.Tag!
    var subTags: [BaseModel.Tag]!
    var stepTags: [BaseModel.Tag] = []
    var selectedXVal: Int?
    var selectedYVal: Int?
    var selectedSizePickerRow: Int = 4
    var selectedHourPickerRow: Int = 0
    var selectedMinPickerRow: Int = 1
    let hours: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    let mins: [Int] = [0, 10, 20, 30, 40, 50]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutStyles()
        setupLayoutSubviews()
        stepCollectionView.dataSource = self
        stepCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        sizePickerView.dataSource = self
        sizePickerView.delegate = self
        timePickerView.dataSource = self
        timePickerView.delegate = self
        setupLayoutConstraints()
        setupProperties()
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
        } else if pickerView == timePickerView {
            return 2
        } else {
            fatalError()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == sizePickerView {
            return 397  // 0~99
        } else if pickerView == timePickerView {
            if component == 0 {
                return hours.count
            } else {
                return mins.count
            }
        } else {
            fatalError()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if pickerView == sizePickerView {
            return 35
        } else if pickerView == timePickerView {
            return 40
        } else {
            fatalError()
        }
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView == timePickerView {
            let _containerView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
            let _label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
            _label.textAlignment = .center
            if component == 0 {
                if row == selectedHourPickerRow {
                    _label.text = "\(hours[row]) hours"
                } else {
                    _label.text = "\(hours[row])"
                }
            } else {
                if row == selectedMinPickerRow {
                    _label.text = "\(mins[row]) min"
                } else {
                    _label.text = "\(mins[row])"
                }
            }
            _containerView.addSubview(_label)
            return _containerView
        }
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
        if pickerView == sizePickerView {
            didSelectSizePickerRow(row: row)
            pickerView.reloadAllComponents()
        } else if pickerView == timePickerView {
            if component == 0 {
                selectedHourPickerRow = row
                selectedXVal = hours[row]
            } else {
                selectedMinPickerRow = row
                selectedYVal = mins[row]
            }
            
            var hr = ""
            var min = ""
            if selectedXVal != 0 {
                hr = "\(selectedXVal!)hr"
            }
            if selectedYVal != 0 {
                min = "\(selectedYVal!)min"
            }
            logTimeButton.setTitle("\(hr) \(min)", for: .normal)
            pickerView.reloadAllComponents()
        }
    }
}

extension CategoryViewController {
    
    // MARK: Private methods
    
    private func setupLayoutStyles() {
        view.backgroundColor = UIColor(hex: "WhiteSmoke")
    }
    
    private func setupLayoutSubviews() {
        loadingImageView = getLoadingImageView(isHidden: false)
        scrollView = getScrollView()
        tagCollectionView = getCategoryCollectionView()
        
        view.addSubview(scrollView)
        view.addSubview(loadingImageView)
        view.addSubview(stepCollectionView)
        
        scrollView.addSubview(searchContainerView)
        scrollView.addSubview(sortContainerView)
        scrollView.addSubview(detailContainerView)
        scrollView.addSubview(tagCollectionView)
        
        detailContainerView.addSubview(titleLabel)
        detailContainerView.addSubview(starButton)
        detailContainerView.addSubview(logSizeButton)
        detailContainerView.addSubview(logTimeButton)
        detailContainerView.addSubview(fingerImageView)
        detailContainerView.addSubview(sizePickerContainerView)
        detailContainerView.addSubview(downArrowImageView)
        detailContainerView.addSubview(timePickerView)
        
        sizePickerContainerView.addSubview(sizePickerView)
    }
    
    // MARK: - SetupLayoutConstraints
    
    private func setupLayoutConstraints() {
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
        searchContainerView.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width / 2) + spaceVal).isActive = true
        searchContainerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        sortContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: stepBarHeightVal + spaceVal).isActive = true
        sortContainerView.leadingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: spaceVal).isActive = true
        sortContainerView.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width / 2) - 28).isActive = true
        sortContainerView.heightAnchor.constraint(equalTo: searchContainerView.heightAnchor, constant: 0).isActive = true
        
        detailContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: stepBarHeightVal + spaceVal).isActive = true
        detailContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: spaceVal).isActive = true
        detailContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: spaceVal).isActive = true
        detailContainerViewHeight = detailContainerView.heightAnchor.constraint(equalToConstant: detailBoxAHeightVal)
        detailContainerViewHeight.priority = UILayoutPriority(rawValue: 999)
        detailContainerViewHeight.isActive = true
        
        timePickerView.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 0).isActive = true
        timePickerView.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor, constant: 0).isActive = true
        timePickerView.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width / 2) - 10).isActive = true
        timePickerView.heightAnchor.constraint(equalToConstant: 125).isActive = true
        
        logTimeButton.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor, constant: -45).isActive = true
        logTimeButton.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -(view.frame.width / 7)).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: detailContainerView.topAnchor, constant: 10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 10).isActive = true
        
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
    
    // MARK: - SetupProperties
    
    private func setupProperties() {
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeButton)
        homeButton.addTarget(self, action:#selector(homeButtonTapped), for: .touchUpInside)
        logSizeButton.addTarget(self, action: #selector(logButtonTapped), for: .touchUpInside)
        logTimeButton.addTarget(self, action: #selector(logButtonTapped), for: .touchUpInside)
        loadCategories()
    }
    
    private func alertError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnDone, style: .default) { _ in
            self.retryFunction!()
        }
        let cancelAction = UIAlertAction(title: lang.btnCancel, style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
    
    private func beforeFatchCategoriesTransition() {
        UIView.transition(with: self.loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.tagCollectionView.isHidden = true
            self.loadingImageView.isHidden = false
        })
    }
    
    private func afterFetchCategoriesTransition(_ superTag: BaseModel.Tag, _ subTags: [BaseModel.Tag]) {
        switch lang.currentLanguageId {
        case LanguageId.eng: navigationItem.title = superTag.eng_name
        case LanguageId.kor: navigationItem.title = superTag.kor_name!
        default: fatalError()}
        if superTag.tag_type == TagType.category {
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = true
                self.searchContainerView.isHidden = false
                self.sortContainerView.isHidden = false
                self.tagCollectionViewTop.constant = stepBarHeightVal + spaceVal + 45 + spaceVal
            }
        } else if superTag.tag_type == TagType.food || superTag.tag_type == TagType.drug {
            switch lang.currentLanguageId {
            case LanguageId.eng: titleLabel.text = superTag.eng_name
            case LanguageId.kor: titleLabel.text = superTag.kor_name
            case LanguageId.jpn: titleLabel.text = superTag.jpn_name
            default: fatalError()}
            sizePickerView.selectRow(4, inComponent: 0, animated: true)
            didSelectSizePickerRow(row: 4)
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = false
                self.searchContainerView.isHidden = true
                self.sortContainerView.isHidden = true
                self.detailContainerViewHeight.constant = detailBoxAHeightVal
                self.tagCollectionViewTop.constant = stepBarHeightVal + spaceVal + detailBoxAHeightVal + spaceVal
                
                self.fingerImageBottom.constant = -75
                self.logSizeButton.isHidden = false
                self.sizePickerContainerView.isHidden = false
                self.logTimeButton.isHidden = true
                self.timePickerView.isHidden = true
            }
        } else if superTag.tag_type == TagType.activity {
            switch lang.currentLanguageId {
            case LanguageId.eng: titleLabel.text = superTag.eng_name
            case LanguageId.kor: titleLabel.text = superTag.kor_name
            case LanguageId.jpn: titleLabel.text = superTag.jpn_name
            default: fatalError()}
            timePickerView.selectRow(0, inComponent: 0, animated: true)
            selectedXVal = 0
            timePickerView.selectRow(1, inComponent: 1, animated: true)
            selectedYVal = 10
            logTimeButton.setTitle("10min", for: .normal)
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = false
                self.searchContainerView.isHidden = true
                self.sortContainerView.isHidden = true
                self.detailContainerViewHeight.constant = detailBoxBHeightVal
                self.tagCollectionViewTop.constant = stepBarHeightVal + spaceVal + detailBoxBHeightVal + spaceVal
                
                self.fingerImageBottom.constant = -30
                self.logSizeButton.isHidden = true
                self.sizePickerContainerView.isHidden = true
                self.logTimeButton.isHidden = false
                self.timePickerView.isHidden = false
            }
        }
        
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
        beforeFatchCategoriesTransition()
        let service = Service(lang: lang)
        service.fetchTagSets(tagId: superTag.id, sortType: SortType.score, popoverAlert: { (message) in
            self.retryFunction = self.loadCategories
            self.alertError(message)
        }) { (tagSet) in
            self.afterFetchCategoriesTransition(tagSet.tag, tagSet.sub_tags)
        }
    }
}
