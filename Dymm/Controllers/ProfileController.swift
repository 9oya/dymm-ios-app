//
//  ProfileController.swift
//  Flava
//
//  Created by eunsang lee on 24/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

let topBarHeightInt = 35

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    // UIView
    var topBarView: UIView!
    var mailConfContainerView: UIView!
    var infoContainerView: UIView!
    var infoImageContainerView: UIView!
    var firstNameContainerView: UIView!
    var lastNameContainerView: UIView!
    var emailContainerView: UIView!
    var phNumberContainerView: UIView!
    var introContainerView: UIView!
    
    // UICollectionView
    var tagCollectionView: UICollectionView!
    
    // UIPickerView
    var pickerView: UIPickerView!
    
    // UIImageView
    var infoImageView: UIImageView!
    
    // UITextView
    var introTextView: UITextView!
    
    // UIButton
    var signOutButton: UIButton!
    var closeButton: UIButton!
    var mailConfAddressButton: UIButton!
    var sendAgainButton: UIButton!
    
    // UILabel
    var infoImageLabel: UILabel!
    var mailConfMsgLabel: UILabel!
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
    var introLabel: UILabel!
    var introPlaceHolderLabel: UILabel!
    
    // Non-view properties
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var mailMessage: String?
    var newMailAddress: String?
    var profile: CustomModel.Profile?
    var selectedCollectionItem: Int?
    var tags: [BaseModel.Tag]?
    var pickedTag: BaseModel.Tag?
    var newInfoStr: String?
    var avatarInfoTarget: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadProfile()
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
    
    @objc func alertPicker() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.view.addSubview(pickerView)
        pickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleClose, style: .default) { _ in })
        pickerView.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
            self.updateProfileTag()
        })
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 250)
        alert.view.addConstraint(height)
        alert.view.tintColor = UIColor.cornflowerBlue
        self.present(alert, animated: true, completion: nil )
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func signOutButtonTapped() {
        UserDefaults.standard.setIsSignIn(value: false)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func mailConfAddressBtnTapped() {
        let alert = UIAlertController(title: lang.titleEditEmail, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleDone, style: .default) { _ in
            if let txtField = alert.textFields?.first, let text = txtField.text {
                self.newInfoStr = text
                self.avatarInfoTarget = AvatarInfoTarget.email
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in }
        alert.addTextField { textField in
            textField.placeholder = self.lang.titleEmail
            textField.text = self.newMailAddress!
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func sendMailAgainBtnTapped() {
        sendMailAgain()
    }
    
    @objc func firstNameContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(title: lang.titleEditFirstName, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleDone, style: .default) { _ in
            if let txtField = alert.textFields?.first, let text = txtField.text {
                if text == "" {
                    return
                } else if text.first == " " || text.count < 2 {
                    return
                }
                self.newInfoStr = text
                self.avatarInfoTarget = AvatarInfoTarget.firstName
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in }
        alert.addTextField { textField in
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = self.lang.titleFirstName
            textField.text = self.profile!.avatar.first_name
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.returnKeyType = .done
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func lastNameContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(title: lang.titleEditLastName, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleDone, style: .default) { _ in
            if let txtField = alert.textFields?.first, let text = txtField.text {
                self.newInfoStr = text
                self.avatarInfoTarget = AvatarInfoTarget.lastName
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in }
        alert.addTextField { textField in
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = self.lang.titleLastName
            textField.text = self.profile!.avatar.last_name
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func emailContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(title: lang.titleEditEmail, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleDone, style: .default) { _ in
            if let txtField = alert.textFields?.first, let text = txtField.text {
                self.newInfoStr = text
                self.avatarInfoTarget = AvatarInfoTarget.email
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in }
        alert.addTextField { textField in
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = self.lang.titleEmail
            textField.text = self.profile!.avatar.email
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func phNumContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(title: lang.titleEditPhoneNum, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleDone, style: .default) { _ in
            if let txtField = alert.textFields?.first, let text = txtField.text {
                self.newInfoStr = text
                self.avatarInfoTarget = AvatarInfoTarget.phNumber
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in }
        alert.addTextField { textField in
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = self.lang.titlePhoneNum
            textField.text = self.profile!.avatar.ph_number ?? nil
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func introContainerTapped(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(title: lang.titleEditIntro, message: nil, preferredStyle: .actionSheet)
        introTextView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let controller = UIViewController()
        introTextView.frame = controller.view.frame
        if let originTxt = introLabel.text {
            introTextView.text = originTxt
        }
        controller.view.addSubview(introTextView)
        alert.setValue(controller, forKey: "contentViewController")
        let confirmAction = UIAlertAction(title: lang.titleDone, style: .default) { _ in
            if let text = self.introTextView.text {
                self.newInfoStr = text
                self.avatarInfoTarget = AvatarInfoTarget.intro
                self.updateAvatarInfo()
            }
        }
        let cancelAction = UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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
        let avatar_fact: BaseModel.ProfileTag = profile!.profile_tags[indexPath.item]
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
        return CGSize(width: (screenWidth / 2) - 10.5, height: CGFloat(tagCellHeightInt))
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
        guard let _tags = tags else { return 0 }
        return _tags.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let _containerView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
        let _label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
        guard let _tags = tags else { fatalError() }
        switch lang.currentLanguageId {
        case LanguageId.eng: _label.text = _tags[row].eng_name
        case LanguageId.kor: _label.text = _tags[row].kor_name
        case LanguageId.jpn: _label.text = _tags[row].jpn_name
        default: fatalError()}
        _label.textAlignment = .center
        _containerView.addSubview(_label)
        return _containerView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let _tags = tags else { return }
        pickedTag = _tags[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}

extension ProfileViewController {
    
    // MARK: Private methods
    
    private func getProfileLabelContainerView() -> UIView {
        let _view = UIView()
        _view.backgroundColor = UIColor.whiteSmoke
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
    
    private func setupLayout() {
        // Initialize super view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = UIColor.whiteSmoke
        
        // Initialize subveiw properties
        topBarView = getAddtionalTopBarView()
        signOutButton = getBasicTextButton(UIColor.tomato)
        signOutButton.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        closeButton = getCloseButton()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        mailConfAddressButton = getBasicTextButton()
        mailConfAddressButton.addTarget(self, action: #selector(mailConfAddressBtnTapped), for: .touchUpInside)
        sendAgainButton = getBasicTextButton()
        sendAgainButton.addTarget(self, action: #selector(sendMailAgainBtnTapped), for: .touchUpInside)
        firstNameContainerView = getProfileLabelContainerView()
        firstNameContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.firstNameContainerTapped(_:))))
        lastNameContainerView = getProfileLabelContainerView()
        lastNameContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.lastNameContainerTapped(_:))))
        emailContainerView = getProfileLabelContainerView()
        emailContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.emailContainerTapped(_:))))
        phNumberContainerView = getProfileLabelContainerView()
        phNumberContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.phNumContainerTapped(_:))))
        introContainerView = getProfileLabelContainerView()
        introContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.introContainerTapped(_:))))
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
        
        mailConfContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.addShadowView()
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        mailConfMsgLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15, weight: .regular)
            _label.textColor = UIColor.lightSteelBlue
            _label.textAlignment = .center
            _label.numberOfLines = 2
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        infoContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.layer.cornerRadius = 10
            _view.addShadowView()
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        tagCollectionView = {
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
            _collectionView.backgroundColor = UIColor.clear
            _collectionView.register(TagCollectionCell.self, forCellWithReuseIdentifier: tagCellId)
            _collectionView.isHidden = true
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        pickerView = {
            let _pickerView = UIPickerView()
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        infoImageContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        infoImageView = {
            let _imageView = UIImageView()
            _imageView.layer.cornerRadius = 70 / 2
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        infoImageLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 35, weight: .medium)
            _label.textColor = UIColor.white
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        introTextView = {
            let _textView = UITextView()
            _textView.backgroundColor = UIColor.white
            _textView.font = .systemFont(ofSize: 14, weight: .regular)
            _textView.translatesAutoresizingMaskIntoConstraints = false
            return _textView
        }()
        introLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15, weight: .regular)
            _label.textColor = UIColor.black
            _label.textAlignment = .left
            _label.numberOfLines = 4
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        
        // Setup subviews
        view.addSubview(topBarView)
        view.addSubview(mailConfContainerView)
        view.addSubview(infoContainerView)
        view.addSubview(tagCollectionView)
        
        topBarView.addSubview(signOutButton)
        
        mailConfContainerView.addSubview(mailConfMsgLabel)
        mailConfContainerView.addSubview(mailConfAddressButton)
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
        
        setupLangProperties()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        pickerView.delegate = self
        
        // Setup constraints
        topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        topBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        topBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        topBarView.heightAnchor.constraint(equalToConstant: CGFloat(topBarHeightInt)).isActive = true
        
        signOutButton.topAnchor.constraint(equalTo: topBarView.topAnchor, constant: 0).isActive = true
        signOutButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -20).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 0).isActive = true
        
        mailConfContainerView.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 7).isActive = true
        mailConfContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        mailConfContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        mailConfContainerView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        mailConfMsgLabel.leadingAnchor.constraint(equalTo: mailConfContainerView.leadingAnchor, constant: 20).isActive = true
        mailConfMsgLabel.trailingAnchor.constraint(equalTo: mailConfContainerView.trailingAnchor, constant: -20).isActive = true
        mailConfMsgLabel.centerYAnchor.constraint(equalTo: mailConfContainerView.centerYAnchor, constant: -40).isActive = true
        
        sendAgainButton.bottomAnchor.constraint(equalTo: mailConfContainerView.bottomAnchor, constant: -15).isActive = true
        sendAgainButton.trailingAnchor.constraint(equalTo: mailConfContainerView.trailingAnchor, constant: -15).isActive = true
        
        mailConfAddressButton.bottomAnchor.constraint(equalTo: sendAgainButton.topAnchor, constant: -15).isActive = true
        mailConfAddressButton.centerXAnchor.constraint(equalTo: mailConfContainerView.centerXAnchor, constant: 0).isActive = true

        infoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(topBarHeightInt + marginInt)).isActive = true
        infoContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        infoContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
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
        firstNameContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        firstNameContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        firstNameGuideLabel.topAnchor.constraint(equalTo: firstNameContainerView.topAnchor, constant: 2).isActive = true
        firstNameGuideLabel.leadingAnchor.constraint(equalTo: firstNameContainerView.leadingAnchor, constant: 6).isActive = true
        firstNameGuideLabel.trailingAnchor.constraint(equalTo: firstNameContainerView.trailingAnchor, constant: 0).isActive = true
        
        firstNameLabel.topAnchor.constraint(equalTo: firstNameGuideLabel.bottomAnchor, constant: 2).isActive = true
        firstNameLabel.leadingAnchor.constraint(equalTo: firstNameContainerView.leadingAnchor, constant: 6).isActive = true
        firstNameLabel.trailingAnchor.constraint(equalTo: firstNameContainerView.trailingAnchor, constant: 0).isActive = true
        
        lastNameContainerView.topAnchor.constraint(equalTo: firstNameContainerView.bottomAnchor, constant: 3).isActive = true
        lastNameContainerView.leadingAnchor.constraint(equalTo: infoImageContainerView.trailingAnchor, constant: 20).isActive = true
        lastNameContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        lastNameContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        lastNameGuideLabel.topAnchor.constraint(equalTo: lastNameContainerView.topAnchor, constant: 2).isActive = true
        lastNameGuideLabel.leadingAnchor.constraint(equalTo: lastNameContainerView.leadingAnchor, constant: 6).isActive = true
        lastNameGuideLabel.trailingAnchor.constraint(equalTo: lastNameContainerView.trailingAnchor, constant: 0).isActive = true
        
        lastNameLabel.topAnchor.constraint(equalTo: lastNameGuideLabel.bottomAnchor, constant: 2).isActive = true
        lastNameLabel.leadingAnchor.constraint(equalTo: lastNameContainerView.leadingAnchor, constant: 6).isActive = true
        lastNameLabel.trailingAnchor.constraint(equalTo: lastNameContainerView.trailingAnchor, constant: 0).isActive = true
        
        emailContainerView.topAnchor.constraint(equalTo: lastNameContainerView.bottomAnchor, constant: 3).isActive = true
        emailContainerView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20).isActive = true
        emailContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        emailContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        emailGuideLabel.topAnchor.constraint(equalTo: emailContainerView.topAnchor, constant: 2).isActive = true
        emailGuideLabel.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 6).isActive = true
        emailGuideLabel.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: 0).isActive = true
        
        emailLabel.topAnchor.constraint(equalTo: emailGuideLabel.bottomAnchor, constant: 2).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 6).isActive = true
        emailLabel.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: 0).isActive = true
        
        phNumberContainerView.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 3).isActive = true
        phNumberContainerView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20).isActive = true
        phNumberContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
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
        introContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
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
        
        tagCollectionView.topAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: CGFloat(marginInt)).isActive = true
        tagCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        tagCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        tagCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    private func setupLangProperties() {
        navigationItem.title = lang.titleProfile
        mailConfMsgLabel.text = lang.msgMailNotConfirmedYet
        firstNameGuideLabel.text = lang.titleFirstNameUpper
        lastNameGuideLabel.text = lang.titleLastNameUpper
        emailGuideLabel.text = lang.titleEmailUpper
        phNumberGuideLabel.text = lang.titlePhoneNumUpper
        introGuideLabel.text = lang.titleIntroUpper
        phNumberPlaceHolderLabel.text = lang.titlePhoneNumUpper
        introPlaceHolderLabel.text = lang.titleIntroUpper
        signOutButton.setTitle(lang.titleSignOut, for: .normal)
        sendAgainButton.setTitle(lang.titleSendAgain, for: .normal)
    }
    
    private func loadProfile() {
        let service = Service(lang: lang)
        service.getProfile(popoverAlert: { (message) in
            self.retryFunction = self.loadProfile
            self.alertError(message)
        }, emailNotConfirmed: { (email) in
            self.newMailAddress = email
            UIView.transition(with: self.mailConfContainerView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.infoContainerView.isHidden = true
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
                self.phNumberLabel.isHidden = false
                self.phNumberGuideLabel.isHidden = false
                self.phNumberPlaceHolderLabel.isHidden = true
            } else {
                self.phNumberLabel.text = nil
                self.phNumberLabel.isHidden = true
                self.phNumberGuideLabel.isHidden = true
                self.phNumberPlaceHolderLabel.isHidden = false
            }
            if let introduction = profile.avatar.introudction {
                self.introLabel.text = introduction
                self.introLabel.isHidden = false
                self.introGuideLabel.isHidden = false
                self.introPlaceHolderLabel.isHidden = true
            } else {
                self.introLabel.text = nil
                self.introLabel.isHidden = true
                self.introGuideLabel.isHidden = true
                self.introPlaceHolderLabel.isHidden = false
            }
            self.tagCollectionView.reloadData()
            UIView.transition(with: self.tagCollectionView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.infoContainerView.isHidden = false
                self.tagCollectionView.isHidden = false
            })
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
            if profileTagSet.sub_tags.count > 0 {
                self.pickedTag = profileTagSet.sub_tags[profileTagSet.select_idx]
            }
            self.pickerView.reloadAllComponents()
            self.pickerView.selectRow(profileTagSet.select_idx, inComponent: 0, animated: true)
            self.alertPicker()
        }
    }
    
    private func updateProfileTag() {
        let profileTagId = profile!.profile_tags[selectedCollectionItem!].id
        let service = Service(lang: lang)
        service.putProfileTag(profile_tag_id: profileTagId, new_tag_id: pickedTag!.id, popoverAlert: { (message) in
            self.retryFunction = self.updateProfileTag
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateProfileTag()
        }) {
            if self.selectedCollectionItem == 0 {
                UserDefaults.standard.setCurrentLanguageId(value: self.pickedTag!.id)
                self.lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
                self.setupLangProperties()
            }
            self.loadProfile()
        }
    }
    
    private func updateAvatarInfo() {
        let service = Service(lang: lang)
        service.putAvatarInfo(target: self.avatarInfoTarget!, newInfoTxt: self.newInfoStr!, popoverAlert: { (message) in
            self.retryFunction = self.updateAvatarInfo
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateAvatarInfo()
        }) { (newInfoTxt) in
            self.loadProfile()
        }
    }
    
    private func sendMailAgain() {
        UIView.transition(with: mailConfMsgLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.mailConfMsgLabel.text = "u/{027B9}"
            self.mailConfMsgLabel.textColor = UIColor.black
            self.mailConfAddressButton.isHidden = true
            self.sendAgainButton.isHidden = true
        })
        mailConfMsgLabel.startRotating()
        let service = Service(lang: lang)
        service.sendMailConfLinkAgain(popoverAlert: { (message) in
            self.retryFunction = self.sendMailAgain
            self.alertError(message)
        }) {
            self.mailConfMsgLabel.stopRotating()
            UIView.animate(withDuration: 0.5, animations: {
                self.mailConfMsgLabel.text = self.lang.msgMailSnedAgainComplete
                self.mailConfMsgLabel.textColor = UIColor.mediumSeaGreen
            })
            UIView.transition(with: self.sendAgainButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.mailConfAddressButton.isHidden = false
                self.sendAgainButton.isHidden = false
            })
        }
    }
}
