//
//  ProfileController.swift
//  Flava
//
//  Created by eunsang lee on 24/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit
import Alamofire

let topBarHeightInt = 35

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    // UIView
    var blindView: UIView!
    var topBarContainer: UIView!
    var mailConfContainer: UIView!
    var infoContainer: UIView!
    var firstNameContainer: UIView!
    var lastNameContainer: UIView!
    var emailContainer: UIView!
    var phNumberContainer: UIView!
    var introContainer: UIView!
    var colorContainer: UIView!
    
    // UICollectionView
    var tagCollection: UICollectionView!
    var colorCollection: UICollectionView!
    
    // UIPickerView
    var profileTagPicker: UIPickerView!
    
    // UIImageView
    var infoImageView: UIImageView!
    var loadingImageView: UIImageView!
    
    // UITextView
    var introTextView: UITextView!
    
    // UIButton
    var signOutButton: UIButton!
    var closeButton: UIButton!
    var mailConfAddressButton: UIButton!
    var sendAgainButton: UIButton!
    var colorLeftButton: UIButton!
    var colorRightButton: UIButton!
    
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
    var colorTitleLabel: UILabel!
    
    // Non-view properties
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var profile: CustomModel.Profile?
    var tags: [BaseModel.Tag]?
    var pickedTag: BaseModel.Tag?
    var mailMessage: String?
    var newMailAddress: String?
    var avatarInfoTarget: Int?
    var newInfoStr: String?
    var selectedCollectionItem: Int?
    var oldPassword: String?
    var newPassword: String?
    var confPassword: String?
    var isOldPasswordCorrect = true
    var resizedImage: UIImage?
    let colorCodeArr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    var selectedColorItem: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadProfile()
    }
    
    // MARK: - Actions
    
    @objc func alertError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: lang.titleYes, style: .default) { _ in
                self.retryFunction!()
            })
        alertController.addAction(UIAlertAction(title: lang.titleClose, style: .cancel) { _ in })
        alertController.view.tintColor = UIColor.cornflowerBlue
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func alertPicker() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.view.addSubview(profileTagPicker)
        profileTagPicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleClose, style: .default) { _ in })
        profileTagPicker.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
            self.updateProfileTag()
        })
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 260)
        alert.view.addConstraint(height)
        alert.view.tintColor = UIColor.cornflowerBlue
        self.present(alert, animated: true, completion: nil )
    }
    
    @objc func alertDatePicker() {
        let datePicker: UIDatePicker = UIDatePicker()
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: getUserCountryCode())
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = .date
        datePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
        if let dateOfBirth = self.profile!.avatar.date_of_birth {
            datePicker.setDate(dateFormatter.date(from: dateOfBirth)!, animated: true)
        }
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.view.addSubview(datePicker)
        alert.addAction(UIAlertAction(title: lang.titleDone, style: UIAlertAction.Style.default, handler: { _ in
            self.newInfoStr = dateFormatter.string(from: datePicker.date)
            self.avatarInfoTarget = TagId.dateOfBirth
            self.updateAvatarInfo()
        }))
        alert.addAction(UIAlertAction(title: lang.titleCancel, style: UIAlertAction.Style.cancel, handler: nil))
        alert.view.tintColor = UIColor.cornflowerBlue
        present(alert, animated: true, completion:{})
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func signOutButtonTapped() {
        UserDefaults.standard.setIsSignIn(value: false)
        UserDefaults.standard.setAvatarId(value: 0)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func alertMailConfAddressTextField() {
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
    
    @objc func alertFirstNameTextField(_ sender: UITapGestureRecognizer? = nil) {
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
    
    @objc func alertLastNameTextField(_ sender: UITapGestureRecognizer? = nil) {
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
    
    @objc func alertEmailTextField(_ sender: UITapGestureRecognizer? = nil) {
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
            textField.autocapitalizationType = .none
            textField.keyboardType = .emailAddress
            textField.placeholder = self.lang.titleEmail
            textField.text = self.profile!.avatar.email
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertPhoneNumberTextField(_ sender: UITapGestureRecognizer? = nil) {
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
    
    @objc func alertIntroTextView(_ sender: UITapGestureRecognizer? = nil) {
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
    
    @objc func alertChangePasswordCompl() {
        let alert = UIAlertController(title: lang.titlePasswordChangeCompl, message: "\n" + lang.msgChangePasswordCompl, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleDone, style: .default) { _ in
            UserDefaults.standard.setIsSignIn(value: false)
            self.dismiss(animated: true, completion: nil)
            return
        }
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertChangePassword(_ sender: UITapGestureRecognizer? = nil) {
        var title = lang.titlePasswordChange
        if !isOldPasswordCorrect {
            title = lang.titleIncorrectOldPassword
        }
        let alert = UIAlertController(title: title, message: "\n" + lang.msgShortPassword, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleSubmit, style: .default) { _ in
            self.newInfoStr = self.newPassword
            self.avatarInfoTarget = TagId.password
            self.updateAvatarInfo()
        }
        let cancelAction = UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in
            self.newInfoStr = nil
            self.oldPassword = nil
            self.newPassword = nil
            self.confPassword = nil
            self.avatarInfoTarget = nil
            self.isOldPasswordCorrect = true
        }
        alert.addTextField { textField in
            textField.autocapitalizationType = .none
            textField.keyboardType = .default
            textField.textContentType = .password
            textField.isSecureTextEntry = true
            textField.placeholder = self.lang.titlePasswordOld
            confirmAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                self.oldPassword = textField.text!
                if self.oldPassword != nil && self.newPassword != nil && self.confPassword != nil {
                    if self.oldPassword!.count >= 8 && self.newPassword!.count >= 8 && self.newPassword == self.confPassword {
                        confirmAction.isEnabled = true
                    }
                }
            }
        }
        alert.addTextField { textField in
            textField.autocapitalizationType = .none
            textField.keyboardType = .default
            textField.textContentType = .password
            textField.isSecureTextEntry = true
            textField.placeholder = self.lang.titlePasswordNew
            confirmAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                self.newPassword = textField.text!
                if self.oldPassword != nil && self.newPassword != nil && self.confPassword != nil {
                    if self.oldPassword!.count >= 8 && self.newPassword!.count >= 8 && self.newPassword == self.confPassword {
                        confirmAction.isEnabled = true
                    }
                }
            }
        }
        alert.addTextField { textField in
            textField.autocapitalizationType = .none
            textField.keyboardType = .default
            textField.textContentType = .newPassword
            textField.isSecureTextEntry = true
            textField.placeholder = self.lang.titlePasswordConfirm
            confirmAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                self.confPassword = textField.text!
                if self.oldPassword != nil && self.newPassword != nil && self.confPassword != nil {
                    if self.oldPassword!.count >= 8 && self.newPassword!.count >= 8 && self.newPassword == self.confPassword {
                        confirmAction.isEnabled = true
                    }
                }
            }
        }
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertChangeProfileImage(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(title: lang.titleChangeProfileImg, message: nil, preferredStyle: .actionSheet)
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        alert.addAction(UIAlertAction(title: lang.titleChooseColor, style: .default) { _ in
            self.colorLeftButton.setTitleColor(UIColor.cornflowerBlue, for: .normal)
            UIView.transition(with: self.colorLeftButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.colorLeftButton.isHidden = false
            })
            UIView.transition(with: self.blindView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.blindView.isHidden = false
            }) { (_) in
                print("")
            }
            return
        })
        alert.addAction(UIAlertAction(title: lang.titleCamera, style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                self.alertCameraError()
            }
        })
        alert.addAction(UIAlertAction(title: lang.titlePhotolibrary, style: .default) { _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in })
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertCameraError() {
        let alertController = UIAlertController(title: lang.titleSorry, message: lang.msgCameraDisable, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: lang.titleDone, style: .cancel) { _ in })
        alertController.view.tintColor = UIColor.cornflowerBlue
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func colorRightButtonTapped() {
        if selectedColorItem == nil {
            return
        }
        self.newInfoStr = "\(colorCodeArr[selectedColorItem!])"
        self.avatarInfoTarget = AvatarInfoTarget.color_code
        self.updateAvatarInfo()
    }
    
    @objc func colorLeftButtonTapped() {
        UIView.transition(with: self.blindView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.blindView.isHidden = true
            self.colorLeftButton.setTitleColor(UIColor.clear, for: .normal)
        }, completion: { (_) in
            self.colorLeftButton.isHidden = true
        })
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case tagCollection:
            guard let number = profile?.profile_tags.count else {
                return 0
            }
            return number
        case colorCollection:
            return colorCodeArr.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case tagCollection:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as? TagCollectionCell else {
                fatalError()
            }
            let profileTag = profile!.profile_tags[indexPath.item]
            cell.imageView.image = UIImage(named: "tag-\(profileTag.tag_id)")
            switch profileTag.tag_id {
            case TagId.subscription:
                cell.label.text = lang.titleSubscribe
                cell.label.font = .systemFont(ofSize: 14, weight: .medium)
                cell.label.textColor = UIColor(hex: "#5A3737")
            case TagId.dateOfBirth:
                if let dateOfBirth = profile?.avatar.date_of_birth {
                    cell.label.text = dateOfBirth
                    cell.label.textColor = .black
                } else {
                    cell.label.text = profileTag.eng_name
                    cell.label.textColor = .lightGray
                }
            default:
                switch lang.currentLanguageId {
                case LanguageId.eng: cell.label.text = profileTag.eng_name
                case LanguageId.kor: cell.label.text = profileTag.kor_name
                case LanguageId.jpn: cell.label.text = profileTag.jpn_name
                default: cell.label.text = profileTag.eng_name}
                if profileTag.is_selected == false {
                    cell.label.textColor = .lightGray
                    return cell
                }
                cell.label.textColor = .black
            }
            return cell
        case colorCollection:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCellId, for: indexPath) as? ColorCollectionCell else {
                fatalError()
            }
            cell.colorView.backgroundColor = getProfileUIColor(key: colorCodeArr[indexPath.item])
            if indexPath.item == selectedColorItem {
                cell.backgroundColor = .lightGray
            }
            return cell
        default:
            fatalError()
        }
        
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case tagCollection:
            selectedCollectionItem = indexPath.item
            switch profile!.profile_tags[indexPath.item].tag_id {
            case TagId.dateOfBirth:
                alertDatePicker()
                return
            case TagId.password:
                alertChangePassword()
                return
            default:
                loadProfileTagsOnPicker()
            }
        case colorCollection:
            selectedColorItem = indexPath.item
            colorCollection.reloadData()
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == colorCollection {
            guard let cell = cell as? ColorCollectionCell else {
                return
            }
            if indexPath.item == selectedColorItem {
                cell.backgroundColor = .lightGray
            } else {
                cell.backgroundColor = .white
            }
        }
    }
    
    // MARK: - UICollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        switch collectionView {
        case tagCollection:
            return CGSize(width: (screenWidth / 2) - 10.5, height: CGFloat(tagCellHeightInt))
        case colorCollection:
            return CGSize(width: (screenWidth - 34) / 6, height: (screenWidth - 34) / 6)
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case tagCollection:
            return 7
        case colorCollection:
            return 0
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case tagCollection:
            return 7
        case colorCollection:
            return 0
        default:
            fatalError()
        }
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError()
        }
        resizedImage = selectedImage.resizedTo1MB()
        uploadProfilePhoto()
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController {
    
    // MARK: Private methods
    
    private func getProfileLabelContainerView() -> UIView {
        let _view = UIView()
        _view.backgroundColor = .whiteSmoke
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }
    
    private func getProfileGuideLabel() -> UILabel {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 10, weight: .regular)
        _label.textColor = .silver
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
        _label.textColor = .silver
        _label.textAlignment = .center
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }
    
    private func setupLayout() {
        // Initialize super view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = UIColor.whiteSmoke
        
        // Initialize subveiw properties
        blindView = getAlertBlindView()
        topBarContainer = getAddtionalTopBarView()
        signOutButton = getBasicTextButton()
        signOutButton.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        closeButton = getCloseButton()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        mailConfAddressButton = getBasicTextButton(.cornflowerBlue)
        mailConfAddressButton.addTarget(self, action: #selector(alertMailConfAddressTextField), for: .touchUpInside)
        sendAgainButton = getBasicTextButton(.cornflowerBlue)
        sendAgainButton.addTarget(self, action: #selector(sendMailAgainBtnTapped), for: .touchUpInside)
        firstNameContainer = getProfileLabelContainerView()
        firstNameContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertFirstNameTextField(_:))))
        lastNameContainer = getProfileLabelContainerView()
        lastNameContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertLastNameTextField(_:))))
        emailContainer = getProfileLabelContainerView()
        emailContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertEmailTextField(_:))))
        phNumberContainer = getProfileLabelContainerView()
        phNumberContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertPhoneNumberTextField(_:))))
        introContainer = getProfileLabelContainerView()
        introContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertIntroTextView(_:))))
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
        mailConfContainer = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10
            _view.addShadowView()
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        mailConfMsgLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 15, weight: .regular)
            _label.textColor = .lightSteelBlue
            _label.textAlignment = .center
            _label.numberOfLines = 2
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        infoContainer = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10
            _view.addShadowView()
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        colorContainer = {
            let _view = UIView()
            _view.backgroundColor = .white
            _view.layer.cornerRadius = 10.0
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        tagCollection = {
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
            _collectionView.backgroundColor = .clear
            _collectionView.register(TagCollectionCell.self, forCellWithReuseIdentifier: tagCellId)
            _collectionView.isHidden = true
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        colorCollection = {
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
            _collectionView.backgroundColor = .clear
            _collectionView.register(ColorCollectionCell.self, forCellWithReuseIdentifier: colorCellId)
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        colorTitleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 18, weight: .regular)
            _label.textColor = .black
            _label.textAlignment = .left
            _label.text = lang.titleChooseColor
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        profileTagPicker = {
            let _pickerView = UIPickerView()
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        infoImageView = {
            let _imageView = UIImageView()
            _imageView.layer.cornerRadius = 70 / 2
            _imageView.contentMode = .scaleAspectFill
            _imageView.clipsToBounds = true
            _imageView.isUserInteractionEnabled = true
            _imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alertChangeProfileImage(_:))))
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        loadingImageView = getLoadingImageView(isHidden: false)
        infoImageLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 35, weight: .medium)
            _label.textColor = .white
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        introTextView = {
            let _textView = UITextView()
            _textView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            _textView.font = .systemFont(ofSize: 16, weight: .regular)
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
        colorLeftButton = {
            let _button = UIButton(type: .system)
            _button.setTitle(lang.titleClose, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            _button.setTitleColor(UIColor.clear, for: .normal)
            _button.showsTouchWhenHighlighted = false
            _button.isHidden = true
            _button.addTarget(self, action:#selector(colorLeftButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        colorRightButton = {
            let _button = UIButton(type: .system)
            _button.setTitle(lang.titleDone, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            _button.setTitleColor(UIColor.cornflowerBlue, for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(colorRightButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        
        // Setup subviews
        view.addSubview(topBarContainer)
        view.addSubview(mailConfContainer)
        view.addSubview(infoContainer)
        view.addSubview(tagCollection)
        view.addSubview(loadingImageView)
        view.addSubview(blindView)
        view.addSubview(colorLeftButton)
        
        topBarContainer.addSubview(signOutButton)
        
        mailConfContainer.addSubview(mailConfMsgLabel)
        mailConfContainer.addSubview(mailConfAddressButton)
        mailConfContainer.addSubview(sendAgainButton)
        
        infoContainer.addSubview(infoImageView)
        infoContainer.addSubview(infoImageLabel)
        infoContainer.addSubview(firstNameContainer)
        infoContainer.addSubview(lastNameContainer)
        infoContainer.addSubview(emailContainer)
        infoContainer.addSubview(phNumberContainer)
        infoContainer.addSubview(introContainer)
        
        firstNameContainer.addSubview(firstNameGuideLabel)
        firstNameContainer.addSubview(firstNameLabel)
        lastNameContainer.addSubview(lastNameGuideLabel)
        lastNameContainer.addSubview(lastNameLabel)
        emailContainer.addSubview(emailGuideLabel)
        emailContainer.addSubview(emailLabel)
        phNumberContainer.addSubview(phNumberGuideLabel)
        phNumberContainer.addSubview(phNumberLabel)
        phNumberContainer.addSubview(phNumberPlaceHolderLabel)
        introContainer.addSubview(introGuideLabel)
        introContainer.addSubview(introLabel)
        introContainer.addSubview(introPlaceHolderLabel)
        
        blindView.addSubview(colorContainer)
        colorContainer.addSubview(colorTitleLabel)
        colorContainer.addSubview(colorCollection)
        colorContainer.addSubview(colorRightButton)
        
        setupLangProperties()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        tagCollection.dataSource = self
        tagCollection.delegate = self
        colorCollection.dataSource = self
        colorCollection.delegate = self
        profileTagPicker.delegate = self
        
        // Setup constraints
        topBarContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        topBarContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        topBarContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        topBarContainer.heightAnchor.constraint(equalToConstant: CGFloat(topBarHeightInt)).isActive = true
        
        signOutButton.topAnchor.constraint(equalTo: topBarContainer.topAnchor, constant: 0).isActive = true
        signOutButton.trailingAnchor.constraint(equalTo: topBarContainer.trailingAnchor, constant: -20).isActive = true
        signOutButton.bottomAnchor.constraint(equalTo: topBarContainer.bottomAnchor, constant: 0).isActive = true
        
        mailConfContainer.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor, constant: 7).isActive = true
        mailConfContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        mailConfContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        mailConfContainer.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        mailConfMsgLabel.leadingAnchor.constraint(equalTo: mailConfContainer.leadingAnchor, constant: 20).isActive = true
        mailConfMsgLabel.trailingAnchor.constraint(equalTo: mailConfContainer.trailingAnchor, constant: -20).isActive = true
        mailConfMsgLabel.centerYAnchor.constraint(equalTo: mailConfContainer.centerYAnchor, constant: -40).isActive = true
        
        sendAgainButton.bottomAnchor.constraint(equalTo: mailConfContainer.bottomAnchor, constant: -15).isActive = true
        sendAgainButton.trailingAnchor.constraint(equalTo: mailConfContainer.trailingAnchor, constant: -15).isActive = true
        
        mailConfAddressButton.bottomAnchor.constraint(equalTo: sendAgainButton.topAnchor, constant: -15).isActive = true
        mailConfAddressButton.centerXAnchor.constraint(equalTo: mailConfContainer.centerXAnchor, constant: 0).isActive = true
        
        infoContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(topBarHeightInt + marginInt)).isActive = true
        infoContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        infoContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        infoContainer.heightAnchor.constraint(equalToConstant: 280).isActive = true

        infoImageView.topAnchor.constraint(equalTo: infoContainer.topAnchor, constant: 20).isActive = true
        infoImageView.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 20).isActive = true
        infoImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        infoImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        infoImageLabel.centerXAnchor.constraint(equalTo: infoImageView.centerXAnchor, constant: 0).isActive = true
        infoImageLabel.centerYAnchor.constraint(equalTo: infoImageView.centerYAnchor, constant: 0).isActive = true
        
        firstNameContainer.topAnchor.constraint(equalTo: infoContainer.topAnchor, constant: 15).isActive = true
        firstNameContainer.leadingAnchor.constraint(equalTo: infoImageView.trailingAnchor, constant: 20).isActive = true
        firstNameContainer.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        firstNameContainer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        firstNameGuideLabel.topAnchor.constraint(equalTo: firstNameContainer.topAnchor, constant: 2).isActive = true
        firstNameGuideLabel.leadingAnchor.constraint(equalTo: firstNameContainer.leadingAnchor, constant: 6).isActive = true
        firstNameGuideLabel.trailingAnchor.constraint(equalTo: firstNameContainer.trailingAnchor, constant: 0).isActive = true
        
        firstNameLabel.topAnchor.constraint(equalTo: firstNameGuideLabel.bottomAnchor, constant: 2).isActive = true
        firstNameLabel.leadingAnchor.constraint(equalTo: firstNameContainer.leadingAnchor, constant: 6).isActive = true
        firstNameLabel.trailingAnchor.constraint(equalTo: firstNameContainer.trailingAnchor, constant: 0).isActive = true
        
        lastNameContainer.topAnchor.constraint(equalTo: firstNameContainer.bottomAnchor, constant: 3).isActive = true
        lastNameContainer.leadingAnchor.constraint(equalTo: infoImageView.trailingAnchor, constant: 20).isActive = true
        lastNameContainer.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        lastNameContainer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        lastNameGuideLabel.topAnchor.constraint(equalTo: lastNameContainer.topAnchor, constant: 2).isActive = true
        lastNameGuideLabel.leadingAnchor.constraint(equalTo: lastNameContainer.leadingAnchor, constant: 6).isActive = true
        lastNameGuideLabel.trailingAnchor.constraint(equalTo: lastNameContainer.trailingAnchor, constant: 0).isActive = true
        
        lastNameLabel.topAnchor.constraint(equalTo: lastNameGuideLabel.bottomAnchor, constant: 2).isActive = true
        lastNameLabel.leadingAnchor.constraint(equalTo: lastNameContainer.leadingAnchor, constant: 6).isActive = true
        lastNameLabel.trailingAnchor.constraint(equalTo: lastNameContainer.trailingAnchor, constant: 0).isActive = true
        
        emailContainer.topAnchor.constraint(equalTo: lastNameContainer.bottomAnchor, constant: 3).isActive = true
        emailContainer.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 20).isActive = true
        emailContainer.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        emailContainer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        emailGuideLabel.topAnchor.constraint(equalTo: emailContainer.topAnchor, constant: 2).isActive = true
        emailGuideLabel.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 6).isActive = true
        emailGuideLabel.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: 0).isActive = true
        
        emailLabel.topAnchor.constraint(equalTo: emailGuideLabel.bottomAnchor, constant: 2).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 6).isActive = true
        emailLabel.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: 0).isActive = true
        
        phNumberContainer.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 3).isActive = true
        phNumberContainer.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 20).isActive = true
        phNumberContainer.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        phNumberContainer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        phNumberGuideLabel.topAnchor.constraint(equalTo: phNumberContainer.topAnchor, constant: 2).isActive = true
        phNumberGuideLabel.leadingAnchor.constraint(equalTo: phNumberContainer.leadingAnchor, constant: 6).isActive = true
        phNumberGuideLabel.trailingAnchor.constraint(equalTo: phNumberContainer.trailingAnchor, constant: 0).isActive = true
        
        phNumberLabel.topAnchor.constraint(equalTo: phNumberGuideLabel.bottomAnchor, constant: 2).isActive = true
        phNumberLabel.leadingAnchor.constraint(equalTo: phNumberContainer.leadingAnchor, constant: 6).isActive = true
        phNumberLabel.trailingAnchor.constraint(equalTo: phNumberContainer.trailingAnchor, constant: 0).isActive = true
        
        phNumberPlaceHolderLabel.leadingAnchor.constraint(equalTo: phNumberContainer.leadingAnchor, constant: 0).isActive = true
        phNumberPlaceHolderLabel.trailingAnchor.constraint(equalTo: phNumberContainer.trailingAnchor, constant: 0).isActive = true
        phNumberPlaceHolderLabel.centerYAnchor.constraint(equalTo: phNumberContainer.centerYAnchor, constant: 0).isActive = true
        
        introContainer.topAnchor.constraint(equalTo: phNumberContainer.bottomAnchor, constant: 3).isActive = true
        introContainer.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 20).isActive = true
        introContainer.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        introContainer.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        introGuideLabel.topAnchor.constraint(equalTo: introContainer.topAnchor, constant: 2).isActive = true
        introGuideLabel.leadingAnchor.constraint(equalTo: introContainer.leadingAnchor, constant: 6).isActive = true
        introGuideLabel.trailingAnchor.constraint(equalTo: introContainer.trailingAnchor, constant: 0).isActive = true
        
        introLabel.topAnchor.constraint(equalTo: introGuideLabel.bottomAnchor, constant: 2).isActive = true
        introLabel.leadingAnchor.constraint(equalTo: introContainer.leadingAnchor, constant: 6).isActive = true
        introLabel.trailingAnchor.constraint(equalTo: introContainer.trailingAnchor, constant: 0).isActive = true
        
        introPlaceHolderLabel.leadingAnchor.constraint(equalTo: introContainer.leadingAnchor, constant: 0).isActive = true
        introPlaceHolderLabel.trailingAnchor.constraint(equalTo: introContainer.trailingAnchor, constant: 0).isActive = true
        introPlaceHolderLabel.centerYAnchor.constraint(equalTo: introContainer.centerYAnchor, constant: 0).isActive = true
        
        tagCollection.topAnchor.constraint(equalTo: infoContainer.bottomAnchor, constant: CGFloat(marginInt)).isActive = true
        tagCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        tagCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        tagCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        loadingImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
        
        blindView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        blindView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        blindView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        blindView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        colorContainer.leadingAnchor.constraint(equalTo: blindView.leadingAnchor, constant: 7).isActive = true
        colorContainer.trailingAnchor.constraint(equalTo: blindView.trailingAnchor, constant: -7).isActive = true
        colorContainer.centerXAnchor.constraint(equalTo: blindView.centerXAnchor, constant: 0).isActive = true
        colorContainer.centerYAnchor.constraint(equalTo: blindView.centerYAnchor, constant: 0).isActive = true
        colorContainer.heightAnchor.constraint(equalToConstant: (60 * 3) + 100).isActive = true
        
        colorCollection.topAnchor.constraint(equalTo: colorContainer.topAnchor, constant: 40).isActive = true
        colorCollection.centerXAnchor.constraint(equalTo: colorContainer.centerXAnchor, constant: 0).isActive = true
        colorCollection.leadingAnchor.constraint(equalTo: colorContainer.leadingAnchor, constant: 15).isActive = true
        colorCollection.trailingAnchor.constraint(equalTo: colorContainer.trailingAnchor, constant: -15).isActive = true
        colorCollection.heightAnchor.constraint(equalToConstant: 60 * 3).isActive = true
        
        colorTitleLabel.topAnchor.constraint(equalTo: colorContainer.topAnchor, constant: 10).isActive = true
        colorTitleLabel.centerXAnchor.constraint(equalTo: colorContainer.centerXAnchor, constant: 0).isActive = true
        
        colorLeftButton.leadingAnchor.constraint(equalTo: colorContainer.leadingAnchor, constant: 0).isActive = true
        colorLeftButton.bottomAnchor.constraint(equalTo: colorContainer.bottomAnchor, constant: -5).isActive = true
        colorLeftButton.widthAnchor.constraint(equalToConstant: view.frame.width / 4).isActive = true
        colorLeftButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        colorRightButton.trailingAnchor.constraint(equalTo: colorContainer.trailingAnchor, constant: 0).isActive = true
        colorRightButton.bottomAnchor.constraint(equalTo: colorContainer.bottomAnchor, constant: -5).isActive = true
        colorRightButton.widthAnchor.constraint(equalToConstant: view.frame.width / 4).isActive = true
        colorRightButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func setupLangProperties() {
        navigationItem.title = lang.titleProfile
        mailConfMsgLabel.text = lang.msgMailNotConfirmedYet
        firstNameGuideLabel.text = lang.titleFirstNameUpper
        lastNameGuideLabel.text = lang.titleLastNameUpper
        emailGuideLabel.text = lang.titleEmailUpper
        phNumberGuideLabel.text = lang.titlePhoneNumUpper
        introGuideLabel.text = lang.titleIntroUpper
        phNumberPlaceHolderLabel.text = lang.titlePhoneNum
        introPlaceHolderLabel.text = lang.titleIntro
        signOutButton.setTitle(lang.titleSignOut, for: .normal)
        sendAgainButton.setTitle(lang.titleSendAgain, for: .normal)
    }
    
    private func loadProfile() {
        if loadingImageView.isHidden {
            UIView.transition(with: loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.infoContainer.isHidden = true
                self.tagCollection.isHidden = true
                self.loadingImageView.isHidden = false
            })
        }
        let service = Service(lang: lang)
        service.getProfile(popoverAlert: { (message) in
            self.retryFunction = self.loadProfile
            self.alertError(message)
        }, emailNotConfirmed: { (email) in
            self.newMailAddress = email
            UIView.transition(with: self.mailConfContainer, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.infoContainer.isHidden = true
                self.mailConfAddressButton.setTitle(email, for: .normal)
                self.mailConfContainer.isHidden = false
                self.loadingImageView.isHidden = true
            })
        }, tokenRefreshCompletion: {
            self.loadProfile()
        }) { (profile) in
            self.profile = profile
            UserDefaults.standard.setCurrentLanguageId(value: profile.language_id)
            UserDefaults.standard.setIsEmailConfirmed(value: profile.avatar.is_confirmed)
            UserDefaults.standard.setIsSignIn(value: true)
            let firstName = profile.avatar.first_name
            if profile.avatar.photo_name != nil && profile.avatar.color_code == 0 {
                print(profile.avatar.photo_name!)
                let url = "\(URI.host)\(URI.avatar)/\(profile.avatar.id)/profile/photo/\(profile.avatar.photo_name!)"
                Alamofire.request(url).responseImage { response in
                    if let data = response.data {
                        self.infoImageView.image = UIImage(data: data)
                    }
                }
            } else {
                let index = firstName.index(firstName.startIndex, offsetBy: 0)
                self.infoImageLabel.text = String(firstName[index])
                self.infoImageLabel.textColor = .white
                self.infoImageView.backgroundColor = getProfileUIColor(key: profile.avatar.color_code)
            }
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
            self.tagCollection.reloadData()
            UIView.transition(with: self.tagCollection, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.infoContainer.isHidden = false
                self.tagCollection.isHidden = false
                self.loadingImageView.isHidden = true
            })
        }
    }
    
    private func loadProfileTagsOnPicker() {
        let profile_tag = profile!.profile_tags[selectedCollectionItem!]
        let service = Service(lang: lang)
        service.getProfileTagSets(tagId: profile_tag.tag_id, isSelected: profile_tag.is_selected, popoverAlert: { (message) in
            self.retryFunction = self.loadProfileTagsOnPicker
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadProfileTagsOnPicker()
        }) { (profileTagSet) in
            self.tags = profileTagSet.sub_tags
            if profileTagSet.sub_tags.count > 0 {
                self.pickedTag = profileTagSet.sub_tags[profileTagSet.select_idx]
            }
            self.profileTagPicker.reloadAllComponents()
            self.profileTagPicker.selectRow(profileTagSet.select_idx, inComponent: 0, animated: true)
            self.alertPicker()
        }
    }
    
    private func updateProfileTag() {
        UIView.transition(with: loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.infoContainer.isHidden = true
            self.tagCollection.isHidden = true
            self.loadingImageView.isHidden = false
        })
        let profileTagId = profile!.profile_tags[selectedCollectionItem!].id
        let service = Service(lang: lang)
        service.putProfileTag(profile_tag_id: profileTagId, tag_id: pickedTag!.id, popoverAlert: { (message) in
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
        UIView.transition(with: loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.infoContainer.isHidden = true
            self.tagCollection.isHidden = true
            self.loadingImageView.isHidden = false
        })
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        var params: Parameters = [
            "avatar_id": avatarId,
            "target": avatarInfoTarget!,
            "new_info": newInfoStr!
        ]
        if oldPassword != nil {
            params["old_password"] = oldPassword!
        }
        let service = Service(lang: lang)
        service.putAvatarInfo(params: params, unauthorized: { (pattern) in
            if pattern == UnauthType.passwordInvalid {
                self.isOldPasswordCorrect = false
                self.alertChangePassword()
            }
        }, popoverAlert: { (message) in
            self.retryFunction = self.updateAvatarInfo
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateAvatarInfo()
        }) { (newInfoTxt) in
            self.newInfoStr = nil
            self.oldPassword = nil
            self.newPassword = nil
            self.confPassword = nil
            self.isOldPasswordCorrect = true
            if self.avatarInfoTarget == TagId.password {
                self.alertChangePasswordCompl()
                self.avatarInfoTarget = nil
                return
            } else if self.avatarInfoTarget == AvatarInfoTarget.color_code {
                self.colorLeftButtonTapped()
            }
            self.avatarInfoTarget = nil
            self.loadProfile()
        }
    }
    
    private func sendMailAgain() {
        UIView.transition(with: mailConfMsgLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.mailConfMsgLabel.text = "u/{02059}"
            self.mailConfMsgLabel.textColor = UIColor.black
            self.mailConfAddressButton.isHidden = true
            self.sendAgainButton.isHidden = true
        })
        mailConfMsgLabel.startRotating()
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let params: Parameters = [
            "avatar_id": avatarId
        ]
        let service = Service(lang: lang)
        service.sendMailConfLinkAgain(params: params, popoverAlert: { (message) in
            self.retryFunction = self.sendMailAgain
            self.alertError(message)
        }) {
            self.mailConfMsgLabel.stopRotating()
            UIView.animate(withDuration: 0.5, animations: {
                self.mailConfMsgLabel.text = self.lang.msgMailSendAgainComplete
                self.mailConfMsgLabel.textColor = UIColor.mediumSeaGreen
            })
            UIView.transition(with: self.sendAgainButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.mailConfAddressButton.isHidden = false
                self.sendAgainButton.isHidden = false
            })
        }
    }
    
    private func uploadProfilePhoto() {
        if loadingImageView.isHidden {
            UIView.transition(with: loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.infoContainer.isHidden = true
                self.tagCollection.isHidden = true
                self.loadingImageView.isHidden = false
            })
        }
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let service = Service(lang: lang)
        service.postProfilePhoto(avatarId: avatarId, image: resizedImage!.pngData()!, popoverAlert: { (message) in
            self.retryFunction = self.uploadProfilePhoto
            self.alertError(message)
        }) {
            self.infoImageView.image = self.resizedImage!
            UIView.transition(with: self.loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.infoContainer.isHidden = false
                self.tagCollection.isHidden = false
                self.loadingImageView.isHidden = true
            })
        }
    }
}
