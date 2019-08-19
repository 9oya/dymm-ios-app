//
//  ProfileController.swift
//  Flava
//
//  Created by eunsang lee on 24/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

private let tagCellId = "TagCell"

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    var loadingImageView: UIImageView!
    var additionalTopBarView: UIView!
    var scrollView: UIScrollView!
    var signOutButton: UIButton!
    var closeButton: UIButton!
    let pickerCancelButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setTitleColor(UIColor.clear, for: .normal)
        _button.titleLabel?.font = .systemFont(ofSize: 16)
        _button.showsTouchWhenHighlighted = true
        _button.isEnabled = false
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    let pickerDoneButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setTitleColor(UIColor.clear, for: .normal)
        _button.titleLabel?.font = .systemFont(ofSize: 16)
        _button.showsTouchWhenHighlighted = true
        _button.isEnabled = false
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    let mailConfContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        _view.addShadowView()
        _view.isHidden = true
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let mailConfMsgLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 15, weight: .regular)
        _label.textColor = UIColor(hex: "LightSteelBlue")
        _label.textAlignment = .center
        _label.numberOfLines = 2
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    var mailConfAddressButton: UIButton!
    var sendAgainButton: UIButton!
    let pencilImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.image = UIImage(named: "button-pencil")
        _imageView.contentMode = .scaleAspectFit
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    let infoContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        _view.layer.cornerRadius = 10
        _view.addShadowView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let tagCollectionView: UICollectionView = {
        let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        _collectionView.backgroundColor = UIColor.clear
        _collectionView.register(TagCollectionCell.self, forCellWithReuseIdentifier: tagCellId)
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        return _collectionView
    }()
    var tagCollectionHeight: NSLayoutConstraint!
    let pickerContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        _view.layer.cornerRadius = 10
        _view.isHidden = true
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let pickerView: UIPickerView = {
        let _pickerView = UIPickerView()
        _pickerView.translatesAutoresizingMaskIntoConstraints = false
        return _pickerView
    }()
    let infoImageContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    let infoImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.layer.cornerRadius = 70 / 2
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }()
    let infoImageLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 35, weight: .medium)
        _label.textColor = UIColor.white
        _label.textAlignment = .center
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    var firstNameContainerView: UIView!
    var lastNameContainerView: UIView!
    var emailContainerView: UIView!
    var phNumberContainerView: UIView!
    var introContainerView: UIView!
    let introTextView: UITextView = {
        let _textView = UITextView()
        _textView.backgroundColor = UIColor.white
        _textView.font = .systemFont(ofSize: 14, weight: .regular)
        _textView.translatesAutoresizingMaskIntoConstraints = false
        return _textView
    }()
    
    var firstNameGuideLabel: UILabel!
    var firstNameLabel: UILabel!
    var lastNameGuideLabel: UILabel!
    var lastNameLabel: UILabel!
    var emailGuideLabel: UILabel!
    var emailLabel: UILabel!
    var phNumberGuideLabel: UILabel!
    var phNumberLabel: UILabel!
    var phNumberPlaceHolderLabel: UILabel!
    var introGuideLabel: UILabel!
    let introLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 15, weight: .regular)
        _label.textColor = UIColor.black
        _label.textAlignment = .left
        _label.numberOfLines = 4
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    var introPlaceHolderLabel: UILabel!
    
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    
    var mailMessage: String?
    var newMailAddress: String?
    
    var profile: CustomModel.Profile?
    var selectedCollectionItem: Int?
    var tags: [BaseModel.Tag]?
    var profileTags: [BaseModel.ProfileTag]?
    var pickedTag: BaseModel.Tag?
    var newInfoStr: String?
    var updateTarget: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutStyles()
        setupLayoutSubviews()
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        pickerView.delegate = self
        setupLayoutConstraints()
        setupProperties()
    }
    
    // MARK: - Actions
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func signOutButtonTapped() {
        UserDefaults.standard.setIsSignIn(value: false)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func pickerCancelButtonTapped() {
        UIView.transition(with: pickerContainerView, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.pickerCancelButton.setTitleColor(UIColor.clear, for: .normal)
            self.pickerCancelButton.isEnabled = false
            self.pickerDoneButton.setTitleColor(UIColor.clear, for: .normal)
            self.pickerDoneButton.isEnabled = false
            self.pickerContainerView.isHidden = true
        })
    }
    
    @objc func pickerDoneButtonTapped() {
        UIView.transition(with: pickerContainerView, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.pickerCancelButton.setTitleColor(UIColor.clear, for: .normal)
            self.pickerCancelButton.isEnabled = false
            self.pickerDoneButton.setTitleColor(UIColor.clear, for: .normal)
            self.pickerDoneButton.isEnabled = false
            self.pickerContainerView.isHidden = true
        })
        updateProfileTag()
    }
    
    @objc func firstNameContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alertController = UIAlertController(title: lang.alertEditFirstNameTitle, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnDone, style: .default) { _ in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                self.newInfoStr = text
                self.updateTarget = AvatarInfoTarget.firstName
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.btnCancel, style: .cancel) { _ in }
        alertController.addTextField { textField in
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = self.lang.alertEditFirstNamePlaceholder
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func lastNameContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alertController = UIAlertController(title: lang.alertEditLastNameTitle, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnDone, style: .default) { _ in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                self.newInfoStr = text
                self.updateTarget = AvatarInfoTarget.lastName
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.btnCancel, style: .cancel) { _ in }
        alertController.addTextField { textField in
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = self.lang.alertEditLastNamePlaceholder
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func emailContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alertController = UIAlertController(title: lang.alertEditEmailTitle, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnDone, style: .default) { _ in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                self.newInfoStr = text
                self.updateTarget = AvatarInfoTarget.email
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.btnCancel, style: .cancel) { _ in }
        alertController.addTextField { textField in
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = self.lang.alertEditEmailPlaceholder
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func phNumContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alertController = UIAlertController(title: lang.alertEditPhNumTitle, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnDone, style: .default) { _ in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                self.newInfoStr = text
                self.updateTarget = AvatarInfoTarget.phNumber
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.btnCancel, style: .cancel) { _ in }
        alertController.addTextField { textField in
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = self.lang.alertEditPhNumPlaceholder
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func introContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alertController = UIAlertController(title: lang.alertEditIntroTitle, message: nil, preferredStyle: .alert)
        introTextView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let controller = UIViewController()
        introTextView.frame = controller.view.frame
        if let originTxt = introLabel.text {
            introTextView.text = originTxt
        }
        controller.view.addSubview(introTextView)
        alertController.setValue(controller, forKey: "contentViewController")
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.frame.height * 0.3)
        alertController.view.addConstraint(height)
        let confirmAction = UIAlertAction(title: lang.btnDone, style: .default) { _ in
            if let text = self.introTextView.text {
                self.newInfoStr = text
                self.updateTarget = AvatarInfoTarget.intro
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.btnCancel, style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let number = profile?.profile_tags.count else {
            return 0
        }
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as? TagCollectionCell else {
            fatalError()
        }
        let avatar_fact: BaseModel.ProfileTag = profile!.profile_tags[indexPath.row]
        switch lang.currentLanguageId {
        case LanguageId.eng: cell.label.text = avatar_fact.eng_name
        case LanguageId.kor: cell.label.text = avatar_fact.kor_name
        case LanguageId.jpn: cell.label.text = avatar_fact.jpn_name
        default: cell.label.text = avatar_fact.eng_name}
        if avatar_fact.is_selected == false {
            cell.label.textColor = UIColor.darkGray
            return cell
        }
        cell.label.textColor = UIColor.black
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCollectionItem = indexPath.row
        loadProfileTags()
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

extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let rows = tags?.count else {
            return 0
        }
        return rows
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let _containerView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
        let _label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
        _label.textAlignment = .center
        switch lang.currentLanguageId {
        case LanguageId.eng: _label.text = tags![row].eng_name
        case LanguageId.kor: _label.text = tags![row].kor_name
        case LanguageId.jpn: _label.text = tags![row].jpn_name
        default: _label.text = tags![row].eng_name}
        _containerView.addSubview(_label)
        return _containerView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedTag = tags![row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}

extension ProfileViewController {
    
    // MARK: Private methods
    
    private func setupLayoutStyles() {
        view.backgroundColor = UIColor(hex: "WhiteSmoke")
    }
    
    private func getProfileLabelContainerView() -> UIView {
        let _view = UIView()
        _view.backgroundColor = UIColor(hex: "WhiteSmoke")
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }
    
    private func getProfileGuideLabel() -> UILabel {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 10, weight: .regular)
        _label.textColor = UIColor(hex: "Silver")
        _label.textAlignment = .left
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }
    
    private func getProfileLabel() -> UILabel {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 15, weight: .regular)
        _label.textColor = UIColor.black
        _label.textAlignment = .left
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }
    
    private func getProfilePlaceHolderLabel() -> UILabel {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 15, weight: .regular)
        _label.textColor = UIColor(hex: "Silver")
        _label.textAlignment = .center
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }
    
    private func setupLayoutSubviews() {
        loadingImageView = getLoadingImageView(isHidden: true)
        
        additionalTopBarView = getAddtionalTopBarView()
        signOutButton = getBasicTextButton()
        closeButton = getCloseButton()
        mailConfAddressButton = getBasicTextButton()
        sendAgainButton = getBasicTextButton()
        scrollView = getScrollView(isHidden: true)
        firstNameContainerView = getProfileLabelContainerView()
        lastNameContainerView = getProfileLabelContainerView()
        emailContainerView = getProfileLabelContainerView()
        phNumberContainerView = getProfileLabelContainerView()
        introContainerView = getProfileLabelContainerView()
        firstNameGuideLabel = getProfileGuideLabel()
        lastNameGuideLabel = getProfileGuideLabel()
        emailGuideLabel = getProfileGuideLabel()
        phNumberGuideLabel = getProfileGuideLabel()
        introGuideLabel = getProfileGuideLabel()
        firstNameLabel = getProfileLabel()
        lastNameLabel = getProfileLabel()
        emailLabel = getProfileLabel()
        phNumberLabel = getProfileLabel()
        phNumberPlaceHolderLabel = getProfilePlaceHolderLabel()
        introPlaceHolderLabel = getProfilePlaceHolderLabel()
        
        view.addSubview(scrollView)
        view.addSubview(loadingImageView)
        view.addSubview(additionalTopBarView)
        view.addSubview(pickerContainerView)
        view.addSubview(pickerCancelButton)
        view.addSubview(pickerDoneButton)
        view.addSubview(mailConfContainerView)
        
        additionalTopBarView.addSubview(signOutButton)
        scrollView.addSubview(infoContainerView)
        scrollView.addSubview(tagCollectionView)
        pickerContainerView.addSubview(pickerView)
        mailConfContainerView.addSubview(mailConfMsgLabel)
        mailConfContainerView.addSubview(mailConfAddressButton)
        mailConfContainerView.addSubview(pencilImageView)
        mailConfContainerView.addSubview(sendAgainButton)
        
        infoContainerView.addSubview(infoImageContainerView)
        infoContainerView.addSubview(firstNameContainerView)
        infoContainerView.addSubview(lastNameContainerView)
        infoContainerView.addSubview(emailContainerView)
        infoContainerView.addSubview(phNumberContainerView)
        infoContainerView.addSubview(introContainerView)
        
        infoImageContainerView.addSubview(infoImageView)
        infoImageContainerView.addSubview(infoImageLabel)
        firstNameContainerView.addSubview(firstNameGuideLabel)
        firstNameContainerView.addSubview(firstNameLabel)
        lastNameContainerView.addSubview(lastNameGuideLabel)
        lastNameContainerView.addSubview(lastNameLabel)
        emailContainerView.addSubview(emailGuideLabel)
        emailContainerView.addSubview(emailLabel)
        phNumberContainerView.addSubview(phNumberGuideLabel)
        phNumberContainerView.addSubview(phNumberLabel)
        phNumberContainerView.addSubview(phNumberPlaceHolderLabel)
        introContainerView.addSubview(introGuideLabel)
        introContainerView.addSubview(introLabel)
        introContainerView.addSubview(introPlaceHolderLabel)
    }
    
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
        
        signOutButton.topAnchor.constraint(equalTo: additionalTopBarView.topAnchor, constant: 0).isActive = true
        signOutButton.trailingAnchor.constraint(equalTo: additionalTopBarView.trailingAnchor, constant: -20).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: additionalTopBarView.bottomAnchor, constant: 0).isActive = true
        
        // mailConfContainerView
        mailConfContainerView.topAnchor.constraint(equalTo: additionalTopBarView.bottomAnchor, constant: 7).isActive = true
        mailConfContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        mailConfContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        mailConfContainerView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        mailConfMsgLabel.leadingAnchor.constraint(equalTo: mailConfContainerView.leadingAnchor, constant: 20).isActive = true
        mailConfMsgLabel.trailingAnchor.constraint(equalTo: mailConfContainerView.trailingAnchor, constant: -20).isActive = true
        mailConfMsgLabel.centerYAnchor.constraint(equalTo: mailConfContainerView.centerYAnchor, constant: -40).isActive = true
        
        sendAgainButton.bottomAnchor.constraint(equalTo: mailConfContainerView.bottomAnchor, constant: -25).isActive = true
        sendAgainButton.centerXAnchor.constraint(equalTo: mailConfContainerView.centerXAnchor, constant: 0).isActive = true
        
        mailConfAddressButton.bottomAnchor.constraint(equalTo: sendAgainButton.topAnchor, constant: -15).isActive = true
        mailConfAddressButton.centerXAnchor.constraint(equalTo: mailConfContainerView.centerXAnchor, constant: 0).isActive = true
        
        pencilImageView.bottomAnchor.constraint(equalTo: sendAgainButton.topAnchor, constant: -24).isActive = true
        pencilImageView.leadingAnchor.constraint(equalTo: mailConfAddressButton.trailingAnchor, constant: 5).isActive = true
        pencilImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        pencilImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // scrollView
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        // profileContainerView
        infoContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 35 + 7).isActive = true
        infoContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 7).isActive = true
        infoContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 7).isActive = true
        infoContainerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0).isActive = true
        infoContainerView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        
        infoImageContainerView.topAnchor.constraint(equalTo: infoContainerView.topAnchor, constant: 20).isActive = true
        infoImageContainerView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20).isActive = true
        infoImageContainerView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        infoImageContainerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        infoImageView.topAnchor.constraint(equalTo: infoImageContainerView.topAnchor, constant: 0).isActive = true
        infoImageView.leadingAnchor.constraint(equalTo: infoImageContainerView.leadingAnchor, constant: 0).isActive = true
        infoImageView.trailingAnchor.constraint(equalTo: infoImageContainerView.trailingAnchor, constant: 0).isActive = true
        infoImageView.bottomAnchor.constraint(equalTo: infoImageContainerView.bottomAnchor, constant: 0).isActive = true
        
        infoImageLabel.centerXAnchor.constraint(equalTo: infoImageContainerView.centerXAnchor, constant: 0).isActive = true
        infoImageLabel.centerYAnchor.constraint(equalTo: infoImageContainerView.centerYAnchor, constant: 0).isActive = true
        
        firstNameContainerView.topAnchor.constraint(equalTo: infoContainerView.topAnchor, constant: 15).isActive = true
        firstNameContainerView.leadingAnchor.constraint(equalTo: infoImageContainerView.trailingAnchor, constant: 20).isActive = true
        firstNameContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -7).isActive = true
        firstNameContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        firstNameGuideLabel.topAnchor.constraint(equalTo: firstNameContainerView.topAnchor, constant: 2).isActive = true
        firstNameGuideLabel.leadingAnchor.constraint(equalTo: firstNameContainerView.leadingAnchor, constant: 6).isActive = true
        firstNameGuideLabel.trailingAnchor.constraint(equalTo: firstNameContainerView.trailingAnchor, constant: 0).isActive = true
        
        firstNameLabel.topAnchor.constraint(equalTo: firstNameGuideLabel.bottomAnchor, constant: 2).isActive = true
        firstNameLabel.leadingAnchor.constraint(equalTo: firstNameContainerView.leadingAnchor, constant: 6).isActive = true
        firstNameLabel.trailingAnchor.constraint(equalTo: firstNameContainerView.trailingAnchor, constant: 0).isActive = true
        
        lastNameContainerView.topAnchor.constraint(equalTo: firstNameContainerView.bottomAnchor, constant: 3).isActive = true
        lastNameContainerView.leadingAnchor.constraint(equalTo: infoImageContainerView.trailingAnchor, constant: 20).isActive = true
        lastNameContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -7).isActive = true
        lastNameContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        lastNameGuideLabel.topAnchor.constraint(equalTo: lastNameContainerView.topAnchor, constant: 2).isActive = true
        lastNameGuideLabel.leadingAnchor.constraint(equalTo: lastNameContainerView.leadingAnchor, constant: 6).isActive = true
        lastNameGuideLabel.trailingAnchor.constraint(equalTo: lastNameContainerView.trailingAnchor, constant: 0).isActive = true
        
        lastNameLabel.topAnchor.constraint(equalTo: lastNameGuideLabel.bottomAnchor, constant: 2).isActive = true
        lastNameLabel.leadingAnchor.constraint(equalTo: lastNameContainerView.leadingAnchor, constant: 6).isActive = true
        lastNameLabel.trailingAnchor.constraint(equalTo: lastNameContainerView.trailingAnchor, constant: 0).isActive = true
        
        emailContainerView.topAnchor.constraint(equalTo: lastNameContainerView.bottomAnchor, constant: 3).isActive = true
        emailContainerView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20).isActive = true
        emailContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -7).isActive = true
        emailContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        emailGuideLabel.topAnchor.constraint(equalTo: emailContainerView.topAnchor, constant: 2).isActive = true
        emailGuideLabel.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 6).isActive = true
        emailGuideLabel.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: 0).isActive = true
        
        emailLabel.topAnchor.constraint(equalTo: emailGuideLabel.bottomAnchor, constant: 2).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 6).isActive = true
        emailLabel.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: 0).isActive = true
        
        phNumberContainerView.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 3).isActive = true
        phNumberContainerView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20).isActive = true
        phNumberContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -7).isActive = true
        phNumberContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        phNumberGuideLabel.topAnchor.constraint(equalTo: phNumberContainerView.topAnchor, constant: 2).isActive = true
        phNumberGuideLabel.leadingAnchor.constraint(equalTo: phNumberContainerView.leadingAnchor, constant: 6).isActive = true
        phNumberGuideLabel.trailingAnchor.constraint(equalTo: phNumberContainerView.trailingAnchor, constant: 0).isActive = true
        
        phNumberLabel.topAnchor.constraint(equalTo: phNumberGuideLabel.bottomAnchor, constant: 2).isActive = true
        phNumberLabel.leadingAnchor.constraint(equalTo: phNumberContainerView.leadingAnchor, constant: 6).isActive = true
        phNumberLabel.trailingAnchor.constraint(equalTo: phNumberContainerView.trailingAnchor, constant: 0).isActive = true
        
        phNumberPlaceHolderLabel.leadingAnchor.constraint(equalTo: phNumberContainerView.leadingAnchor, constant: 0).isActive = true
        phNumberPlaceHolderLabel.trailingAnchor.constraint(equalTo: phNumberContainerView.trailingAnchor, constant: 0).isActive = true
        phNumberPlaceHolderLabel.centerYAnchor.constraint(equalTo: phNumberContainerView.centerYAnchor, constant: 0).isActive = true
        
        introContainerView.topAnchor.constraint(equalTo: phNumberContainerView.bottomAnchor, constant: 3).isActive = true
        introContainerView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20).isActive = true
        introContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -7).isActive = true
        introContainerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        introGuideLabel.topAnchor.constraint(equalTo: introContainerView.topAnchor, constant: 2).isActive = true
        introGuideLabel.leadingAnchor.constraint(equalTo: introContainerView.leadingAnchor, constant: 6).isActive = true
        introGuideLabel.trailingAnchor.constraint(equalTo: introContainerView.trailingAnchor, constant: 0).isActive = true
        
        introLabel.topAnchor.constraint(equalTo: introGuideLabel.bottomAnchor, constant: 2).isActive = true
        introLabel.leadingAnchor.constraint(equalTo: introContainerView.leadingAnchor, constant: 6).isActive = true
        introLabel.trailingAnchor.constraint(equalTo: introContainerView.trailingAnchor, constant: 0).isActive = true
        
        introPlaceHolderLabel.leadingAnchor.constraint(equalTo: introContainerView.leadingAnchor, constant: 0).isActive = true
        introPlaceHolderLabel.trailingAnchor.constraint(equalTo: introContainerView.trailingAnchor, constant: 0).isActive = true
        introPlaceHolderLabel.centerYAnchor.constraint(equalTo: introContainerView.centerYAnchor, constant: 0).isActive = true
        
        // profileCollectionView
        tagCollectionView.topAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: 7).isActive = true
        tagCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 7).isActive = true
        tagCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 7).isActive = true
        tagCollectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        tagCollectionHeight = tagCollectionView.heightAnchor.constraint(equalToConstant: 35 + 7)
        tagCollectionHeight.priority = UILayoutPriority(rawValue: 999)
        tagCollectionHeight.isActive = true
        
        // pickerContainerView
        pickerContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        pickerContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        pickerContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        pickerContainerView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        
        pickerView.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 20).isActive = true
        pickerView.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 12).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: -12).isActive = true
        pickerView.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: 0).isActive = true
        
        // TODO
        pickerCancelButton.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 25).isActive = true
        pickerCancelButton.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 10).isActive = true
        
        pickerDoneButton.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: -25).isActive = true
        pickerDoneButton.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 10).isActive = true
    }
    
    private func setupProperties() {
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.title = lang.titleProfile
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        pickerCancelButton.addTarget(self, action: #selector(pickerCancelButtonTapped), for: .touchUpInside)
        pickerDoneButton.addTarget(self, action: #selector(pickerDoneButtonTapped), for: .touchUpInside)
        signOutButton.setTitle(lang.btnSignOut, for: .normal)
        sendAgainButton.setTitle(lang.btnSendAgain, for: .normal)
        pickerCancelButton.setTitle(lang.btnCancel, for: .normal)
        pickerDoneButton.setTitle(lang.btnDone, for: .normal)
        
        let firstNameTap = UITapGestureRecognizer(target: self, action: #selector(self.firstNameContainerTapped(_:)))
        let lastNameTap = UITapGestureRecognizer(target: self, action: #selector(self.lastNameContainerTapped(_:)))
        let emailTap = UITapGestureRecognizer(target: self, action: #selector(self.emailContainerTapped(_:)))
        let phNumTap = UITapGestureRecognizer(target: self, action: #selector(self.phNumContainerTapped(_:)))
        let introTap = UITapGestureRecognizer(target: self, action: #selector(self.introContainerTapped(_:)))
        firstNameContainerView.addGestureRecognizer(firstNameTap)
        lastNameContainerView.addGestureRecognizer(lastNameTap)
        emailContainerView.addGestureRecognizer(emailTap)
        phNumberContainerView.addGestureRecognizer(phNumTap)
        introContainerView.addGestureRecognizer(introTap)
        
        mailConfMsgLabel.text = lang.msgMailNotConfirmedYet
        firstNameGuideLabel.text = lang.labelAvatarFirstName
        lastNameGuideLabel.text = lang.labelAvatarLastName
        emailGuideLabel.text = lang.labelUserMail
        phNumberGuideLabel.text = lang.labelUserPhoneNum
        introGuideLabel.text = lang.labelAvatarIntroduction
        phNumberPlaceHolderLabel.text = lang.labelUserPhoneNum
        introPlaceHolderLabel.text = lang.labelAvatarIntroduction
        
        loadProfile()
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
    
    private func loadProfile() {
        let service = Service(lang: lang)
        service.getProfile(popoverAlert: { (message) in
            self.retryFunction = self.loadProfile
            self.alertError(message)
        }, emailNotConfirmed: { (email) in
            UIView.transition(with: self.emailContainerView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.mailConfAddressButton.setTitle(email, for: .normal)
                self.mailConfContainerView.isHidden = false
            })
        }, tokenRefreshCompletion: {
            self.loadProfile()
        }) { (profile) in
            self.profile = profile
            UserDefaults.standard.setIsEmailConfirmed(value: profile.avatar.is_confirmed)
            UserDefaults.standard.setIsSignIn(value: true)
            let firstName = profile.avatar.first_name
            let index = firstName.index(firstName.startIndex, offsetBy: 0)
            self.infoImageLabel.text = String(firstName[index])
            self.infoImageLabel.textColor = UIColor.white
            self.infoImageView.backgroundColor = getProfileUIColor(key: profile.avatar.profile_type)
            self.firstNameLabel.text = firstName
            self.lastNameLabel.text = profile.avatar.last_name
            self.emailLabel.text = profile.avatar.email
            if let phoneNumber = profile.avatar.ph_number {
                self.phNumberLabel.text = phoneNumber
                self.phNumberPlaceHolderLabel.isHidden = true
            } else {
                self.phNumberGuideLabel.isHidden = true
                self.phNumberLabel.isHidden = true
                self.phNumberPlaceHolderLabel.isHidden = false
            }
            if let introduction = profile.avatar.introudction {
                self.introLabel.text = introduction
                self.introPlaceHolderLabel.isHidden = true
            } else {
                self.introGuideLabel.isHidden = true
                self.introLabel.isHidden = true
                self.introPlaceHolderLabel.isHidden = false
            }
            self.tagCollectionHeight.constant = self.getCategoryCollectionViewHeight(self.profile!.profile_tags.count)
            self.tagCollectionView.reloadData()
            self.scrollView.isHidden = false
        }
    }
    
    private func loadProfileTags() {
        let profile_tag = profile!.profile_tags[selectedCollectionItem!]
        let service = Service(lang: lang)
        service.getProfileTagSets(tagId: profile_tag.tag_id, isSelected: profile_tag.is_selected, popoverAlert: { (message) in
            self.retryFunction = self.loadProfileTags
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadProfileTags()
        }) { (profileTagSet) in
            self.tags = profileTagSet.sub_tags
            self.pickerView.reloadAllComponents()
            UIView.transition(with: self.pickerContainerView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.pickerView.selectRow(profileTagSet.select_idx, inComponent: 0, animated: true)
                self.pickerContainerView.isHidden = false
                self.pickerCancelButton.setTitleColor(UIColor.white, for: .normal)
                self.pickerCancelButton.isEnabled = true
                self.pickerDoneButton.setTitleColor(UIColor.white, for: .normal)
                self.pickerDoneButton.isEnabled = true
            })
        }
    }
    
    private func updateProfileTag() {
        guard let pickedProfileTagId = pickedTag?.id else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                UIView.transition(with: self.pickerContainerView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                    self.pickerContainerView.isHidden = true
                })
            })
            return
        }
        let profile_tag = profile!.profile_tags[selectedCollectionItem!]
        let service = Service(lang: lang)
        service.putProfileTag(profile_tag_id: profile_tag.id, new_tag_id: pickedProfileTagId, popoverAlert: { (message) in
            self.retryFunction = self.updateProfileTag
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateProfileTag()
        }) {
            if self.selectedCollectionItem == 0 {
                UserDefaults.standard.setCurrentLanguageId(value: pickedProfileTagId)
                self.setupProperties()
            }
            self.loadProfile()
        }
    }
    
    private func updateAvatarInfo() {
        UIView.transition(with: loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.loadingImageView.isHidden = false
        })
        let service = Service(lang: lang)
        service.putAvatarInfo(target: self.updateTarget!, newInfoStr: self.newInfoStr!, popoverAlert: { (message) in
            self.retryFunction = self.updateAvatarInfo
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateAvatarInfo()
        }) { (newInfoStr) in
            switch self.updateTarget! {
            case AvatarInfoTarget.firstName:
                self.firstNameLabel.text = newInfoStr
                let firstLetterIdx = newInfoStr.index(newInfoStr.startIndex, offsetBy: 0)
                self.infoImageLabel.text = String(newInfoStr[firstLetterIdx])
            case AvatarInfoTarget.lastName:
                self.lastNameLabel.text = newInfoStr
            case AvatarInfoTarget.intro:
                self.introLabel.text = newInfoStr
            default:
                fatalError()
            }
            UIView.transition(with: self.loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.loadingImageView.isHidden = true
            })
        }
    }
}
