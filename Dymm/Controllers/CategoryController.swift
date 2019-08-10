//
//  CategoryController.swift
//  Flava
//
//  Created by eunsang lee on 17/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

private let tagCellId = "TagCell"

class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    var loadingImageView: UIImageView!
    var additionalTopBarView: UIView!
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
    let targetButton: UIButton = {
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
        _imageView.image = #imageLiteral(resourceName: "item-finger-click")
        _imageView.contentMode = .scaleAspectFit
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    let downArrowImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.image = #imageLiteral(resourceName: "item-arrow-down")
        _imageView.contentMode = .scaleAspectFit
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    let pickerContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.darkGray
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let pickerView: UIPickerView = {
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
    var superTag: BaseModel.Tag!
    var subTags: [BaseModel.Tag]!
    var footstepTag: BaseModel.Tag?
    var selectedNumber: Int?
    var selectedFraction: Int?
    var selectedPickerRow: Int = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutStyles()
        setupLayoutSubviews()
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        pickerView.dataSource = self
        pickerView.delegate = self
        setupLayoutConstraints()
        setupProperties()
    }
    
    // MARK: - Actions
    
    @objc func homeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func footstepButtonTapped() {
        superTag = footstepTag
        loadCategories()
    }
    
    @objc func targetButtonTapped() {
        let vc = DiaryViewController()
        vc.diaryStat = DiaryStat.log
        vc.logType = LogType.food
        vc.selectedTag = superTag!
        vc.logNumber = selectedNumber!
        vc.logFraction = selectedFraction!
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
        guard let number = subTags?.count else {
            return 0
        }
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as? TagCollectionCell else {
            fatalError()
        }
        let tag = subTags[indexPath.row]
        switch lang.currentLanguageId {
        case LanguageId.eng: cell.label.text = tag.eng_name
        case LanguageId.kor: cell.label.text = tag.kor_name
        default: fatalError()}
        cell.imageView.image = UIImage(named: "tagId-\(tag.id)")
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected_tag = subTags[indexPath.item]
        let footstepButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
        switch lang.currentLanguageId {
        case LanguageId.eng: footstepButton.setTitle(superTag.eng_name, for: .normal)
        case LanguageId.kor: footstepButton.setTitle(superTag.kor_name, for: .normal)
        default: fatalError()}
        footstepButton.setTitleColor(UIColor(hex: "Black"), for: .normal)
        footstepButton.titleLabel?.font = .systemFont(ofSize: 14)
        footstepButton.addTarget(self, action:#selector(footstepButtonTapped), for: .touchUpInside)
        footstepButton.showsTouchWhenHighlighted = true
        additionalTopBarView.addSubview(footstepButton)
        footstepTag = superTag
        superTag = selected_tag
        loadCategories()
    }
    
    // MARK: - UICollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: (screenWidth / 2) - 10.5, height: CGFloat(45))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}

extension CategoryViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
            if row == selectedPickerRow {
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
                if row == selectedPickerRow {
                    midImage.image = UIImage(named: "item-quarter-filled")
                } else {
                    midImage.image = UIImage(named: "item-quarter-empty")
                }
            case 2:
                if row == selectedPickerRow {
                    midImage.image = UIImage(named: "item-half-filled")
                } else {
                    midImage.image = UIImage(named: "item-half-empty")
                }
            case 3:
                if row == selectedPickerRow {
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
        didSelectPickerViewRow(row: row)
        pickerView.reloadAllComponents()
    }
}

extension CategoryViewController {
    
    // MARK: Private methods
    
    private func setupLayoutStyles() {
        view.backgroundColor = UIColor(hex: "WhiteSmoke")
    }
    
    private func setupLayoutSubviews() {
        loadingImageView = getLoadingImageView(isHidden: false)
        additionalTopBarView = getAddtionalTopBarView()
        scrollView = getScrollView()
        tagCollectionView = getCategoryCollectionView()
        
        view.addSubview(scrollView)
        view.addSubview(loadingImageView)
        view.addSubview(additionalTopBarView)
        
        scrollView.addSubview(searchContainerView)
        scrollView.addSubview(sortContainerView)
        scrollView.addSubview(detailContainerView)
        scrollView.addSubview(tagCollectionView)
        
        detailContainerView.addSubview(titleLabel)
        detailContainerView.addSubview(starButton)
        detailContainerView.addSubview(targetButton)
        detailContainerView.addSubview(fingerImageView)
        detailContainerView.addSubview(pickerContainerView)
        detailContainerView.addSubview(downArrowImageView)
        
        pickerContainerView.addSubview(pickerView)
    }
    
    // MARK: - SetupLayoutConstraints
    
    private func setupLayoutConstraints() {
        // loadingImageView, alertBlindView
        loadingImageView.widthAnchor.constraint(equalToConstant: 62).isActive = true
        loadingImageView.heightAnchor.constraint(equalToConstant: 62).isActive = true
        loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        // additionalTopBarView
        additionalTopBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        additionalTopBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        additionalTopBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        additionalTopBarView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        // scrollView
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        searchContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 35 + 7).isActive = true
        searchContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 7).isActive = true
        searchContainerView.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width / 2) + 7).isActive = true
        searchContainerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        sortContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 35 + 7).isActive = true
        sortContainerView.leadingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: 7).isActive = true
        sortContainerView.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width / 2) - 28).isActive = true
        sortContainerView.heightAnchor.constraint(equalTo: searchContainerView.heightAnchor, constant: 0).isActive = true
        
        detailContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 35 + 7).isActive = true
        detailContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 7).isActive = true
        detailContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 7).isActive = true
        detailContainerViewHeight = detailContainerView.heightAnchor.constraint(equalToConstant: 350)
        detailContainerViewHeight.priority = UILayoutPriority(rawValue: 999)
        detailContainerViewHeight.isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: detailContainerView.topAnchor, constant: 10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 10).isActive = true
        
        starButton.topAnchor.constraint(equalTo: detailContainerView.topAnchor, constant: 7).isActive = true
        starButton.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -7).isActive = true
        
        // pickerContainerView
        pickerContainerView.bottomAnchor.constraint(equalTo: detailContainerView.bottomAnchor, constant: 0).isActive = true
        pickerContainerView.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 0).isActive = true
        pickerContainerView.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: 0).isActive = true
        pickerContainerView.heightAnchor.constraint(equalToConstant: 58).isActive = true
        
        pickerView.centerXAnchor.constraint(equalTo: pickerContainerView.centerXAnchor, constant: 0).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: pickerContainerView.centerYAnchor, constant: 0).isActive = true
        pickerView.widthAnchor.constraint(equalToConstant: 58).isActive = true
        pickerView.heightAnchor.constraint(equalToConstant: view.frame.width + 200).isActive = true
        
        downArrowImageView.centerXAnchor.constraint(equalTo: detailContainerView.centerXAnchor, constant: 0).isActive = true
        downArrowImageView.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: -1).isActive = true
        
        targetButton.bottomAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: -5).isActive = true
        targetButton.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -(view.frame.width / 5)).isActive = true
        
        fingerImageView.bottomAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: -15).isActive = true
        fingerImageView.leadingAnchor.constraint(equalTo: targetButton.trailingAnchor, constant: 8).isActive = true
        
        // addBar: 35, space: 7, searchBar: 45, space: 7
        tagCollectionViewTop = tagCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 35 + 7 + 45 + 7)
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
        targetButton.addTarget(self, action: #selector(targetButtonTapped), for: .touchUpInside)
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
    
    private func didSelectPickerViewRow(row: Int) {
        let portion = row / 4
        let remainder = row % 4
        selectedPickerRow = row
        if portion <= 0 {
            switch remainder {
            case 0:
                // Case select nothing
                pickerView.selectRow(1, inComponent: 0, animated: true)
                targetButton.setTitle("¼", for: .normal)
                // "0 + 1/4"
                selectedNumber = 0
                selectedFraction = 1
                selectedPickerRow = 1
            case 1:
                targetButton.setTitle("¼", for: .normal)
                // "0 + 1/4"
                selectedNumber = 0
                selectedFraction = 1
            case 2:
                targetButton.setTitle("½", for: .normal)
                // "0 + 1/2"
                selectedNumber = 0
                selectedFraction = 2
            case 3:
                targetButton.setTitle("¾", for: .normal)
                // "0 + 3/4"
                selectedNumber = 0
                selectedFraction = 3
            default:
                return
            }
        } else {
            switch remainder {
            case 0:
                targetButton.setTitle("\(portion)", for: .normal)
                // "n + 0"
                selectedNumber = portion
                selectedFraction = 0
            case 1:
                targetButton.setTitle("\(portion)¼", for: .normal)
                // "n + 1/4"
                selectedNumber = portion
                selectedFraction = 1
            case 2:
                targetButton.setTitle("\(portion)½", for: .normal)
                // "n + 1/2"
                selectedNumber = portion
                selectedFraction = 2
            case 3:
                targetButton.setTitle("\(portion)¾", for: .normal)
                // "n + 3/4"
                selectedNumber = portion
                selectedFraction = 3
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
        self.subTags = subTags
        let tagsCnt = subTags.count
        
        if superTag.tag_type == TagType.category {
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = true
                self.searchContainerView.isHidden = false
                self.sortContainerView.isHidden = false
                self.tagCollectionViewTop.constant = 35 + 7 + 45 + 7
            }
        } else if superTag.tag_type == TagType.food || superTag.tag_type == TagType.drug {
            switch lang.currentLanguageId {
            case LanguageId.eng: titleLabel.text = superTag.eng_name
            case LanguageId.kor: titleLabel.text = superTag.kor_name
            case LanguageId.jpn: titleLabel.text = superTag.jpn_name
            default: fatalError()}
            didSelectPickerViewRow(row: 4)
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = false
                self.searchContainerView.isHidden = true
                self.sortContainerView.isHidden = true
                self.detailContainerViewHeight.constant = 350
                self.tagCollectionViewTop.constant = 35 + 7 + 350 + 7
            }
        } else if superTag.tag_type == TagType.activity {
            switch lang.currentLanguageId {
            case LanguageId.eng: titleLabel.text = superTag.eng_name
            case LanguageId.kor: titleLabel.text = superTag.kor_name
            case LanguageId.jpn: titleLabel.text = superTag.jpn_name
            default: fatalError()}
            UIView.animate(withDuration: 0.5) {
                self.detailContainerView.isHidden = false
                self.searchContainerView.isHidden = true
                self.sortContainerView.isHidden = true
                self.detailContainerViewHeight.constant = 333
                self.tagCollectionViewTop.constant = 35 + 7 + 333 + 7
            }
        }
        
        UIView.transition(with: self.tagCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.tagCollectionView.reloadData()
            self.tagCollectionViewHeight.constant = self.getCategoryCollectionViewHeight(tagsCnt)
            self.loadingImageView.isHidden = true
            self.tagCollectionView.isHidden = false
        })
        switch lang.currentLanguageId {
        case LanguageId.eng: navigationItem.title = superTag.eng_name
        case LanguageId.kor: navigationItem.title = superTag.kor_name!
        default: fatalError()}
    }
    
    private func loadCategories() {
        beforeFatchCategoriesTransition()
        let service = Service(lang: lang)
        service.fetchTagSets(tagId: superTag.id, sortType: SortType.score, popoverAlert: { (message) in
            self.retryFunction = self.loadCategories
            self.alertError(message)
        }) { (tagSet) in
            self.afterFetchCategoriesTransition(tagSet.tag, tagSet.sub_tags)
            print("Load categories complete.")
        }
    }
}
