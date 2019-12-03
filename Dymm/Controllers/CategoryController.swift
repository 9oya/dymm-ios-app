//
//  CategoryController.swift
//  Flava
//
//  Created by eunsang lee on 17/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit
import Alamofire

private let stepCellId = "StepCell"

private let stepBarHeightInt = 40
private let searchBarHeightInt = 40
private let detailBoxAHeightInt = 312
private let detailBoxBHeightInt = 312
private let detailBoxCHeightInt = 265

class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    // UIViews
    var detailContainer: UIView!
    var sizePickerContainer: UIView!
    
    // UICollectionViews
    var stepCollection: UICollectionView!
    var tagCollection: UICollectionView!
    
    // UIPickerViews
    var timePicker: UIDatePicker!
    var sizePicker: UIPickerView!
    var langPicker: UIPickerView!
    
    // UIImageViews
    var downArrowImageView: UIImageView!
    var photoImageView: UIImageView!
    var gradientBackImage: UIImageView!
    
    // UITextField
    var searchTextField: UITextField!
    
    // UILabels
    var titleLabel: UILabel!
    var bookmarksTotalLabel: UILabel!
    var logSizeLabel: UILabel!
    var logTimeLabel: UILabel!
    
    // UIButtons
    var homeButton: UIButton!
    var starButton: UIButton!
    var logSizeButton: UIButton!
    var startDateButton: UIButton!
    var endDateButton: UIButton!
    var langPickButton: UIButton!
    var sendOpinionBtn: UIButton!
    
    // NSLayoutConstraints
    var tagCollectionTop: NSLayoutConstraint!
    var tagCollectionViewHeight: NSLayoutConstraint!
    var detailContainerHeight: NSLayoutConstraint!
    var fingerImageBottom: NSLayoutConstraint!
    
    // Non-view properties
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: getUserCountryCode())
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    var superTag: BaseModel.Tag?
    var superTagId: Int?
    var subTags: [BaseModel.Tag]!
    var stepTags: [BaseModel.Tag] = []
    var langTags: [BaseModel.Tag]?
    var selectedLangTag: BaseModel.Tag?
    var selectedXVal: Int?
    var selectedYVal: Int?
    var selectedDate: String?
    var cond_log_type: Int?
    var selectedSizePickerRow: Int = 4
    var selectedHourPickerRow: Int = 0
    var selectedMinPickerRow: Int = 1
    let hours: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    let mins: [Int] = [0, 10, 20, 30, 40, 50]
    var topLeftButtonType = ButtonType.home
    var bookmark_id: Int?
    var typedKeyword: String?
    let hangulChars = "ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ".unicodeScalars
    //    let engChars = "abcdefghijklmnopqrstuvwxygABCDEFGHIJKLMNOPQRSTUVWXYZ".unicodeScalars
    var lastContentOffset: CGFloat = 0.0
    var isScrollToLoading: Bool = false
    var currPageNum: Int = 1
    var minimumCnt: Int = 40
    var opinion: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadCategories()
    }
    
    // MARK: - Actions
    
    @objc func alertError(_ message: String) {
        view.hideSpinner()
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lang.titleYes, style: .default) { _ in
            self.retryFunction!()
        })
        alert.addAction(UIAlertAction(title: lang.titleNo, style: .cancel) { _ in })
        alert.view.tintColor = .mediumSeaGreen
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertDatePicker(cond_log_type: Int) {
        self.cond_log_type = cond_log_type
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.timeZone = NSTimeZone.local
        datePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
        datePicker.datePickerMode = .date
        var title = ""
        if cond_log_type == CondLogType.startDate {
            title = "\(lang.titleStartDate!)\n\n\n\n\n\n\n\n"
        } else {
            title = "\(lang.titleEndDate!)\n\n\n\n\n\n\n\n"
        }
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.view.addSubview(datePicker)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            self.selectedDate = self.dateFormatter.string(from: datePicker.date)
            UIView.transition(with: self.detailContainer, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.detailContainer.isHidden = true
            })
            self.createAConditionLog()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        if cond_log_type == CondLogType.startDate {
            alert.view.tintColor = .mediumSeaGreen
        } else {
            alert.view.tintColor = .hex_fe4c4c
        }
        present(alert, animated: true, completion:{})
    }
    
    @objc func alertLangPicker() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.view.addSubview(langPicker)
        langPicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleClose, style: .default) { _ in })
        langPicker.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
            if let langId = self.selectedLangTag?.id {
                self.lang = LangPack(langId)
                UIView.transition(with: self.langPickButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.langPickButton.setTitle(LangHelper.getLanguageName(langId), for: .normal)
                })
            } else {
                self.lang = LangPack(LanguageId.eng)
                UIView.transition(with: self.langPickButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.langPickButton.setTitle(LangHelper.getLanguageName(LanguageId.eng), for: .normal)
                })
            }
            self.tagCollection.reloadData()
            self.stepCollection.reloadData()
        })
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 260)
        alert.view.addConstraint(height)
        alert.view.tintColor = .mediumSeaGreen
        self.present(alert, animated: true, completion: nil )
    }
    
    @objc func alertCompl(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleYes, style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: lang.titleNo, style: .cancel) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .mediumSeaGreen
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertOpinionTextView(_ sender: UITapGestureRecognizer? = nil) {
        var message = ""
        switch lang.currentLanguageId {
        case LanguageId.eng: message = superTag!.eng_name
        case LanguageId.kor: message = superTag!.kor_name!
        default: fatalError() }
        let alert = UIAlertController(title: lang.titleOpinion, message: message, preferredStyle: .alert)
        let noteTextView: UITextView = {
            let _textView = UITextView()
            _textView.backgroundColor = .white
            _textView.font = .systemFont(ofSize: 15, weight: .light)
            _textView.translatesAutoresizingMaskIntoConstraints = false
            return _textView
        }()
        noteTextView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let controller = UIViewController()
        noteTextView.frame = controller.view.frame
        controller.view.addSubview(noteTextView)
        alert.setValue(controller, forKey: "contentViewController")
        let confirmAction = UIAlertAction(title: lang.titleSubmit, style: .default) { _ in
            if let text = noteTextView.text {
                self.opinion = text
                if self.opinion == "" {
                    return
                } else if self.opinion!.count < 5 {
                    return
                }
                self.submitOpinion()
            }
        }
        let cancelAction = UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .mediumSeaGreen
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func presentAuthNavigation() {
        let vc = AuthViewController()
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func homeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func starButtonTapped() {
        if UserDefaults.standard.isSignIn() {
            if bookmark_id != nil {
                removeBookmark()
            } else {
                createBookmark()
            }
        } else {
            presentAuthNavigation()
        }
    }
    
    @objc func logButtonTapped(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.05, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            UIButton.animate(withDuration: 0.05, animations: {
                sender.transform = CGAffineTransform.identity
            }) { (_) in
                if UserDefaults.standard.isSignIn() {
                    let vc = DiaryViewController()
                    vc.diaryMode = DiaryMode.logger
                    vc.selectedTag = self.superTag!
                    vc.xVal = self.selectedXVal!
                    vc.yVal = self.selectedYVal!
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.presentAuthNavigation()
                }
            }
        }
    }
    
    @objc func startDateButtonTapped() {
        if UserDefaults.standard.isSignIn() {
            alertDatePicker(cond_log_type: CondLogType.startDate)
        } else {
            presentAuthNavigation()
        }
    }
    
    @objc func endDateButtonTapped() {
        if UserDefaults.standard.isSignIn() {
            alertDatePicker(cond_log_type: CondLogType.endDate)
        } else {
            presentAuthNavigation()
        }
    }
    
    @objc func timePickerChanged(_ sender: UIDatePicker){
        let _formatter = DateFormatter()
        _formatter.locale = Locale(identifier: getUserCountryCode())
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
        logTimeLabel.text = "\(hr) \(min)"
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        currPageNum = 1
        minimumCnt = 40
        lastContentOffset = 0.0
        isScrollToLoading = false
        let _text = textField.text!
        if textField.text == "" {
            typedKeyword = nil
            loadCategories()
            return
        } else if textField.text!.first == " " {
            textField.text = nil
            typedKeyword = nil
            return
        } else if textField.text!.count < 2 {
            if _text.range(of: "[a-zA-Z]", options: .regularExpression) != nil {
                typedKeyword = nil
                return
            } else if lang.currentLanguageId == LanguageId.kor {
                for _char in textField.text!.unicodeScalars {
                    if hangulChars.contains(_char) {
                        typedKeyword = nil
                        return
                    }
                }
                typedKeyword = textField.text!
                searchTagsByKeyword()
                return
            }
        }
        for _char in textField.text!.unicodeScalars {
            if hangulChars.contains(_char) {
                typedKeyword = nil
                return
            }
        }
        typedKeyword = textField.text!
        searchTagsByKeyword()
    }
    
    @objc func langPickBtnTapped() {
        loadLangTagsOnPicker()
    }
}

extension CategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagCollection {
            guard let number = subTags?.count else {
                return 0
            }
            return number
        } else if collectionView == stepCollection {
            return stepTags.count
        } else {
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tagCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as? TagCollectionCell else {
                fatalError()
            }
            let tag = subTags[indexPath.row]
            var _text = ""
            switch lang.currentLanguageId {
            case LanguageId.eng: _text = tag.eng_name
            case LanguageId.kor: _text = tag.kor_name!
            default: fatalError()}
            if typedKeyword != nil {
                cell.label.textColor = .black
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: _text)
                attributedString.setColorForText(textForAttribute: typedKeyword!, withColor: .orange)
                cell.label.attributedText = attributedString
            } else {
                cell.label.text = _text
                switch tag.id {
                case TagId.supplements:
                    cell.label.textColor = .webOrange
                default:
                    cell.label.textColor = .black
                }
            }
            cell.imageView.image = UIImage(named: "tag-\(tag.id)")
            return cell
        } else if collectionView == stepCollection {
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
        view.endEditing(true)
        searchTextField.text = nil
        typedKeyword = nil
        currPageNum = 1
        minimumCnt = 40
        lastContentOffset = 0.0
        isScrollToLoading = false
        if collectionView == tagCollection {
            let selected_tag = subTags[indexPath.item]
            stepTags.append(superTag!)
            UIView.transition(with: stepCollection, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.stepCollection.reloadData()
            })
            superTag = selected_tag
            loadCategories()
        } else if collectionView == stepCollection {
            superTag = stepTags[indexPath.item]
            while stepTags.count > indexPath.item {
                stepTags.remove(at: indexPath.item)
            }
            UIView.transition(with: stepCollection, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.stepCollection.reloadData()
            })
            loadCategories()
        } else {
            fatalError()
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tagCollection {
            return CGSize(width: (view.frame.width / 2) - 10.5, height: CGFloat(tagCellHeightInt))
        } else if collectionView == stepCollection {
            let tag = stepTags[indexPath.row]
            var txtCnt = 0
            switch lang.currentLanguageId {
            case LanguageId.eng: txtCnt = tag.eng_name.count
            case LanguageId.kor: txtCnt = tag.kor_name!.count
            case LanguageId.jpn: txtCnt = tag.jpn_name!.count
            default: fatalError()}
            var width = 50
            if txtCnt <= 3 {
                width = 50
            } else if txtCnt <= 5 {
                width = 70
            } else if txtCnt <= 8 {
                width = 90
            } else if txtCnt >= 9 {
                width = 110
            }
            return CGSize(width: width, height: 40)
        } else {
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == tagCollection {
            return 7
        } else if collectionView == stepCollection {
            return 2
        } else {
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == tagCollection {
            return 7
        } else if collectionView == stepCollection {
            return 0
        } else {
            fatalError()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let _subTags = subTags else {
            return
        }
        
        if lastContentOffset > scrollView.contentOffset.y {
            // Case scolled up
            return
        }
        if scrollView.contentSize.height < 0 {
            // Case view did initialized
            return
        } else {
            lastContentOffset = scrollView.contentOffset.y
        }
        
        
        if (scrollView.frame.size.height + scrollView.contentOffset.y) > (scrollView.contentSize.height - 200) {
            if _subTags.count == minimumCnt {
                isScrollToLoading = true
                currPageNum += 1
                minimumCnt += 40
                if typedKeyword != nil {
                    searchTagsByKeyword()
                } else {
                    loadCategories()
                }
            }
        }
    }
}

extension CategoryViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case sizePicker:
            // 0, 1/4, 2/4, 3/4, 1, 1+1/4 ... 99
            return 397
        case langPicker:
            guard let numberOfRows = langTags?.count else {
                return 0
            }
            return numberOfRows
        default:
            fatalError()
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        switch pickerView {
        case sizePicker:
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 58))
            let portion = row / 4
            let remainder = row % 4
            if remainder == 0 {
                let numberLabel = UILabel(frame: CGRect(x: 0, y: 15, width: 33, height: 23))
                let bottomImage = UIImageView(frame: CGRect(x: 0, y: 41, width: 33, height: 18))
                numberLabel.text = "\(portion)"
                numberLabel.font = .systemFont(ofSize: 20, weight: .regular)
                numberLabel.textAlignment = .center
                bottomImage.image = .itemDivBig
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
                bottomImage.image = .itemDivSmall
                containerView.addSubview(midImage)
                containerView.addSubview(bottomImage)
                switch remainder {
                case 1:
                    if row == selectedSizePickerRow {
                        midImage.image = .itemCircleQuarterFilled
                    } else {
                        midImage.image = .itemCircleQuarterEmpty
                    }
                case 2:
                    if row == selectedSizePickerRow {
                        midImage.image = .itemCircleHalfFilled
                    } else {
                        midImage.image = .itemCircleHalfEmpty
                    }
                case 3:
                    if row == selectedSizePickerRow {
                        midImage.image = .itemCircleAlmostFilled
                    } else {
                        midImage.image = .itemCircleAlmostEmpty
                    }
                default:
                    break
                }
            }
            containerView.transform = CGAffineTransform(rotationAngle: (.pi / 2))
            return containerView
        case langPicker:
            let _containerView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
            let _label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
            guard let _tags = langTags else { fatalError() }
            switch lang.currentLanguageId {
            case LanguageId.eng: _label.text = _tags[row].eng_name
            case LanguageId.kor: _label.text = _tags[row].kor_name
            case LanguageId.jpn: _label.text = _tags[row].jpn_name
            default: fatalError()}
            _label.textAlignment = .center
            _containerView.addSubview(_label)
            return _containerView
        default:
            fatalError()
        }
        
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case sizePicker:
            didSelectSizePickerRow(row: row)
            pickerView.reloadAllComponents()
        case langPicker:
            guard let _tags = langTags else { return }
            selectedLangTag = _tags[row]
        default:
            fatalError()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

extension CategoryViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("After keyboard return tapped")
        textField.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("After keyboard end editing")
    }
}

extension CategoryViewController {
    
    // MARK: Private methods
    
    private func setupLayout() {
        // Initialize view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = .whiteSmoke
        
        // Initialize subveiw properties
        detailContainer = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.addShadowView()
            _view.layer.cornerRadius = 10
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        searchTextField = {
            let _textField = UITextField()
            _textField.font = .systemFont(ofSize: 15, weight: .light)
            _textField.textColor = UIColor.dimGray
            _textField.backgroundColor = UIColor.white
            _textField.textAlignment = .center
            _textField.textContentType = .namePrefix
            _textField.autocapitalizationType = .none
            _textField.keyboardType = .default
            _textField.borderStyle = .none
            _textField.layer.cornerRadius = 10.0
            _textField.placeholder = lang.titleSearch
            _textField.addShadowView()
            _textField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
            _textField.isHidden = true
            _textField.translatesAutoresizingMaskIntoConstraints = false
            return _textField
        }()
        langPickButton = {
            let _button = UIButton(type: .system)
            _button.setTitleColor(UIColor.darkGray, for: .normal)
            _button.setTitle(LangHelper.getLanguageName(lang.currentLanguageId), for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 15)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(langPickBtnTapped), for: .touchUpInside)
            _button.backgroundColor = UIColor.white
            _button.layer.cornerRadius = 10.0
            _button.addShadowView()
            _button.isHidden = true
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        sizePickerContainer = {
            let _view = UIView()
            _view.backgroundColor = .mediumSeaGreen
            _view.clipsToBounds = true
            _view.layer.cornerRadius = 10
            _view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        stepCollection = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            _collectionView.backgroundColor = .white
            _collectionView.register(StepCollectionCell.self, forCellWithReuseIdentifier: stepCellId)
            _collectionView.semanticContentAttribute = .forceLeftToRight
            _collectionView.showsHorizontalScrollIndicator = false
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        tagCollection = {
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
            _collectionView.backgroundColor = .clear
            _collectionView.register(TagCollectionCell.self, forCellWithReuseIdentifier: tagCellId)
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        timePicker = {
            let _datePicker = UIDatePicker()
            _datePicker.datePickerMode = .countDownTimer
            _datePicker.minuteInterval = 5
            _datePicker.setValue(UIColor.dodgerBlue, forKeyPath: "textColor")
            _datePicker.setValue(false, forKeyPath: "highlightsToday")
            _datePicker.addTarget(self, action: #selector(timePickerChanged(_:)), for: .valueChanged)
            _datePicker.translatesAutoresizingMaskIntoConstraints = false
            return _datePicker
        }()
        langPicker = {
            let _pickerView = UIPickerView()
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        sizePicker = {
            let _pickerView = UIPickerView()
            _pickerView.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        downArrowImageView = {
            let _imageView = UIImageView()
            _imageView.image = .itemTriangleDown
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
            _label.textColor = .black
            _label.textAlignment = .left
            _label.numberOfLines = 2
            _label.adjustsFontSizeToFitWidth = true
            _label.minimumScaleFactor = 0.5
            _label.allowsDefaultTighteningForTruncation = true
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        bookmarksTotalLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 12, weight: .regular)
            _label.textColor = .lightGray
            _label.textAlignment = .right
            _label.numberOfLines = 1
            _label.text = "0"
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        homeButton = {
            let _button = UIButton(type: .system)
            switch topLeftButtonType {
            case ButtonType.home:
                _button.setImage(UIImage.itemHome.withRenderingMode(.alwaysOriginal), for: .normal)
            case ButtonType.close:
                _button.setImage(UIImage.itemCloseThin.withRenderingMode(.alwaysOriginal), for: .normal)
            default: fatalError()}
            _button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(homeButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        sendOpinionBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemOpinion.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 35, height: 32)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(alertOpinionTextView(_:)), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        starButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemStarEmpty.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.addTarget(self, action:#selector(starButtonTapped), for: .touchUpInside)
            _button.frame = CGRect(x: 0, y: 0, width: 27, height: 25)
            _button.showsTouchWhenHighlighted = true
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        logSizeLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 30, weight: .regular)
            _label.textColor = .black
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        logTimeLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 25, weight: .regular)
            _label.textColor = .black
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        logSizeButton = {
            let _button = UIButton(type: .custom)
            _button.setImage(UIImage.itemBtnPlus.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 54, height: 54)
            _button.showsTouchWhenHighlighted = false
            _button.adjustsImageWhenHighlighted = false
            _button.addShadowView()
            _button.addTarget(self, action: #selector(logButtonTapped(_:)), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        startDateButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemArrowCircle.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 16, height: 17)
            _button.setTitleColor(UIColor.dimGray, for: .normal)
            _button.setTitle(lang.titleStartDate, for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(startDateButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        endDateButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemCheckThin.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 16, height: 17)
            _button.setTitleColor(UIColor.dimGray, for: .normal)
            _button.setTitle(lang.titleEndDate, for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(endDateButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        gradientBackImage = {
            let _imageView = UIImageView()
            _imageView.contentMode = .scaleAspectFill
            _imageView.clipsToBounds = true
            _imageView.image = UIImage(named: "item-gradient-back")
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        
        stepCollection.dataSource = self
        stepCollection.delegate = self
        tagCollection.dataSource = self
        tagCollection.delegate = self
        sizePicker.dataSource = self
        sizePicker.delegate = self
        langPicker.dataSource = self
        langPicker.delegate = self
        searchTextField.delegate = self
        
        // Setup subviews
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendOpinionBtn)
        view.addSubview(stepCollection)
        view.addSubview(searchTextField)
        view.addSubview(langPickButton)
        view.addSubview(detailContainer)
        view.addSubview(tagCollection)
        
        detailContainer.addSubview(titleLabel)
        detailContainer.addSubview(starButton)
        detailContainer.addSubview(bookmarksTotalLabel)
        detailContainer.addSubview(photoImageView)
        detailContainer.addSubview(logSizeLabel)
        detailContainer.addSubview(logSizeButton)
        detailContainer.addSubview(logTimeLabel)
        detailContainer.addSubview(startDateButton)
        detailContainer.addSubview(endDateButton)
        detailContainer.addSubview(sizePickerContainer)
        detailContainer.addSubview(downArrowImageView)
        detailContainer.addSubview(timePicker)
        
        sizePickerContainer.addSubview(gradientBackImage)
        sizePickerContainer.addSubview(sizePicker)
        
        // Setup constraints
        stepCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        stepCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        stepCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        stepCollection.heightAnchor.constraint(equalToConstant: CGFloat(stepBarHeightInt)).isActive = true
        
        searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(stepBarHeightInt + marginInt)).isActive = true
        searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        searchTextField.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) + CGFloat(marginInt)).isActive = true
        searchTextField.heightAnchor.constraint(equalToConstant: CGFloat(searchBarHeightInt)).isActive = true
        
        langPickButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(stepBarHeightInt + marginInt)).isActive = true
        langPickButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: CGFloat(marginInt)).isActive = true
        langPickButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 28).isActive = true
        langPickButton.heightAnchor.constraint(equalTo: searchTextField.heightAnchor, constant: 0).isActive = true
        
        detailContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(stepBarHeightInt + marginInt)).isActive = true
        detailContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        detailContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        detailContainerHeight = detailContainer.heightAnchor.constraint(equalToConstant: CGFloat(detailBoxAHeightInt))
        detailContainerHeight.priority = UILayoutPriority(rawValue: 999)
        detailContainerHeight.isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: detailContainer.topAnchor, constant: 5).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: detailContainer.leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor, constant: -(27 + 7)).isActive = true
        
        starButton.topAnchor.constraint(equalTo: detailContainer.topAnchor, constant: 7).isActive = true
        starButton.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor, constant: -7).isActive = true
        
        bookmarksTotalLabel.topAnchor.constraint(equalTo: detailContainer.topAnchor, constant: 1).isActive = true
        bookmarksTotalLabel.trailingAnchor.constraint(equalTo: starButton.leadingAnchor, constant: -2).isActive = true
        
        photoImageView.topAnchor.constraint(equalTo: detailContainer.topAnchor, constant: 55).isActive = true
        photoImageView.centerXAnchor.constraint(equalTo: detailContainer.centerXAnchor, constant: 0).isActive = true
        
        logSizeLabel.centerXAnchor.constraint(equalTo: detailContainer.centerXAnchor, constant: 0).isActive = true
        logSizeLabel.bottomAnchor.constraint(equalTo: sizePickerContainer.topAnchor, constant: -4).isActive = true
        
        logTimeLabel.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor, constant: -36).isActive = true
        logTimeLabel.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor, constant: -(view.frame.width / 17)).isActive = true
        
        logSizeButton.bottomAnchor.constraint(equalTo: sizePickerContainer.topAnchor, constant: -18).isActive = true
        logSizeButton.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor, constant: -15).isActive = true
        
        startDateButton.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor, constant: -15).isActive = true
        startDateButton.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor, constant: -(view.frame.width / 10)).isActive = true
        
        endDateButton.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor, constant: -15).isActive = true
        endDateButton.leadingAnchor.constraint(equalTo: detailContainer.leadingAnchor, constant: view.frame.width / 10).isActive = true
        
        timePicker.leadingAnchor.constraint(equalTo: detailContainer.leadingAnchor, constant: 7).isActive = true
        timePicker.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor, constant: 0).isActive = true
        timePicker.widthAnchor.constraint(equalToConstant: (view.frame.width / 2)).isActive = true
        timePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        sizePickerContainer.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor, constant: 0).isActive = true
        sizePickerContainer.leadingAnchor.constraint(equalTo: detailContainer.leadingAnchor, constant: 0).isActive = true
        sizePickerContainer.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor, constant: 0).isActive = true
        sizePickerContainer.heightAnchor.constraint(equalToConstant: 58).isActive = true
        
        gradientBackImage.topAnchor.constraint(equalTo: sizePickerContainer.topAnchor, constant: 0).isActive = true
        gradientBackImage.leadingAnchor.constraint(equalTo: sizePickerContainer.leadingAnchor, constant: 0).isActive = true
        gradientBackImage.trailingAnchor.constraint(equalTo: sizePickerContainer.trailingAnchor, constant: 0).isActive = true
        gradientBackImage.bottomAnchor.constraint(equalTo: sizePickerContainer.bottomAnchor, constant: 0).isActive = true
        
        sizePicker.centerXAnchor.constraint(equalTo: sizePickerContainer.centerXAnchor, constant: 0).isActive = true
        sizePicker.centerYAnchor.constraint(equalTo: sizePickerContainer.centerYAnchor, constant: 0).isActive = true
        sizePicker.widthAnchor.constraint(equalToConstant: 58).isActive = true
        sizePicker.heightAnchor.constraint(equalToConstant: view.frame.width + 200).isActive = true
        
        downArrowImageView.centerXAnchor.constraint(equalTo: detailContainer.centerXAnchor, constant: 0).isActive = true
        downArrowImageView.topAnchor.constraint(equalTo: sizePickerContainer.topAnchor, constant: -1).isActive = true
        
        tagCollectionTop = tagCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(stepBarHeightInt + marginInt))
        tagCollectionTop.priority = UILayoutPriority(rawValue: 999)
        tagCollectionTop.isActive = true
        tagCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        tagCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        tagCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    private func didSelectSizePickerRow(row: Int) {
        let portion = row / 4
        let remainder = row % 4
        selectedSizePickerRow = row
        if portion <= 0 {
            switch remainder {
            case 0:
                // Case select nothing
                // "0 + 1/4"
                sizePicker.selectRow(1, inComponent: 0, animated: true)
                logSizeLabel.text = "¼"
                selectedXVal = 0
                selectedYVal = 1
                selectedSizePickerRow = 1
            case 1:
                // "0 + 1/4"
                logSizeLabel.text = "¼"
                selectedXVal = 0
                selectedYVal = 1
            case 2:
                // "0 + 1/2"
                logSizeLabel.text = "½"
                selectedXVal = 0
                selectedYVal = 2
            case 3:
                // "0 + 3/4"
                logSizeLabel.text = "¾"
                selectedXVal = 0
                selectedYVal = 3
            default:
                return
            }
        } else {
            switch remainder {
            case 0:
                // "n + 0"
                logSizeLabel.text = "\(portion)"
                selectedXVal = portion
                selectedYVal = 0
            case 1:
                // "n + 1/4"
                logSizeLabel.text = "\(portion)¼"
                selectedXVal = portion
                selectedYVal = 1
            case 2:
                // "n + 1/2"
                logSizeLabel.text = "\(portion)½"
                selectedXVal = portion
                selectedYVal = 2
            case 3:
                // "n + 3/4"
                logSizeLabel.text = "\(portion)¾"
                selectedXVal = portion
                selectedYVal = 3
            default:
                return
            }
        }
    }
    
    private func setDetailPhotoImage(tag: BaseModel.Tag) {
        if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-\(tag.division2!)-\(tag.division3!)-\(tag.division4!)-\(tag.division5!)") {
            self.photoImageView.image = image
        } else {
            if tag.division2 == 0 {
                self.photoImageView.image = UIImage(named: "photo-\(tag.class1!)-0-0-0-0-0")
            } else if tag.division3 == 0 {
                if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-\(tag.division2!)-0-0-0") {
                    self.photoImageView.image = image
                } else {
                    if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-0-0-0-0") {
                        self.photoImageView.image = image
                    } else {
                        self.photoImageView.image = UIImage(named: "photo-\(tag.class1!)-0-0-0-0-0")
                    }
                }
            } else if tag.division4 == 0 {
                if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-\(tag.division2!)-\(tag.division3!)-0-0") {
                    self.photoImageView.image = image
                } else {
                    if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-\(tag.division2!)-0-0-0") {
                        self.photoImageView.image = image
                    } else {
                        if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-0-0-0-0") {
                            self.photoImageView.image = image
                        } else {
                            self.photoImageView.image = UIImage(named: "photo-\(tag.class1!)-0-0-0-0-0")
                        }
                    }
                }
            } else if tag.division5 == 0 {
                if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-\(tag.division2!)-\(tag.division3!)-\(tag.division4!)-0") {
                    self.photoImageView.image = image
                } else {
                    if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-\(tag.division2!)-\(tag.division3!)-0-0") {
                        self.photoImageView.image = image
                    } else {
                        if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-\(tag.division2!)-0-0-0") {
                            self.photoImageView.image = image
                        } else {
                            if let image = UIImage(named: "photo-\(tag.class1!)-\(tag.division1!)-0-0-0-0") {
                                self.photoImageView.image = image
                            } else {
                                self.photoImageView.image = UIImage(named: "photo-\(tag.class1!)-0-0-0-0-0")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func afterFetchCategoriesTransition(_ _superTag: BaseModel.Tag, _ _subTags: [BaseModel.Tag]) {
        self.superTag = _superTag
        if isScrollToLoading {
            isScrollToLoading = false
            if _subTags.count > 0 {
                self.subTags.append(contentsOf: _subTags)
                self.tagCollection.reloadData()
            }
            return
        }
        
        if _superTag.tag_type == TagType.category || _superTag.tag_type == TagType.bookmark || _superTag.tag_type == TagType.history {
            // Execute category tag_type exclusive
            switch lang.currentLanguageId {
            case LanguageId.eng: navigationItem.title = _superTag.eng_name
            case LanguageId.kor: navigationItem.title = _superTag.kor_name
            case LanguageId.jpn: navigationItem.title = _superTag.jpn_name
            default: fatalError()}
            UIView.animate(withDuration: 0.5) {
                self.detailContainer.isHidden = true
                if _superTag.id == TagId.bookmarks {
                    self.searchTextField.isHidden = true
                    self.langPickButton.isHidden = true
                    self.tagCollectionTop.constant = CGFloat(stepBarHeightInt + marginInt)
                } else {
                    self.searchTextField.isHidden = false
                    self.langPickButton.isHidden = false
                    self.tagCollectionTop.constant = CGFloat(stepBarHeightInt + marginInt + searchBarHeightInt + marginInt)
                }
            }
        } else {
            // Case all non-cateogry tag_types
            switch lang.currentLanguageId {
            case LanguageId.eng: titleLabel.text = _superTag.eng_name
            case LanguageId.kor: titleLabel.text = _superTag.kor_name
            case LanguageId.jpn: titleLabel.text = _superTag.jpn_name
            default: fatalError()}
        }
        if _superTag.tag_type == TagType.bookmark || _superTag.tag_type == TagType.history {
            UIView.animate(withDuration: 0.5) {
                self.searchTextField.isHidden = true
                self.langPickButton.isHidden = true
                self.tagCollectionTop.constant = CGFloat(stepBarHeightInt + marginInt)
            }
        } else if _superTag.tag_type == TagType.food || _superTag.tag_type == TagType.drug {
            // Execute food and drug tag_types exclusive
            sizePicker.selectRow(4, inComponent: 0, animated: true)
            didSelectSizePickerRow(row: 4)
            UIView.animate(withDuration: 0.5) {
                self.detailContainer.isHidden = false
                self.searchTextField.isHidden = true
                self.langPickButton.isHidden = true
                self.detailContainerHeight.constant = CGFloat(detailBoxAHeightInt)
                self.tagCollectionTop.constant = CGFloat(stepBarHeightInt + marginInt + detailBoxAHeightInt + marginInt)
                
                self.downArrowImageView.isHidden = false
                self.logSizeButton.isHidden = false
                self.logSizeLabel.isHidden = false
                self.sizePickerContainer.isHidden = false
                self.logTimeLabel.isHidden = true
                self.timePicker.isHidden = true
                self.startDateButton.isHidden = true
                self.endDateButton.isHidden = true
                if _superTag.class1 != nil {
                    self.setDetailPhotoImage(tag: _superTag)
                }
            }
        } else if _superTag.tag_type == TagType.activity {
            // Execute activity tag_type exclusive
            selectedXVal = 0
            selectedYVal = 5
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = 0
            components.minute = 5
            self.timePicker.setDate(calendar.date(from: components)!, animated: true)
            logTimeLabel.text = "5min"
            UIView.animate(withDuration: 0.5) {
                self.detailContainer.isHidden = false
                self.searchTextField.isHidden = true
                self.langPickButton.isHidden = true
                self.detailContainerHeight.constant = CGFloat(detailBoxBHeightInt)
                self.tagCollectionTop.constant = CGFloat(stepBarHeightInt + marginInt + detailBoxBHeightInt + marginInt)
                
                self.downArrowImageView.isHidden = true
                self.logSizeButton.isHidden = false
                self.logSizeLabel.isHidden = true
                self.sizePickerContainer.isHidden = true
                self.logTimeLabel.isHidden = false
                self.timePicker.isHidden = false
                self.startDateButton.isHidden = true
                self.endDateButton.isHidden = true
                
                if _superTag.class1 != nil {
                    self.setDetailPhotoImage(tag: _superTag)
                }
            }
        } else if _superTag.tag_type == TagType.disease {
            // Execute condition tag_type exclusive
            UIView.animate(withDuration: 0.5) {
                self.detailContainer.isHidden = false
                self.searchTextField.isHidden = true
                self.langPickButton.isHidden = true
                self.detailContainerHeight.constant = CGFloat(detailBoxCHeightInt)
                self.tagCollectionTop.constant = CGFloat(stepBarHeightInt + marginInt + detailBoxCHeightInt + marginInt)
                
                self.downArrowImageView.isHidden = true
                self.logSizeButton.isHidden = true
                self.logSizeLabel.isHidden = true
                self.sizePickerContainer.isHidden = true
                self.logTimeLabel.isHidden = true
                self.timePicker.isHidden = true
                self.startDateButton.isHidden = false
                self.endDateButton.isHidden = false
                
                if _superTag.class1 != nil {
                    self.setDetailPhotoImage(tag: _superTag)
                }
            }
        }
        
        // For all tag_types
        subTags = _subTags
        tagCollection.reloadData()
        UIView.transition(with: tagCollection, duration: 0.5, options: .transitionCrossDissolve, animations: {
            if _superTag.id == TagId.bookmarks {
                self.tagCollectionTop.constant = CGFloat(stepBarHeightInt + marginInt)
            } else if _superTag.tag_type == TagType.category {
                self.tagCollectionTop.constant = CGFloat(stepBarHeightInt + marginInt + searchBarHeightInt + marginInt)
            }
            self.tagCollection.isHidden = false
            self.view.hideSpinner()
            
        }, completion: { (_) in
            if self.subTags.count > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                self.tagCollection.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        })
    }
    
    private func loadCategories() {
        if !isScrollToLoading {
            self.view.showSpinner()
            UIView.transition(with: detailContainer, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.detailContainer.isHidden = true
                self.tagCollection.isHidden = true
                self.searchTextField.isHidden = true
                self.langPickButton.isHidden = true
            })
        }
        if superTag != nil {
            superTagId = superTag!.id
        }
        let service = Service(lang: lang)
        service.getTagSetList(tagId: superTagId!, sortType: SortType.priority, pageNum: currPageNum, langId: lang.currentLanguageId,popoverAlert: { (message) in
            self.retryFunction = self.loadCategories
            self.alertError(message)
        }) { (tagSet) in
            if tagSet.bookmark_id != nil {
                self.bookmark_id = tagSet.bookmark_id
                self.starButton.setImage(UIImage.itemStarFilled.withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                self.bookmark_id = nil
                self.starButton.setImage(UIImage.itemStarEmpty.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            self.bookmarksTotalLabel.text = "\(tagSet.bookmarks_total ?? 0)"
            self.afterFetchCategoriesTransition(tagSet.tag, tagSet.sub_tags)
        }
    }
    
    private func searchTagsByKeyword() {
        let service = Service(lang: lang)
        service.searchTags(tagId: superTag!.id, keyWord: typedKeyword!, page: currPageNum, popoverAlert: { (message) in
            self.retryFunction = self.searchTagsByKeyword
            self.alertError(message)
        }) { (tagSet) in
            self.afterFetchCategoriesTransition(tagSet.tag, tagSet.sub_tags)
        }
    }
    
    private func createAConditionLog() {
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
        service.postAvatarCond(params: params, popoverAlert: { (message) in
            self.retryFunction = self.createAConditionLog
            self.detailContainer.isHidden = true
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.createAConditionLog()
        }) {
            UIView.transition(with: self.detailContainer, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.detailContainer.isHidden = false
            }, completion: { (_) in
                switch self.lang.currentLanguageId {
                case LanguageId.eng: self.alertCompl(self.superTag!.eng_name, self.lang.msgLogComplete)
                case LanguageId.kor: self.alertCompl(self.superTag!.kor_name!, self.lang.msgLogComplete)
                case LanguageId.jpn: self.alertCompl(self.superTag!.jpn_name!, self.lang.msgLogComplete)
                default: fatalError()}
            })
        }
    }
    
    private func createBookmark() {
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let params: Parameters = [
            "avatar_id": avatarId,
            "tag_id": superTag!.id,
            "tag_type": superTag!.tag_type!
        ]
        let service = Service(lang: lang)
        service.postABookmark(params: params, popoverAlert: { (message) in
            self.retryFunction = self.createBookmark
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.createBookmark()
        }) { (postBookmark) in
            self.bookmark_id = postBookmark.bookmark_id
            UIView.animate(withDuration: 0.5, animations: {
                self.starButton.setImage(UIImage.itemStarFilled.withRenderingMode(.alwaysOriginal), for: .normal)
                self.bookmarksTotalLabel.text = "\(postBookmark.bookmarks_total)"
            })
        }
    }
    
    private func removeBookmark() {
        let service = Service(lang: lang)
        service.putABookmark(bookmark_id: self.bookmark_id!, popoverAlert: { (message) in
            self.retryFunction = self.removeBookmark
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.removeBookmark()
        }) { (bookmakrsTotal) in
            self.bookmark_id = nil
            UIView.animate(withDuration: 0.5, animations: {
                self.starButton.setImage(UIImage.itemStarEmpty.withRenderingMode(.alwaysOriginal), for: .normal)
                self.bookmarksTotalLabel.text = "\(bookmakrsTotal)"
            })
        }
    }
    
    private func loadLangTagsOnPicker() {
        let service = Service(lang: lang)
        service.getProfileTagSets(tagId: TagId.language, isSelected: false, popoverAlert: { (message) in
            self.retryFunction = self.loadLangTagsOnPicker
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadLangTagsOnPicker()
        }) { (profileTagSet) in
            self.langTags = profileTagSet.sub_tags
            self.langPicker.reloadAllComponents()
            
            switch self.lang.currentLanguageId {
            case LanguageId.eng:
                self.langPicker.selectRow(0, inComponent: 0, animated: true)
            case LanguageId.kor:
                self.langPicker.selectRow(1, inComponent: 0, animated: true)
            default: fatalError()}
            
            self.alertLangPicker()
        }
    }
    
    private func submitOpinion() {
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let params: Parameters = [
            "avatar_id": avatarId,
            "tag_id": superTag!.id,
            "opinion": opinion!
        ]
        let service = Service(lang: lang)
        service.sendUserOpinionMail(params: params, popoverAlert: { (message) in
            self.retryFunction = self.submitOpinion
            self.alertError(message)
        }) {
            self.alertCompl("Complete!", "Thank you for your precious opinion.")
        }
    }
}
