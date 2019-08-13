//
//  AuthController.swift
//  Dymm
//
//  Created by eunsang lee on 23/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit
import Alamofire
import SkyFloatingLabelTextField

class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    var loadingImageView: UIImageView!
    var scrollView: UIScrollView!
    var additionalTopBarView: UIView!
    var forgotButton: UIButton!
    var closeButton: UIButton!
    let formContainerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        _view.addShadowView()
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }()
    var formContainerHeight: NSLayoutConstraint!
    let titleLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 20, weight: .light)
        _label.textColor = UIColor.black
        _label.textAlignment = .center
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    let firstNameTextField: SkyFloatingLabelTextField = {
        let _textField = SkyFloatingLabelTextField()
        _textField.font = .systemFont(ofSize: 15, weight: .light)
        _textField.selectedTitleColor = UIColor.black
        _textField.selectedLineColor = UIColor.black
        _textField.selectedLineHeight = 1
        _textField.textContentType = .namePrefix
        _textField.autocapitalizationType = .words
        _textField.isHidden = true
        _textField.translatesAutoresizingMaskIntoConstraints = false
        return _textField
    }()
    let lastNameTextField: SkyFloatingLabelTextField = {
        let _textField = SkyFloatingLabelTextField()
        _textField.font = .systemFont(ofSize: 15, weight: .light)
        _textField.selectedTitleColor = UIColor.black
        _textField.selectedLineColor = UIColor.black
        _textField.textContentType = .namePrefix
        _textField.autocapitalizationType = .words
        _textField.isHidden = true
        _textField.translatesAutoresizingMaskIntoConstraints = false
        return _textField
    }()
    let emailTextField: SkyFloatingLabelTextField = {
        let _textField = SkyFloatingLabelTextField(frame: CGRect.zero)
        _textField.font = .systemFont(ofSize: 15, weight: .light)
        _textField.selectedTitleColor = UIColor.black
        _textField.selectedLineColor = UIColor.black
        _textField.textContentType = .emailAddress
        _textField.keyboardType = .emailAddress
        _textField.autocapitalizationType = .none
        _textField.translatesAutoresizingMaskIntoConstraints = false
        return _textField
    }()
    var emailTextFieldTop: NSLayoutConstraint!
    let passwordTextField: SkyFloatingLabelTextField = {
        let _textField = SkyFloatingLabelTextField(frame: CGRect.zero)
        _textField.font = .systemFont(ofSize: 15, weight: .light)
        _textField.selectedTitleColor = UIColor.black
        _textField.selectedLineColor = UIColor.black
        _textField.textContentType = .password
        _textField.isSecureTextEntry = true
        _textField.translatesAutoresizingMaskIntoConstraints = false
        return _textField
    }()
    let confirmPassTextField: SkyFloatingLabelTextField = {
        let _textField = SkyFloatingLabelTextField(frame: CGRect.zero)
        _textField.font = .systemFont(ofSize: 15, weight: .light)
        _textField.selectedTitleColor = UIColor.black
        _textField.selectedLineColor = UIColor.black
        _textField.textContentType = .password
        _textField.isSecureTextEntry = true
        _textField.isHidden = true
        _textField.translatesAutoresizingMaskIntoConstraints = false
        return _textField
    }()
    let messageLabel: UILabel = {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 14)
        _label.textColor = UIColor(hex: "DarkOrange")
        _label.textAlignment = .center
        _label.numberOfLines = 2
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }()
    var formGrayLineView: UIView!
    let formSwapButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setTitleColor(UIColor.cornflowerBlue, for: .normal)
        _button.titleLabel?.font = .systemFont(ofSize: 16)
        _button.showsTouchWhenHighlighted = true
        _button.addTarget(self, action: #selector(formSwapButtonTapped), for: .touchUpInside)
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    let submitButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setTitleColor(UIColor.cornflowerBlue, for: .normal)
        _button.titleLabel?.font = .systemFont(ofSize: 16)
        _button.showsTouchWhenHighlighted = true
        _button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var isSignUpForm: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutStyles()
        setupLayoutSubviews()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPassTextField.delegate = self
        setupLayoutConstraints()
        setupProperties()
    }
    
    // MARK: - Actions
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func formSwapButtonTapped() {
        transitionAuthForm()
    }
    
    @objc func submitButtonTapped() {
        if isSignUpForm {
            accountSignUp()
        } else {
            accountSignIn()
        }
    }
}

extension AuthViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case emailTextField:
            guard let text = textField.text else {
                return false
            }
            guard let floatingLabelTextField = textField as? SkyFloatingLabelTextField else {
                return false
            }
            if ((text + string).isValidEmail()) {
                floatingLabelTextField.errorMessage = ""
            } else {
                floatingLabelTextField.errorMessage = lang.msgFloatingInvalidEmail
            }
        case passwordTextField:
            guard let text = textField.text else {
                return false
            }
            guard let floatingLabelTextField = textField as? SkyFloatingLabelTextField else {
                return false
            }
            if ((text + string).count >= 8) {
                floatingLabelTextField.errorMessage = ""
            } else {
                floatingLabelTextField.errorMessage = lang.msgShortPassword
            }
        case confirmPassTextField:
            guard let text = textField.text else {
                return false
            }
            guard let floatingLabelTextField = textField as? SkyFloatingLabelTextField else {
                return false
            }
            if ((text + string) == passwordTextField.text) {
                floatingLabelTextField.errorMessage = ""
            } else {
                floatingLabelTextField.errorMessage = lang.msgFloatingMismatchConfirmPassword
            }
        default:
            return true
        }
        return true
    }
}

extension AuthViewController {
    
    // MARK: Private methods
    
    private func setupLayoutStyles() {
        view.backgroundColor = UIColor(hex: "WhiteSmoke")
    }
    
    private func setupLayoutSubviews() {
        loadingImageView = getLoadingImageView(isHidden: true)
        
        scrollView = getScrollView()
        additionalTopBarView = getAddtionalTopBarView()
        forgotButton = getBasicTextButton()
        closeButton = getCloseButton()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        formGrayLineView = getGrayLineView()
        
        view.addSubview(scrollView)
        view.addSubview(loadingImageView)
        view.addSubview(additionalTopBarView)
        
        additionalTopBarView.addSubview(forgotButton)
        scrollView.addSubview(formContainerView)
        
        formContainerView.addSubview(titleLabel)
        formContainerView.addSubview(firstNameTextField)
        formContainerView.addSubview(lastNameTextField)
        formContainerView.addSubview(emailTextField)
        formContainerView.addSubview(passwordTextField)
        formContainerView.addSubview(confirmPassTextField)
        formContainerView.addSubview(messageLabel)
        formContainerView.addSubview(formSwapButton)
        formContainerView.addSubview(submitButton)
        formContainerView.addSubview(formGrayLineView)
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
        
        forgotButton.topAnchor.constraint(equalTo: additionalTopBarView.topAnchor, constant: 0).isActive = true
        forgotButton.trailingAnchor.constraint(equalTo: additionalTopBarView.trailingAnchor, constant: -20).isActive = true
        forgotButton.bottomAnchor.constraint(equalTo: additionalTopBarView.bottomAnchor, constant: 0).isActive = true
        
        // scrollView
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        formContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 35 + 7).isActive = true
        formContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 7).isActive = true
        formContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 7).isActive = true
        formContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 7).isActive = true
        formContainerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0).isActive = true
        formContainerHeight = formContainerView.heightAnchor.constraint(equalToConstant: 260)
        formContainerHeight.priority = UILayoutPriority(rawValue: 999)
        formContainerHeight.isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: 0).isActive = true
        
        firstNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        firstNameTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        firstNameTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        firstNameTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10).isActive = true
        lastNameTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        lastNameTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        lastNameTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        emailTextFieldTop = emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        emailTextFieldTop.priority = UILayoutPriority(rawValue: 999)
        emailTextFieldTop.isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        confirmPassTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        confirmPassTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 12)).isActive = true
        confirmPassTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 12)).isActive = true
        confirmPassTextField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        messageLabel.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 10).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -10).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: formGrayLineView.topAnchor, constant: -10).isActive = true
        
        formGrayLineView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: (view.frame.width / 13)).isActive = true
        formGrayLineView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 13)).isActive = true
        formGrayLineView.bottomAnchor.constraint(equalTo: formSwapButton.topAnchor, constant: -10).isActive = true
        formGrayLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        formSwapButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: view.frame.width / 8).isActive = true
        formSwapButton.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -10).isActive = true
        
        submitButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -(view.frame.width / 8)).isActive = true
        submitButton.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -10).isActive = true
    }
    
    private func setupProperties() {
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        titleLabel.text = lang.labelSignIn
        firstNameTextField.placeholder = lang.txtFieldFirstName
        firstNameTextField.title = lang.txtFieldFirstName
        lastNameTextField.placeholder = lang.txtFieldLastName
        lastNameTextField.title = lang.txtFieldLastName
        emailTextField.placeholder = lang.txtFieldEmail
        emailTextField.title = lang.txtFieldEmail
        passwordTextField.placeholder = lang.txtFieldPassword
        passwordTextField.title = lang.txtFieldPassword
        confirmPassTextField.placeholder = lang.txtFieldConfirmPassword
        confirmPassTextField.title = lang.txtFieldConfirmPassword
        forgotButton.setTitle(lang.btnForgotPassword, for: .normal)
        formSwapButton.setTitle(lang.btnSignUp, for: .normal)
        submitButton.setTitle(lang.btnSubmit, for: .normal)
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
    
    private func transitionAuthForm() {
        if isSignUpForm {
            UIView.animate(withDuration: 0.5, animations: {
                self.formContainerHeight.constant = 260
                self.emailTextFieldTop.constant = 10
                self.firstNameTextField.isHidden = true
                self.lastNameTextField.isHidden = true
                self.confirmPassTextField.isHidden = true
                self.view.layoutIfNeeded()
            })
            UIView.transition(with: titleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.titleLabel.text = self.lang.labelSignIn
                self.formSwapButton.setTitle(self.lang.btnSignUp, for: .normal)
            })
            isSignUpForm = false
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.formContainerHeight.constant = 425
                self.emailTextFieldTop.constant = 120
                self.firstNameTextField.isHidden = false
                self.lastNameTextField.isHidden = false
                self.confirmPassTextField.isHidden = false
                self.view.layoutIfNeeded()
            })
            UIView.transition(with: titleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.titleLabel.text = self.lang.labelSignUp
                self.formSwapButton.setTitle(self.lang.btnSignIn, for: .normal)
            })
            self.isSignUpForm = true
        }
    }
    
    private func setMessageLabel(_ message: String) {
        messageLabel.text = message
        UIView.transition(with: messageLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.messageLabel.isHidden = false
        })
    }
    
    private func validateSignUpParams() -> Parameters? {
        guard let first_name = firstNameTextField.text,
            let last_name = lastNameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPassTextField.text else {
                return nil
        }
        guard first_name.count > 0 else {
            setMessageLabel(lang.msgEmptyName)
            return nil
        }
        guard email.count > 0 else {
            setMessageLabel(lang.msgEmptyEmail)
            return nil
        }
        guard email.isValidEmail() else {
            setMessageLabel(lang.msgInvalidEmail)
            return nil
        }
        guard password.count > 0 else {
            setMessageLabel(lang.msgEmptyPassword)
            return nil
        }
        guard password.count >= 8 else {
            setMessageLabel(lang.msgShortPassword)
            return nil
        }
        guard passwordTextField.text == confirmPassword else {
            setMessageLabel(lang.msgMismatchConfirmPassword)
            return nil
        }
        let userParams: Parameters = [
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "password": password,
            "language_id": getDeviceLanguage()
        ]
        return userParams
    }
    
    private func validateSignInParams() -> Parameters? {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                return nil
        }
        guard email.count > 0 else {
            setMessageLabel(lang.msgEmptyEmail)
            return nil
        }
        guard email.isValidEmail() else {
            setMessageLabel(lang.msgInvalidEmail)
            return nil
        }
        guard password.count > 0 else {
            setMessageLabel(lang.msgEmptyPassword)
            return nil
        }
        guard password.count >= 8 else {
            setMessageLabel(lang.msgShortPassword)
            return nil
        }
        let userParams: Parameters = [
            "email": email,
            "password": password
        ]
        return userParams
    }
    
    private func loadingViewTrainsition() {
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            if self.loadingImageView.isHidden {
                self.formContainerView.isHidden = true
                self.loadingImageView.isHidden = false
            } else {
                self.formContainerView.isHidden = false
                self.loadingImageView.isHidden = true
            }
        })
    }
    
    private func unauthorized(_ pattern: Int) {
        switch pattern {
        case UnauthType.mailInvalid:
            setMessageLabel(lang.msgForbiddenInvalidEmail)
        case UnauthType.mailDuplicated:
            setMessageLabel(lang.msgForbiddenDuplicatedEmail)
        case UnauthType.passwordInvalid:
            setMessageLabel(lang.msgForbiddenInvalidPassword)
        default:
            fatalError("Unexpected forbidden pattern has passed")
        }
        self.loadingViewTrainsition()
    }
    
    private func accountSignIn() {
        guard let parameters = validateSignInParams() else {
            return
        }
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.formContainerView.isHidden = true
            self.loadingImageView.isHidden = false
        })
        let service = Service(lang: lang)
        service.authExistingAvatar(parameters, unauthorized: { pattern in
            self.unauthorized(pattern)
        }, popoverAlert: { message in
            self.retryFunction = self.accountSignIn
            self.alertError(message)
        }) { (auth) in
            let _avatar = auth.avatar
            UserDefaults.standard.setIsEmailConfirmed(value: _avatar.is_confirmed)
            UserDefaults.standard.setAccessToken(value: _avatar.access_token!)
            UserDefaults.standard.setRefreshToken(value: _avatar.refresh_token!)
            UserDefaults.standard.setAvatarId(value: _avatar.id)
            UserDefaults.standard.setCurrentLanguageId(value: auth.language_id)
            UserDefaults.standard.setIsSignIn(value: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func accountSignUp() {
        guard let parameters = validateSignUpParams() else {
            return
        }
        UIView.transition(with: formContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.formContainerView.isHidden = true
            self.loadingImageView.isHidden = false
        })
        let service = Service(lang: lang)
        service.createNewAvatar(parameters, unauthorized: { pattern in
            self.unauthorized(pattern)
        }, popoverAlert: { (message) in
            self.retryFunction = self.accountSignUp
            self.alertError(message)
        }) { (auth) in
            let _avatar = auth.avatar
            UserDefaults.standard.setIsEmailConfirmed(value: _avatar.is_confirmed)
            UserDefaults.standard.setAccessToken(value: _avatar.access_token!)
            UserDefaults.standard.setRefreshToken(value: _avatar.refresh_token!)
            UserDefaults.standard.setAvatarId(value: _avatar.id)
            UserDefaults.standard.setCurrentLanguageId(value: auth.language_id)
            UserDefaults.standard.setIsSignIn(value: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
